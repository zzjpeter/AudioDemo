//
//  EncodeH264Manager.m
//  AudioDemo
//
//  Created by 朱志佳 on 2019/5/22.
//  Copyright © 2019 朱志佳. All rights reserved.
//

#import "EncodeH264Manager.h"

@interface EncodeH264Manager ()<AVCaptureVideoDataOutputSampleBufferDelegate>
{
    int frameID;
    dispatch_queue_t mCaptureQueue;
    dispatch_queue_t mEncodeQueue;
    VTCompressionSessionRef mEncodingSession;
    CMFormatDescriptionRef  format;
    NSFileHandle *writeFileHandle;
}
@property (nonatomic , strong) AVCaptureSession *mCaptureSession; //负责输入和输出设备之间的数据传递
//@property (nonatomic , strong) AVCaptureDeviceInput *mCaptureDeviceInput;//负责从AVCaptureDevice获得输入数据
//@property (nonatomic , strong) AVCaptureVideoDataOutput *mCaptureVideoDataOutput; //负责将mCaptureDeviceInput获取的输入数据 输出给应用applicaiton
@property (nonatomic , strong) AVCaptureVideoPreviewLayer *mPreviewLayer;

@end

@implementation EncodeH264Manager

SingleImplementation(manager)

#pragma mark public
- (void)startWithConfiguration:(CommonVideoConfiguration *)configuration
{
    if (self.mCaptureSession.running) {
        [self stop];
    }
    self.configuration = configuration;
    [self startCapture:configuration];
}
- (void)stop
{
    [self stopCapture];
}

#pragma mark private
- (void)startCapture:(CommonVideoConfiguration *)configuration
{
    //0.设置文件写入
    [self setWriteFileHandle];
    
    //1.设置CaptureSession 添加数据设备输入和数据输出到应用 1.1设置输入设备
    [self setCaptureSession:self.mCaptureSession configuration:configuration];
            
    //2.设置视频预览
    [self setPreviewLayer:self.mCaptureSession configuration:configuration];
    
    //3.设置VideoToolBox 如编码器类型（CMVideoCodecType kCMVideoCodecType_H264）
    [self setVideoToolBoxConfiguration:configuration];
        
    //4.启动
    [self.mCaptureSession startRunning];
}

- (void)stopCapture {
    
    [self.mCaptureSession stopRunning];
    
    [self.mPreviewLayer removeFromSuperlayer];
    
    [self endVideoToolBox];
    
    [self closeFileHandle];
}

#pragma mark 0.处理录制文件写入fileHandle
- (void)setWriteFileHandle
{
    NSString *file = self.configuration.writeFile;
    [[NSFileManager defaultManager] removeItemAtPath:file error:nil];
    [[NSFileManager defaultManager] createFileAtPath:file contents:nil attributes:nil];
    writeFileHandle = [NSFileHandle fileHandleForWritingAtPath:file];
}
- (void)closeFileHandle
{
    [writeFileHandle closeFile];
    writeFileHandle = NULL;
}

