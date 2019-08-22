//
//  FFmpegMovieManager.m
//  AudioDemo
//
//  Created by 朱志佳 on 2019/6/4.
//  Copyright © 2019 朱志佳. All rights reserved.
//

#import "FFmpegMovieManager.h"
#include <libavcodec/avcodec.h>
#include <libavformat/avformat.h>
#include <libswscale/swscale.h>

@interface FFmpegMovieManager ()
{
    AVFormatContext      *formatCtx;
    AVCodecContext       *codecCtx;
    AVFrame              *frame;
    AVStream             *stream;
    AVPacket             packet;
    AVPicture            picture;
    int                  videoStream;
    double               fps;
    BOOL                 isReleaseResources;
    CVPixelBufferPoolRef pixelBufferPool;
}

@end

@implementation FFmpegMovieManager

SingleImplementation(manager);

- (instancetype)init
{
    self = [super init];
    if (self) {
    
    }
    return self;
}
- (void)restart
{
    [self startWithPath:self.file];
}
- (void)startWithPath:(NSString *)file
{
    [self stop];
    
    self.file = file;
    [self start];
}
- (void)start
{
    [self setupDecoder:[self.file UTF8String]];
}
- (void)stop
{
    if (!isReleaseResources) {
        [self releaseResources];
    }
}

#pragma mark 初始化
- (BOOL)setupDecoder:(const char *)filePath
{
    isReleaseResources = NO;
    AVCodec *pCodec;
    // 注册所有解码器
    avcodec_register_all();
    av_register_all();
    avformat_network_init();
    // 打开视频文件
    if (avformat_open_input(&formatCtx, filePath, NULL, NULL) != 0) {
        NSLog(@"打开文件失败");
        goto initError;
    }
    // 检查数据流
    if (avformat_find_stream_info(formatCtx, NULL) < 0) {
        NSLog(@"检查数据流失败");
        goto initError;
    }
    // 根据数据流,找到第一个视频流
    if ((videoStream = av_find_best_stream(formatCtx, AVMEDIA_TYPE_VIDEO, -1, -1, &pCodec, 0)) < 0) {
        NSLog(@"没有找到第一个视频流");
        goto initError;
    }
    // 获取视频流的编解码上下文的指针
    stream = formatCtx->streams[videoStream];
    codecCtx = stream->codec;
#if DEBUG
    // 打印视频流的详细信息
    av_dump_format(formatCtx, videoStream, filePath, 0);
#endif
    if (stream->avg_frame_rate.den && stream->avg_frame_rate.num) {
        fps = av_q2d(stream->avg_frame_rate);
    }else{
        fps = 30;
    }
    // 查找解码器
    pCodec = avcodec_find_decoder(codecCtx->codec_id);
    if (pCodec == NULL) {
        NSLog(@"没有找到解码器");
        goto initError;
    }
    // 打开解码器
    if (avcodec_open2(codecCtx, pCodec, NULL) < 0) {
        NSLog(@"打开解码器失败");
        goto initError;
    }
    // 分配视频帧
    frame = av_frame_alloc();
    _outputWidth = codecCtx->width;
    _outputHeight = codecCtx->height;
    return YES;
initError:
    return NO;
}

- (void)seekTime:(double)seconds
{
    AVRational timeBase = formatCtx->streams[videoStream]->time_base;
    int64_t targetFrame = (int64_t)((double)timeBase.den / timeBase.num * seconds);
    avformat_seek_file(formatCtx, videoStream, 0, targetFrame, targetFrame, AVSEEK_FLAG_FRAME);
    avcodec_flush_buffers(codecCtx);
}
#pragma mark read next Frame
- (BOOL)stepFrame
{
    int frameFinished = 0;
    while (!frameFinished && av_read_frame(formatCtx, &packet) >= 0) {
        if (packet.stream_index == videoStream) {
            avcodec_decode_video2(codecCtx, frame, &frameFinished, &packet);
        }
    }
    if (frameFinished == 0 && isReleaseResources == NO) {
        [self releaseResources];
    }
    return frameFinished != 0;
}



#pragma mark 释放资源
- (void)releaseResources {
    NSLog(@"%@##%@",NSStringFromClass([self class]),NSStringFromSelector(_cmd));;
    //    SJLogFunc
    isReleaseResources = YES;
    // 释放RGB
    avpicture_free(&picture);
    // 释放frame
    av_packet_unref(&packet);
    // 释放YUV frame
    av_free(frame);
    // 关闭解码器
    if (codecCtx) avcodec_close(codecCtx);
    // 关闭文件
    if (formatCtx) avformat_close_input(&formatCtx);
    avformat_network_deinit();
}

#pragma mark fileUrl 文件路径处理
- (NSString *)file
{
    if (!_file) {
        NSString *file = [CacheHelper pathForCommonFile:@"test.mov" withType:0];
        if (![CacheHelper checkFileExist:file]) {
            file = [[NSBundle mainBundle] pathForResource:@"test.mov" ofType:nil];
        }
        _file = file;
    }
    return _file;
}

