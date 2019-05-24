//
//  AudioManager.m
//  AudioDemo
//
//  Created by 朱志佳 on 2019/5/5.
//  Copyright © 2019 朱志佳. All rights reserved.
//

#import "AudioManager.h"
#import <AVFoundation/AVFoundation.h>
#import <AudioToolbox/AudioToolbox.h>
#import "ZHeader.h"

//AudioUnitElement
#define kOutputBus 0 //代表Element0 output数据  (Element1：数据 应用（application）到 输出设备（扬声器））【左边输入域 右边输出域】（0:output）
#define kInputBus 1 //代表Element1  input数据  （Element0：数据 输入设备（麦克风）到 应用（application））【左边输入域 右边输出域】 （1:input)

const uint32_t CONST_BUFFER_SIZES = 0x10000;

@interface AudioManager ()
{
    NSInputStream *inputSteam;
    AudioStreamBasicDescription audioFormat;//Describe format // 描述格式
    NSFileHandle *fileHandle;
}
@property (nonatomic,assign) AudioUnit audioUnit;//AudioComponentInstanceNew 中初始化
@property (nonatomic,assign) AudioBufferList *bufferList;//设置缓冲区大小
@property (nonatomic,strong) AVAudioSessionCategory audioSessionCategory;//模式1.播放 2.录制 3.播放并录制

@property (nonatomic,strong) NSMutableData *pcmData;

@end

@implementation AudioManager

SingleImplementation(manager)

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self initialze];
    }
    return self;
}

#pragma mark 初始化数据
-(void)initialze {
    self.pcmData = [NSMutableData new];
    self.audioSessionCategory = AVAudioSessionCategoryPlayAndRecord;
}

#pragma mark 初始化AudioUnit设置
/**
 1.描述音频元件（kAudioUnitType_Output／kAudioUnitSubType_RemoteIO ／kAudioUnitManufacturerApple）。
 2.使用 AudioComponentFindNext(NULL, &descriptionOfAudioComponent) 获得 AudioComponent。AudioComponent有点像生产 Audio Unit 的工厂。
 3.使用 AudioComponentInstanceNew(ourComponent, &audioUnit) 获得 Audio Unit 实例。
 4.使用 AudioUnitSetProperty函数为录制和回放开启IO。
 5.使用 AudioStreamBasicDescription 结构体描述音频格式，并使用AudioUnitSetProperty进行设置。
 6.使用 AudioUnitSetProperty 设置音频录制与放播的回调函数。
 7.分配缓冲区。
 8.初始化 Audio Unit。
 9.启动 Audio Unit。
 */