#pragma mark 1.设置CaptureSession 添加数据设备输入和数据输出到应用
- (void)setCaptureSession:(AVCaptureSession *)mCaptureSession configuration:(CommonVideoConfiguration *)configuration {
    
    if (mCaptureSession.running) {
        [self stop];
    }
    
    mCaptureQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    
    if (IsEmpty(mCaptureSession)) {
        AVCaptureSession *mCaptureSession = [[AVCaptureSession alloc] init];
        self.mCaptureSession = mCaptureSession;
    }
    
    mCaptureSession.sessionPreset = configuration.avsessionPreset;
    
    //1.配置CaptureDeviceInput
    AVCaptureDevice *inputDevice = [self inputDeviceCameraWithPostion:configuration.devicePosition];
    AVCaptureDeviceInput *mCaptureDeviceInput = [[AVCaptureDeviceInput alloc] initWithDevice:inputDevice error:nil];
    if ([mCaptureSession canAddInput:mCaptureDeviceInput]) {
        [mCaptureSession addInput:mCaptureDeviceInput];
    }
    
    //2.配置CaptureVideoDataOutput
    AVCaptureVideoDataOutput *mCaptureVideoDataOutput = [[AVCaptureVideoDataOutput alloc] init];
    [mCaptureVideoDataOutput setAlwaysDiscardsLateVideoFrames:NO];//当此属性的值为NO时，将使委托者有更多时间处理旧帧，然后丢弃新帧，但结果是应用程序内存使用量可能会大大增加。 默认值为是。
    [mCaptureVideoDataOutput setVideoSettings:@{(id)kCVPixelBufferPixelFormatTypeKey:@(kCVPixelFormatType_420YpCbCr8BiPlanarFullRange)}];
    [mCaptureVideoDataOutput setSampleBufferDelegate:self queue:mCaptureQueue];
    if ([mCaptureSession canAddOutput:mCaptureVideoDataOutput]) {
        [mCaptureSession addOutput:mCaptureVideoDataOutput];
    }
    
    //此设置要放到addDeviceInput之后才能获取到
    //通过输入设备和数据输出 设置 connection和设备的 方向、帧率、光学防抖 等配置
    [self setConnectionWithmCaptureVideoDataOutput:mCaptureVideoDataOutput inputDevice:inputDevice configuration:configuration];
    
}
#pragma mark 1.1设置输入设备
- (AVCaptureDevice *)inputDeviceCameraWithPostion:(AVCaptureDevicePosition)position {
    
    //返回和视频录制相关的默认设备
    NSArray *devices = nil;
    if (@available(iOS 10.0, *)) {
        AVCaptureDeviceDiscoverySession *deviceDiscoverySession = [AVCaptureDeviceDiscoverySession  discoverySessionWithDeviceTypes:@[AVCaptureDeviceTypeBuiltInWideAngleCamera] mediaType:AVMediaTypeVideo position:position];
        devices = deviceDiscoverySession.devices;
    } else {
        devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    }
    
    //遍历这些设备返回跟postion相关的设备
    AVCaptureDevice *inputDeviceCamera = nil;
    for (AVCaptureDevice *device in devices){
        if (device.position == position){
            inputDeviceCamera = device;
        }
    }
    return inputDeviceCamera;
}
#pragma mark 1.2 通过输入设备和数据输出 设置 connection和设备的 方向、帧率、光学防抖 等配置
- (void)setConnectionWithmCaptureVideoDataOutput:(AVCaptureVideoDataOutput *)mCaptureVideoDataOutput
           inputDevice:(AVCaptureDevice *)inputDevice
         configuration:(CommonVideoConfiguration *)configuration {
    
    AVCaptureConnection *connection = [mCaptureVideoDataOutput connectionWithMediaType:AVMediaTypeVideo];
    //1.设置方向
    if(configuration.landscape){
        if (connection.isVideoOrientationSupported) {
            connection.videoOrientation = AVCaptureVideoOrientationLandscapeLeft;
        }
    }else{
        if (connection.isVideoOrientationSupported) {
            connection.videoOrientation = AVCaptureVideoOrientationPortrait;
        }
    }
    
    //2.设置帧率
    CMTime videoFrameRate =  CMTimeMake(1, (int32_t)configuration.videoFrameRate);
    NSArray *supportedFrameRateRanges = [inputDevice.activeFormat videoSupportedFrameRateRanges];
    BOOL frameRateSupported = NO;
    for (AVFrameRateRange *range in supportedFrameRateRanges) {
        if (CMTIME_COMPARE_INLINE(videoFrameRate, >=, range.minFrameDuration) &&
            CMTIME_COMPARE_INLINE(videoFrameRate, <=, range.maxFrameDuration)) {
            frameRateSupported = YES;
        }
    }
    if (frameRateSupported) {
        NSError *error = nil;
        if ([inputDevice lockForConfiguration:&error]) {
            inputDevice.activeVideoMaxFrameDuration = videoFrameRate;
            inputDevice.activeVideoMinFrameDuration = videoFrameRate;
            [inputDevice unlockForConfiguration];
        }
    }
    
    //3.光学防抖
    AVCaptureVideoStabilizationMode stabilizationMode = AVCaptureVideoStabilizationModeCinematic;
    if ([inputDevice.activeFormat isVideoStabilizationModeSupported:stabilizationMode]) {
        [connection setPreferredVideoStabilizationMode:stabilizationMode];
    }
    
}