#pragma mark setter/getter
- (void)setOutputWidth:(int)outputWidth
{
    _outputWidth = outputWidth;
}
- (void)setOutputHeight:(int)outputHeight
{
    _outputHeight = outputHeight;
}
- (UIImage *)currentImage
{
    if (!frame->data[0]) {
        return nil;
    }
    return [self imageFromAVPicture];
}
- (double)duration
{
    return (double)formatCtx->duration / AV_TIME_BASE;
}
- (double)currentTime
{
    AVRational timeBase = formatCtx->streams[videoStream]->time_base;
    return packet.pts * (double)timeBase.num / timeBase.den;
}
- (int)sourceWidth
{
    return codecCtx->width;
}
- (int)sourceHeight
{
    return codecCtx->height;
}
- (double)fps
{
    return fps;
}
- (uint8_t *)getYUVdata
{
    return frame->data[0];
}
#pragma mark image From AVPicture from AVFrame
- (UIImage *)imageFromAVPicture
{
    UIImage *image = nil;
    avpicture_free(&picture);
    avpicture_alloc(&picture, AV_PIX_FMT_RGB24, _outputWidth, _outputHeight);
    struct SwsContext *imgConvertCtx = sws_getContext(
                                                      frame->width,
                                                      frame->height,
                                                      AV_PIX_FMT_YUV420P,
                                                      _outputWidth,
                                                      _outputHeight,
                                                      AV_PIX_FMT_RGB24,
                                                      SWS_FAST_BILINEAR,
                                                      NULL,
                                                      NULL,
                                                      NULL);
    if (imgConvertCtx == nil) {
        return nil;
    }
    sws_scale(imgConvertCtx,
              frame->data,
              frame->linesize,
              0,
              frame->height,
              picture.data,
              picture.linesize);
    sws_freeContext(imgConvertCtx);
    
    CGBitmapInfo bitmapInfo = kCGBitmapByteOrderDefault;
    CFDataRef data = CFDataCreate(kCFAllocatorDefault,
                                  picture.data[0],
                                  picture.linesize[0] * _outputHeight);
    CGDataProviderRef provider = CGDataProviderCreateWithCFData(data);
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGImageRef cgImage = CGImageCreate(_outputWidth,
                                       _outputWidth,
                                       8,
                                       24,
                                       picture.linesize[0],
                                       colorSpace,
                                       bitmapInfo,
                                       provider,
                                       NULL,
                                       NO,
                                       kCGRenderingIntentDefault);
    image = [UIImage imageWithCGImage:cgImage];
    CGImageRelease(cgImage);
    CGColorSpaceRelease(colorSpace);
    CGDataProviderRelease(provider);
    CFRelease(data);
    
    return image;
}
#pragma mark CVPixelBufferRef  from AVFrame
- (CVPixelBufferRef)getCurrentCVPixelBuffer
{
    AVFrame *frame = self->frame;
    if (!frame || !frame->data[0]) {
        return nil;
    }
    
    CVReturn theError;
    if (!pixelBufferPool) {
        NSDictionary *attributes = @{
                                     (id)kCVPixelBufferPixelFormatTypeKey : @(kCVPixelFormatType_420YpCbCr8BiPlanarFullRange),
                                     (id)kCVPixelBufferWidthKey : @(frame->width),
                                     (id)kCVPixelBufferHeightKey : @(frame->height),
                                     (id)kCVPixelBufferBytesPerRowAlignmentKey : @(frame->linesize[0]),
                                     (id)kCVPixelBufferIOSurfacePropertiesKey : [NSDictionary dictionary],
                                     };
        theError = CVPixelBufferPoolCreate(kCFAllocatorDefault, NULL, (__bridge CFDictionaryRef)attributes, &pixelBufferPool);
        if (theError != kCVReturnSuccess){
            NSLog(@"CVPixelBufferPoolCreate Failed");
        }
    }
    
    CVPixelBufferRef pixelBuffer = nil;
    theError = CVPixelBufferPoolCreatePixelBuffer(NULL, pixelBufferPool, &pixelBuffer);
    if(theError != kCVReturnSuccess){
        NSLog(@"CVPixelBufferPoolCreatePixelBuffer Failed");
    }
    CVBufferSetAttachment(pixelBuffer, kCVImageBufferYCbCrMatrix_ITU_R_601_4, kCVImageBufferYCbCrMatrixKey, kCVAttachmentMode_ShouldPropagate);
    
    @autoreleasepool {
        CVPixelBufferLockBaseAddress(pixelBuffer, 0);
        size_t bytePerRowY = CVPixelBufferGetBytesPerRowOfPlane(pixelBuffer, 0);
        size_t bytesPerRowUV = CVPixelBufferGetBytesPerRowOfPlane(pixelBuffer, 1);
        void *base = CVPixelBufferGetBaseAddressOfPlane(pixelBuffer, 0);
        memcpy(base, frame->data[0], bytePerRowY * frame->height);
        base = CVPixelBufferGetBaseAddressOfPlane(pixelBuffer, 1);
        //    memcpy(base, frame->data[1], bytesPerRowUV * frame->height / 2);
        NSLog(@"base:%p",base);
        uint32_t size = frame->linesize[1] * frame->height;
        uint8_t * dstData = malloc(2 * size);
        for (int i = 0; i < 2 * size; i++) {
            if (i % 2 == 0) {
                dstData[i] = frame->data[1][i/2];
            }else{
                dstData[i] = frame->data[2][i/2];
            }
        }
        memcpy(base, dstData, bytesPerRowUV * frame->height / 2);
        free(dstData);
        /*
         这里的前提是AVFrame中yuv的格式是nv12；
         但如果AVFrame是yuv420p，就需要把frame->data[1]和frame->data[2]的每一个字节交叉存储到pixelBUffer的plane1上，即把原来的uuuu和vvvv，保存成uvuvuvuv
         */
        CVPixelBufferUnlockBaseAddress(pixelBuffer, 0);
    }
    
    return pixelBuffer;
}

@end
