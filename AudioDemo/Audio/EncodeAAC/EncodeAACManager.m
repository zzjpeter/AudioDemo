//
//  EncodeAACManager.m
//  AudioDemo
//
//  Created by 朱志佳 on 2019/5/23.
//  Copyright © 2019 朱志佳. All rights reserved.
//

#import "EncodeAACManager.h"
#import "AACEncoder.h"

@interface EncodeAACManager ()<AVCaptureAudioDataOutputSampleBufferDelegate>
{
    dispatch_queue_t mCaptureQueue;
    dispatch_queue_t mEncodeQueue;
    NSFileHandle *audioFileHandle;
}
@property (nonatomic , strong) AVCaptureSession *mCaptureSession; //负责输入和输出设备之间的数据传递
@property (nonatomic , strong) AVCaptureDeviceInput *mCaptureAudioDeviceInput;//负责从AVCaptureDevice获得输入数据
@property (nonatomic , strong) AVCaptureAudioDataOutput *mCaptureAudioOutput;

@property (nonatomic , strong) AACEncoder *mAudioEncoder;

@end

@implementation EncodeAACManager

SingleImplementation(manager)

#pragma mark public
- (void)start
{
    if (self.mCaptureSession.running ) {
        [self stop];
    }
    [self startCapture];
}
- (void)stop
{
    [self stopCapture];
}

- (void)startCapture
{
    self.mCaptureSession = [[AVCaptureSession alloc] init];
    
    mCaptureQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    mEncodeQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    
    AVCaptureDevice *audioDevice = [[AVCaptureDevice devicesWithMediaType:AVMediaTypeAudio] lastObject];
    self.mCaptureAudioDeviceInput = [[AVCaptureDeviceInput alloc] initWithDevice:audioDevice error:nil];
    if ([self.mCaptureSession canAddInput:self.mCaptureAudioDeviceInput]) {
        [self.mCaptureSession addInput:self.mCaptureAudioDeviceInput];
    }
    
    self.mCaptureAudioOutput = [[AVCaptureAudioDataOutput alloc] init];
    if ([self.mCaptureSession canAddOutput:self.mCaptureAudioOutput]) {
        [self.mCaptureSession addOutput:self.mCaptureAudioOutput];
    }
    [self.mCaptureAudioOutput setSampleBufferDelegate:self queue:mCaptureQueue];
    
    NSString *audioFile = [CacheHelper pathForCommonFile:@"abc.aac" withType:0];
    [[NSFileManager defaultManager] removeItemAtPath:audioFile error:nil];
    [[NSFileManager defaultManager] createFileAtPath:audioFile contents:nil attributes:nil];
    audioFileHandle = [NSFileHandle fileHandleForWritingAtPath:audioFile];
    
    [self.mCaptureSession startRunning];
}

- (void)stopCapture {
    [self.mCaptureSession stopRunning];
    [audioFileHandle closeFile];
    audioFileHandle = NULL;
}

- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection
{
    {
        dispatch_sync(mEncodeQueue, ^{
            [self.mAudioEncoder encodeSampleBuffer:sampleBuffer completionBlock:^(NSData *encodedData, NSError *error) {
                [self->audioFileHandle writeData:encodedData];
            }];
        });
    }
}

- (AACEncoder *)mAudioEncoder
{
    if (!_mAudioEncoder) {
        _mAudioEncoder = [[AACEncoder alloc] init];
    }
    return _mAudioEncoder;
}

@end