#pragma mark 2.设置视频预览
- (void)setPreviewLayer:(AVCaptureSession *)mCaptureSession configuration:(CommonVideoConfiguration *)configuration{
    
    if (!mCaptureSession) {
        NSLog(@"mCaptureSession捕捉会话设置失败");
        return;
    }
    
    UIView *preview = configuration.preview;
    if (IsEmpty(preview)) {
        return;
    }
    
    AVCaptureVideoPreviewLayer *mPreviewLayer = ({
        AVCaptureVideoPreviewLayer *mPreviewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:mCaptureSession];
        [mPreviewLayer setVideoGravity:AVLayerVideoGravityResizeAspect];
        [mPreviewLayer setFrame:preview.bounds];
        [preview.layer addSublayer:mPreviewLayer];
        mPreviewLayer;
    });
    self.mPreviewLayer = mPreviewLayer;

}

#pragma mark 3.设置VideoToolBox 如编码器类型（CMVideoCodecType kCMVideoCodecType_H264）
- (void)setVideoToolBoxConfiguration:(CommonVideoConfiguration *)configuration {
    
    mEncodeQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    
    dispatch_sync(mEncodeQueue  , ^{
        
        self->frameID = 0;
        int width = configuration.videoSize.width, height = configuration.videoSize.height;
        OSStatus status = VTCompressionSessionCreate(NULL, width, height, kCMVideoCodecType_H264, NULL, NULL, NULL, didCompressH264, (__bridge void *)(self),  &mEncodingSession);
        NSLog(@"H264: VTCompressionSessionCreate %d", (int)status);
        if (status != 0)
        {
            NSLog(@"H264: Unable to create a H264 session");
            return ;
        }
        
        //设置编码进行的一系列参数配置（帧间隔、fps、bitRate、是否实时等 具体可以通过点击key进去参考文档设置）
        [self setVTSessionSetProperty:mEncodingSession configuration:configuration];
        
    });
}

#pragma mark 3.1设置编码进行的一系列参数配置（帧间隔、fps、bitRate、是否实时等 具体可以通过点击key进去参考文档设置）
- (void)setVTSessionSetProperty:(VTCompressionSessionRef)mEncodingSession configuration:(CommonVideoConfiguration *)configuration{
    
    // 设置关键帧（GOPsize)最大间隔帧数 frameInterval(两关键帧之间允许 间隔的 最大帧数)
    VTSessionSetProperty(mEncodingSession, kVTCompressionPropertyKey_MaxKeyFrameInterval, (__bridge CFTypeRef)@(_configuration.videoMaxKeyframeInterval));
    
    // 设置关键帧（GOPsize)最大间隔时间 frameIntervalDuration(两关键帧之间允许 间隔的 最大时间)
    VTSessionSetProperty(mEncodingSession, kVTCompressionPropertyKey_MaxKeyFrameIntervalDuration, (__bridge CFTypeRef)@(_configuration.videoMaxKeyFrameIntervalDuration));
    
    // 允许帧重新排序.默认为true
    VTSessionSetProperty(mEncodingSession, kVTCompressionPropertyKey_AllowFrameReordering, (__bridge CFTypeRef)@(configuration.allowFrameReordering));
    
    // 设置码率，均值，单位是bps bit bitRate
    VTSessionSetProperty(mEncodingSession, kVTCompressionPropertyKey_AverageBitRate, (__bridge CFTypeRef)@(configuration.videoBitRate));
    
    // 设置码率，上限，单位是Bps Byte bitRateLimit CFArray[CFNumber], [bytes, seconds, bytes, seconds...], Optional
    NSArray *dataRateLimits = @[@(configuration.videoMaxBitRate / 8), @(1)];
    VTSessionSetProperty(mEncodingSession, kVTCompressionPropertyKey_DataRateLimits, (__bridge CFArrayRef)dataRateLimits);
    
    // 指定编码比特流的配置和标准 比如kVTProfileLevel_H264_Main_AutoLevel
    VTSessionSetProperty(mEncodingSession, kVTCompressionPropertyKey_ProfileLevel, (__bridge CFStringRef)configuration.profileLevel);
    
    // 建议不设置（默认值是特定于编码器的，并且可能会根据其他编码器设置而改变。使用此属性时应小心-更改可能会导致配置与请求的配置文件和级别不兼容）
    // H.264压缩的熵编码模式 基于上下文的自适应可变长度编码（CAVLC）或基于上下文的自适应二进制算术编码（CABAC）
    //VTSessionSetProperty(mEncodingSession, kVTCompressionPropertyKey_H264EntropyMode, kVTH264EntropyMode_CABAC);
    
    // 视频编码压缩是否是实时压缩。可设置CFBoolean或NULL.默认为NULL
    // 1.对于离线压缩，建议将此属性设置为kCFBooleanFalse，以获取更好的效果，
    // 2.对于实时压缩，建议将此属性设置为kCFBooleanTrue，避免延迟
    VTSessionSetProperty(mEncodingSession, kVTCompressionPropertyKey_RealTime, (__bridge CFBooleanRef)@(configuration.realTime));
    
    // 设置期望帧率 fps 帧速率以每秒帧数为单位
    VTSessionSetProperty(mEncodingSession, kVTCompressionPropertyKey_ExpectedFrameRate, (__bridge CFTypeRef)@(configuration.videoFrameRate));
    
    // Tell the encoder to start encoding 启动编码（具体编码操作在编码回调中进行处理）
    VTCompressionSessionPrepareToEncodeFrames(mEncodingSession);
}