- (void)setupAudioUnit{
    
    //注意:此处代码必须设置
    //1、设置AVAudioSession 设置其功能(录制、回调、或者录制和回调)
    NSError *error = nil;
    [[AVAudioSession sharedInstance] setCategory:self.audioSessionCategory error:&error];//AVAudioSessionCategory 根据不同的值，来设置走不同的回调1.Record 只走录制回调 2.playback 只走播放回调 3.playAndRecord 录制和播放回调同时都走。
    [[AVAudioSession sharedInstance] setPreferredIOBufferDuration:0.022 error:&error];
    if (error) {
        NSLog(@"audiosession error is %@",error.localizedDescription);
        return;
    }
    
    if (self.audioSessionCategory == AVAudioSessionCategoryPlayAndRecord ||
        self.audioSessionCategory == AVAudioSessionCategoryRecord) {
        [self initWriteFileHandle];
    }
    
    //Audio Unit具体设置
    //2.初始化AudioComponentDescription，然后再调用AudioComponentFindNext得到AudioComponent，
    //最后调用AudioComponentInstanceNew初始化得到AudioUnit
    OSStatus status;
    
    //Describe audio component // 描述音频元件
    AudioComponentDescription desc;
    desc.componentType          = kAudioUnitType_Output;
    desc.componentSubType       = kAudioUnitSubType_RemoteIO;
    desc.componentFlags         = 0;
    desc.componentFlagsMask     = 0;
    desc.componentManufacturer  = kAudioUnitManufacturer_Apple;
    
    //Get component // 获得一个元件
    AudioComponent inputComponent = AudioComponentFindNext(NULL, &desc);
    
    //Get audio units // 获得 Audio Unit
    status = AudioComponentInstanceNew(inputComponent, &_audioUnit);
    checkStatus(status);
    
    //Enable IO for recording // 为录制打开 IO
    //1.设备（麦克风）输入数据到I/O Unit 和 4.I/O Unit输出数据到设备（扬声器）的数据格式
    UInt32 flag = 1;
    status = AudioUnitSetProperty(_audioUnit,
                                  kAudioOutputUnitProperty_EnableIO,
                                  kAudioUnitScope_Input,
                                  kInputBus,
                                  &flag,
                                  sizeof(flag));
    checkStatus(status);
    
    //Enable IO for playback // 为播放打开 IO
    status = AudioUnitSetProperty(_audioUnit,
                                  kAudioOutputUnitProperty_EnableIO,
                                  kAudioUnitScope_Output,
                                  kOutputBus,
                                  &flag,
                                  sizeof(flag));
    checkStatus(status);
    
    //Describe format // 描述格式
    memset(&audioFormat, 0, sizeof(audioFormat));
    audioFormat.mSampleRate         = 44100.00;//44.1KHz // 采样率
    audioFormat.mFormatID           = kAudioFormatLinearPCM;// PCM格式
    audioFormat.mFormatFlags        = kAudioFormatFlagIsSignedInteger;// 整形
    audioFormat.mFramesPerPacket    = 1;// 每个packet只有1帧
    audioFormat.mChannelsPerFrame   = 1;// 声道数
    audioFormat.mBitsPerChannel     = 16;// 位深
    audioFormat.mBytesPerFrame      = 2;// 每帧只有2个byte 声道*位深
    audioFormat.mBytesPerPacket     = 2;// 每个Packet只有2个byte 声道*位深*帧数
    [self printAudioStreamBasicDescription:audioFormat];
    
    //Application format // 设置应用处理音频的格式
    //2.I/O Unit输出数据到应用appliction 和
    status = AudioUnitSetProperty(_audioUnit,
                                  kAudioUnitProperty_StreamFormat,
                                  kAudioUnitScope_Output,
                                  kInputBus,
                                  &audioFormat,
                                  sizeof(audioFormat));
    checkStatus(status);
    
    status = AudioUnitSetProperty(_audioUnit,
                                  kAudioUnitProperty_StreamFormat,
                                  kAudioUnitScope_Input,
                                  kOutputBus,
                                  &audioFormat,
                                  sizeof(audioFormat));
    checkStatus(status);
    
    //set input callback // 设置数据采集回调函数
    AURenderCallbackStruct callbackStruct;
    callbackStruct.inputProc = recordingCallback;
    callbackStruct.inputProcRefCon = (__bridge void * _Nullable)self;
    status = AudioUnitSetProperty(_audioUnit,
                                  kAudioOutputUnitProperty_SetInputCallback,//用来设置回调
                                  kAudioUnitScope_Global,
                                  kInputBus,
                                  &callbackStruct,
                                  sizeof(callbackStruct));
    checkStatus(status);
    
    //set output callback // 设置声音输出回调函数。当speaker需要数据时就会调用回调函数去获取数据。它是 "拉" 数据的概念。
    callbackStruct.inputProc = playbackCallback;
    callbackStruct.inputProcRefCon = (__bridge void * _Nullable)self;
    status = AudioUnitSetProperty(_audioUnit,
                                  kAudioUnitProperty_SetRenderCallback,//用来设置回调
                                  kAudioUnitScope_Global,
                                  kOutputBus,
                                  &callbackStruct,
                                  sizeof(callbackStruct));
    checkStatus(status);
    
    //Disable buffer allocation for the recorder (optional - do this if we want to pass in our own) // 关闭为录制分配的缓冲区（我们想使用我们自己分配的）
    flag = 0;
    status = AudioUnitSetProperty(_audioUnit,
                                  kAudioUnitProperty_ShouldAllocateBuffer,
                                  kAudioUnitScope_Output,
                                  kInputBus,
                                  &flag,
                                  sizeof(flag));
    // TODO: Allocate our own buffers if we want
    //创建并设置缓冲区大小（成功开启录制时，创建缓冲区。关闭录制时，销毁缓冲区）
    uint32_t numberBuffers = 1;
    UInt32 bufferSize = CONST_BUFFER_SIZES;
    _bufferList = (AudioBufferList*)malloc(sizeof(AudioBufferList));
    _bufferList->mNumberBuffers = numberBuffers;
    _bufferList->mBuffers[0].mData = malloc(bufferSize);
    _bufferList->mBuffers[0].mDataByteSize = bufferSize;
    _bufferList->mBuffers[0].mNumberChannels = 1;
    
    // Initialise // 初始化
    //是初始化AudioUnit，需要在设置好absd之后调用；初始化是一个耗时的操作，需要分配buffer、申请系统资源等；
    status = AudioUnitInitialize(_audioUnit);
    checkStatus(status);
    
    // Initialise也可以用以下代码
    //    UInt32 category = kAudioSessionCategory_PlayAndRecord;
    //    status = AudioSessionSetProperty(kAudioSessionProperty_AudioCategory, sizeof(category), category);
    //    checkStatus(status);
    //    status = 0;
    //    status = AudioSessionSetActive(YES);
    //    checkStatus(status);
    //    status = AudioUnitInitialize(audioUnit);
    //    checkStatus(status);
}
// 检测状态
void checkStatus(OSStatus status){
    if (status != noErr) {
        printf("Error: %ld\n",(long)status);
    }
}