#pragma mark 4.结束编码操作 释放编码操作相关资源
- (void)endVideoToolBox
{
    VTCompressionSessionCompleteFrames(mEncodingSession, kCMTimeInvalid);
    VTCompressionSessionInvalidate(mEncodingSession);
    CFRelease(mEncodingSession);
    mEncodingSession = NULL;
}

#pragma mark 压缩编码逻辑处理
#pragma mark AVCaptureVideoDataOutputSampleBufferDelegate
- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection {
    dispatch_sync(mEncodeQueue, ^{
        [self encode:sampleBuffer];
    });
}

#pragma mark encode 设置Frame编码参数
- (void)encode:(CMSampleBufferRef )sampleBuffer
{
    CVImageBufferRef imageBuffer = (CVImageBufferRef)CMSampleBufferGetImageBuffer(sampleBuffer);
    CMTime presentationTimeStamp = CMTimeMake(frameID++, 1000);// 帧时间，如果不设置会导致时间轴过长。固定压缩为每秒1000帧
    CMTime duration = kCMTimeInvalid;//默认值kCMTimeInvalid
    duration = CMTimeMake(1, (int32_t)_configuration.videoFrameRate);
    NSDictionary * dic = nil;
    if (frameID % _configuration.videoFrameRate == 0) {
        dic = @{(__bridge NSString *)kVTEncodeFrameOptionKey_ForceKeyFrame: @YES};
    }
    VTEncodeInfoFlags flags;
    OSStatus statusCode = VTCompressionSessionEncodeFrame(mEncodingSession,
                                                          imageBuffer,
                                                          presentationTimeStamp,
                                                          duration,
                                                          (CFDictionaryRef)dic,
                                                          NULL,
                                                          &flags);
    if (statusCode != noErr) {
        NSLog(@"H264: VTCompressionSessionEncodeFrame failed with %d", (int)statusCode);
        [self endVideoToolBox];
        return;
    }
    NSLog(@"H264: VTCompressionSessionEncodeFrame Success");
}