#pragma mark 处理 录制文件写入fileHandle
- (void)initWriteFileHandle
{
    NSString *audioFile = [CacheHelper pathForCommonFile:@"abc.pcm" withType:0];
    [[NSFileManager defaultManager] removeItemAtPath:audioFile error:nil];
    [[NSFileManager defaultManager] createFileAtPath:audioFile contents:nil attributes:nil];
    fileHandle = [NSFileHandle fileHandleForWritingAtPath:audioFile];
}
- (void)closeFileHandle
{
    [fileHandle closeFile];
    fileHandle = NULL;
}

#pragma mark 开启 Audio Unit
- (void)startWithAVAudioSessionCategory:(AVAudioSessionCategory)audioSessionCategory;
{
    self.audioSessionCategory = audioSessionCategory;
    [self start];
}
- (void)start {
    [self onStart];
    //When you are ready to start:
    [self setupAudioUnit];
    OSStatus status = AudioOutputUnitStart(self.audioUnit);
    checkStatus(status);
}
- (void)onStart
{
    NSString *file = [CacheHelper pathForCommonFile:@"abc.pcm" withType:0];
    if (![CacheHelper checkfile:file]) {
        file = [[NSBundle mainBundle] pathForResource:@"abc" ofType:@"pcm"];
    }
    inputSteam = [[NSInputStream alloc] initWithFileAtPath:file];
    if (!inputSteam) {
        NSLog(@"打开文件失败 %@", file);
    }
    else {
        [inputSteam open];
    }
}
#pragma mark 关闭 Audio Unit
- (void)stop {
    //And to stop:
    OSStatus status = AudioOutputUnitStop(self.audioUnit);
    checkStatus(status);
    
    if (self.bufferList != NULL) {
        if (self.bufferList->mBuffers[0].mData) {
            free(self.bufferList->mBuffers[0].mData);
            self.bufferList->mBuffers[0].mData = NULL;
        }
        free(self.bufferList);
        self.bufferList = NULL;
    }
    
    [self finished];//销毁

    [self onStop];
}
- (void)onStop{
    [inputSteam close];
    inputSteam = nil;
    
    if ([self.delegate respondsToSelector:@selector(onPlayToEnd:)]) {
        [self.delegate onPlayToEnd:self];
    }
    
    //[self writeFile:_pcmData];
    _pcmData = [NSMutableData new];//reset
    [self closeFileHandle];
}
#pragma mark 结束 Audio Unit
- (void)finished {
    AudioUnitUninitialize(self.audioUnit);
    AudioComponentInstanceDispose(self.audioUnit);
    self.audioUnit = nil;
}

#pragma mark 录制和播放回调
#pragma mark Recording Callback 录制回调
static OSStatus recordingCallback(void *inRefCon,
                                  AudioUnitRenderActionFlags *ioActionFlags,
                                  const AudioTimeStamp *inTimeStamp,
                                  UInt32 inBusNumber,
                                  UInt32 inNumberFrames,
                                  AudioBufferList *ioData) {
    // TODO:
    // 使用 inNumberFrames 计算有多少数据是有效的
    // 在 AudioBufferList 里存放着更多的有效空间
    
    AudioManager *self = (__bridge AudioManager*) inRefCon;
    NSLog(@"recordingCallback:size:%ld",(long)self.bufferList->mBuffers[0].mDataByteSize);
    if (inNumberFrames > 0) {
        
        self.bufferList->mNumberBuffers = 1;
        
        OSStatus status;
        status = AudioUnitRender(self.audioUnit,
                                 ioActionFlags,
                                 inTimeStamp,
                                 inBusNumber,
                                 inNumberFrames,
                                 self.bufferList);
        checkStatus(status);
        
        //录制的pcmData数据处理 //将录制的pcm数据写入文件中
        [self.pcmData appendBytes:self.bufferList->mBuffers[0].mData
                           length:self.bufferList->mBuffers[0].mDataByteSize];//1.直接追加到pcmdata中
        NSData *aPcmData = [NSData dataWithBytes:self.bufferList->mBuffers[0].mData length:self.bufferList->mBuffers[0].mDataByteSize];
        [self writeData:aPcmData];//2.直接追加到fileHandle指定的文件中
    }
    
    return noErr;
}

#pragma mark playback Callback 播放回调
static OSStatus playbackCallback(void *inRefCon,
                                 AudioUnitRenderActionFlags *ioActionFlags,
                                 const AudioTimeStamp *inTimeStamp,
                                 UInt32 inBusNumber,
                                 UInt32 inNumberFrames,
                                 AudioBufferList *ioData) {
    // Notes: ioData contains buffers (may be more than one!)
    // Fill them up as much as you can. Remember to set the size value in each buffer to match how
    // much data is in the buffer.
    // Notes: ioData 包括了一堆 buffers
    // 尽可能多的向ioData中填充数据，记得设置每个buffer的大小要与buffer匹配好。
    AudioManager *self = (__bridge AudioManager*) inRefCon;
    
    ioData->mBuffers[0].mDataByteSize = (UInt32)[self->inputSteam read:ioData->mBuffers[0].mData maxLength:(NSInteger)ioData->mBuffers[0].mDataByteSize];//从文件中读取pcm数据
    
    NSLog(@"playbackCallback:size:%ld",(long)ioData->mBuffers[0].mDataByteSize);
    
    if (ioData->mBuffers[0].mDataByteSize <= 0) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self stop];
        });
    }
    
    return noErr;
}


#pragma mark 音频相关的辅助功能 data写入到文件
- (void)writeFile:(NSData *)data {
    NSString *path = [CacheHelper pathForCommonFile:@"abc.pcm" withType:0];
    NSError *error = nil;
    [data writeToFile:path options:NSDataWritingAtomic error:&error];
    if (error) {
        NSLog(@"error:%@",error);
    }
}
- (void)writeData:(NSData *)aPcmData
{
    [fileHandle writeData:aPcmData];
}

#pragma mark 打印 printAudioStreamBasicDescription
- (void)printAudioStreamBasicDescription:(AudioStreamBasicDescription)asbd {
    char formatID[5];
    UInt32 mFormatID = CFSwapInt32HostToBig(asbd.mFormatID);
    bcopy (&mFormatID, formatID, 4);
    formatID[4] = '\0';
    printf("Sample Rate:         %10.0f\n",  asbd.mSampleRate);
    printf("Format ID:           %10s\n",    formatID);
    printf("Format Flags:        %10X\n",    (unsigned int)asbd.mFormatFlags);
    printf("Frames per Packet:   %10d\n",    (unsigned int)asbd.mFramesPerPacket);
    printf("Channels per Frame:  %10d\n",    (unsigned int)asbd.mChannelsPerFrame);
    printf("Bits per Channel:    %10d\n",    (unsigned int)asbd.mBitsPerChannel);
    printf("Bytes per Frame:     %10d\n",    (unsigned int)asbd.mBytesPerFrame);
    printf("Bytes per Packet:    %10d\n",    (unsigned int)asbd.mBytesPerPacket);

    printf("\n");
}

@end