#pragma mark 编码完成后的数据回调 建议处理称nsdata进行存储或者传输
void didCompressH264(void *outputCallbackRefCon, void *sourceFrameRefCon, OSStatus status, VTEncodeInfoFlags infoFlags, CMSampleBufferRef sampleBuffer)
{
    NSLog(@"didCompressH264 called with status %d infoFlags %d", (int)status, (int)infoFlags);
    if (status != 0) {
        return;
    }
    if (!CMSampleBufferDataIsReady(sampleBuffer)) {
        NSLog(@"didCompressH264 data is not ready ");
        return;
    }
    
    EncodeH264Manager* encoder = (__bridge EncodeH264Manager*)outputCallbackRefCon;
    
    bool keyframe = !CFDictionaryContainsKey( (CFArrayGetValueAtIndex(CMSampleBufferGetSampleAttachmentsArray(sampleBuffer, true), 0)), kCMSampleAttachmentKey_NotSync);
    // 判断当前帧是否为关键帧 通过是否有同步参数来判断
    // 获取sps & pps数据
    if (keyframe)
    {
        CMFormatDescriptionRef format = CMSampleBufferGetFormatDescription(sampleBuffer);
        size_t sparameterSetSize, sparameterSetCount;
        const uint8_t *sparameterSet;
        OSStatus statusCode = CMVideoFormatDescriptionGetH264ParameterSetAtIndex(format, 0, &sparameterSet, &sparameterSetSize, &sparameterSetCount, 0 );
        if (statusCode == noErr)
        {
            // Found sps and now check for pps
            size_t pparameterSetSize, pparameterSetCount;
            const uint8_t *pparameterSet;
            OSStatus statusCode = CMVideoFormatDescriptionGetH264ParameterSetAtIndex(format, 1, &pparameterSet, &pparameterSetSize, &pparameterSetCount, 0 );
            if (statusCode == noErr)
            {
                // Found pps
                NSData *sps = [NSData dataWithBytes:sparameterSet length:sparameterSetSize];
                NSData *pps = [NSData dataWithBytes:pparameterSet length:pparameterSetSize];
                if (encoder)
                {
                    [encoder gotSpsPps:sps pps:pps];
                }
            }
        }
    }
    
    CMBlockBufferRef dataBuffer = CMSampleBufferGetDataBuffer(sampleBuffer);
    size_t length, totalLength;
    char *dataPointer;
    OSStatus statusCodeRet = CMBlockBufferGetDataPointer(dataBuffer, 0, &length, &totalLength, &dataPointer);
    if (statusCodeRet == noErr)
    {
        size_t bufferOffset = 0;
        static const int AVCCHeaderLength = 4; // 返回的nalu数据前四个字节不是0001的startcode，而是大端模式的帧长度length
        
        // 循环获取nalu数据
        while (bufferOffset < totalLength - AVCCHeaderLength) {
            uint32_t NALUnitLength = 0;
            // Read the NAL unit length
            memcpy(&NALUnitLength, dataPointer + bufferOffset, AVCCHeaderLength);
            
            // 从大端转系统端
            NALUnitLength = CFSwapInt32BigToHost(NALUnitLength);
            
            NSData* data = [[NSData alloc] initWithBytes:(dataPointer + bufferOffset + AVCCHeaderLength) length:NALUnitLength];
            [encoder gotEncodedData:data isKeyFrame:keyframe];
            
            // Move to the next NAL unit in the block buffer
            bufferOffset += AVCCHeaderLength + NALUnitLength;
        }
    }
}
#pragma mark -关键帧的处理 写入 sps、pps（sequence parameters set 序列参数集 picture parameters set 图形参数集）
- (void)gotSpsPps:(NSData*)sps pps:(NSData*)pps
{
    NSLog(@"gotSpsPps %d %d", (int)[sps length], (int)[pps length]);
    const char bytes[] = "\x00\x00\x00\x01";
    size_t length = (sizeof bytes) - 1; //string literals have implicit trailing '\0'
    NSData *ByteHeader = [NSData dataWithBytes:bytes length:length];
    [writeFileHandle writeData:ByteHeader];
    [writeFileHandle writeData:sps];
    [writeFileHandle writeData:ByteHeader];
    [writeFileHandle writeData:pps];
    
}
#pragma mark -通用帧 写入
- (void)gotEncodedData:(NSData*)data isKeyFrame:(BOOL)isKeyFrame
{
    NSLog(@"gotEncodedData %d", (int)[data length]);
    if (writeFileHandle != NULL)
    {
        const char bytes[] = "\x00\x00\x00\x01";
        size_t length = (sizeof bytes) - 1; //string literals have implicit trailing '\0'
        NSData *ByteHeader = [NSData dataWithBytes:bytes length:length];
        [writeFileHandle writeData:ByteHeader];
        [writeFileHandle writeData:data];
    }
}


@end
