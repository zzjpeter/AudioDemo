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

#define kOutputBus 0
#define kInputBus 1
// Bus 0 is used for the output side, bus 1 is used to get audio input.

@interface AudioManager ()
{
    AudioUnit audioUnit;//setupAudioUnit 中的AudioComponentInstanceNew 中初始化
    AudioBufferList *bufferList;//setupAudioUnit 中初始化 设置缓冲区大小
    
    NSMutableData *pcmData;
}

@end

@implementation AudioManager

+(instancetype)sharedAudioManager {
    static AudioManager *shareAudioManager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shareAudioManager = [[AudioManager alloc] init];
    });
    return shareAudioManager;
}

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
    pcmData = [NSMutableData new];
}

#pragma mark 初始化AudioUnit设置
- (void)setupAudioUnit{
    
    NSError *error;
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayAndRecord error:&error];//AVAudioSessionCategory 根据不同的值，来设置走不同的回调1.Record 只走录制回调 2.playback 只走播放回调 3.playAndRecord 录制和播放回调同时都走。
    [[AVAudioSession sharedInstance] setPreferredIOBufferDuration:0.022 error:&error];
    if (error) {
        NSLog(@"audiosession error is %@",error.localizedDescription);
        return;
    }
    
    OSStatus status;
    //AudioComponentInstance audioUnit;
    
    //Describe audio component // 描述音频元件
    AudioComponentDescription desc;
    desc.componentType = kAudioUnitType_Output;
    desc.componentSubType = kAudioUnitSubType_RemoteIO;
    desc.componentFlags = 0;
    desc.componentFlagsMask = 0;
    desc.componentManufacturer = kAudioUnitManufacturer_Apple;
    
    //Get component // 获得一个元件
    AudioComponent inputComponent = AudioComponentFindNext(NULL, &desc);
    
    //Get audio units // 获得 Audio Unit
    status = AudioComponentInstanceNew(inputComponent, &audioUnit);
    checkStatus(status);
    
    //Enable IO for recording // 为录制打开 IO
    UInt32 flag = 1;
    status = AudioUnitSetProperty(audioUnit,
                                  kAudioOutputUnitProperty_EnableIO,
                                  kAudioUnitScope_Input,
                                  kInputBus,
                                  &flag,
                                  sizeof(flag));
    checkStatus(status);
    
    //Enable IO for playback // 为播放打开 IO
    status = AudioUnitSetProperty(audioUnit,
                                  kAudioOutputUnitProperty_EnableIO,
                                  kAudioUnitScope_Output,
                                  kOutputBus,
                                  &flag,
                                  sizeof(flag));
    checkStatus(status);
    
    //Describe format // 描述格式
    AudioStreamBasicDescription audioFormat;
    audioFormat.mSampleRate = 44100.00;//44.1KHz
    audioFormat.mFormatID = kAudioFormatLinearPCM;
    audioFormat.mFormatFlags = kAudioFormatFlagIsSignedInteger;
    audioFormat.mFramesPerPacket = 1;
    audioFormat.mChannelsPerFrame = 1;
    audioFormat.mBitsPerChannel = 16;
    audioFormat.mBytesPerPacket = 2;
    audioFormat.mBytesPerFrame = 2;
    
    //Apply format // 设置格式
    status = AudioUnitSetProperty(audioUnit,
                                  kAudioUnitProperty_StreamFormat,
                                  kAudioUnitScope_Output,
                                  kInputBus,
                                  &audioFormat,
                                  sizeof(audioFormat));
    checkStatus(status);
    
    status = AudioUnitSetProperty(audioUnit,
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
    status = AudioUnitSetProperty(audioUnit,
                                  kAudioOutputUnitProperty_SetInputCallback,
                                  kAudioUnitScope_Global,
                                  kInputBus,
                                  &callbackStruct,
                                  sizeof(callbackStruct));
    checkStatus(status);
    
    //set output callback // 设置声音输出回调函数。当speaker需要数据时就会调用回调函数去获取数据。它是 "拉" 数据的概念。
    callbackStruct.inputProc = playbackCallback;
    callbackStruct.inputProcRefCon = (__bridge void * _Nullable)self;
    status = AudioUnitSetProperty(audioUnit,
                                  kAudioUnitProperty_SetRenderCallback,
                                  kAudioUnitScope_Global,
                                  kOutputBus,
                                  &callbackStruct,
                                  sizeof(callbackStruct));
    checkStatus(status);
    
    //Disable buffer allocation for the recorder (optional - do this if we want to pass in our own) // 关闭为录制分配的缓冲区（我们想使用我们自己分配的）
    flag = 0;
    status = AudioUnitSetProperty(audioUnit,
                                  kAudioUnitProperty_ShouldAllocateBuffer,
                                  kAudioUnitScope_Output,
                                  kInputBus,
                                  &flag,
                                  sizeof(flag));
    // TODO: Allocate our own buffers if we want
    
    // Initialise // 初始化
    status = AudioUnitInitialize(audioUnit);
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
    
    //创建并设置缓冲区大小（成功开启录制时，创建缓冲区。关闭录制时，销毁缓冲区）
    uint32_t numberBuffers = 1;
    UInt32 bufferSize = 2048;
    bufferList = (AudioBufferList*)malloc(sizeof(AudioBufferList));
    bufferList->mNumberBuffers = numberBuffers;
    bufferList->mBuffers[0].mData = malloc(bufferSize);
    bufferList->mBuffers[0].mDataByteSize = bufferSize;
    bufferList->mBuffers[0].mNumberChannels = 1;
}

void checkStatus(OSStatus status){
    if (status != noErr) {
        printf("Error: %d\n",status);
    }
}

#pragma mark Recording Callback 录制回调
static OSStatus recordingCallback(void *inRefCon,
                                  AudioUnitRenderActionFlags *ioActionFlags,
                                  const AudioTimeStamp *inTimeStamp,  
                                  UInt32 inBusNumber,
                                  UInt32 inNumberFrames,
                                  AudioBufferList *ioData) {
    printf("recordingCallback\n");
    // TODO:
    // 使用 inNumberFrames 计算有多少数据是有效的
    // 在 AudioBufferList 里存放着更多的有效空间
    
    AudioManager *self = (__bridge AudioManager*) inRefCon;
    if (inNumberFrames > 0) {
        
        self->bufferList->mNumberBuffers = 1;
        
        OSStatus status;
        status = AudioUnitRender(self->audioUnit,
                                 ioActionFlags,
                                 inTimeStamp,
                                 inBusNumber,
                                 inNumberFrames,
                                 self->bufferList);
        checkStatus(status);
        
        [self->pcmData appendBytes:self->bufferList->mBuffers[0].mData
                            length:self->bufferList->mBuffers[0].mDataByteSize];
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
    printf("playbackCallback\n");
    // Notes: ioData contains buffers (may be more than one!)
    // Fill them up as much as you can. Remember to set the size value in each buffer to match how
    // much data is in the buffer.
    // Notes: ioData 包括了一堆 buffers
    // 尽可能多的向ioData中填充数据，记得设置每个buffer的大小要与buffer匹配好。
    //AudioManager *self = (__bridge AudioManager*) inRefCon;
    
    return noErr;
}

- (void)startRecoder {
    //When you are ready to start:
    [self setupAudioUnit];
    OSStatus status = AudioOutputUnitStart(audioUnit);
    checkStatus(status);
}

- (void)stopRecoder {
    //And to stop:
    OSStatus status = AudioOutputUnitStop(audioUnit);
    checkStatus(status);
    AudioUnitUninitialize(audioUnit);
    
    if (bufferList != NULL) {
        if (bufferList->mBuffers[0].mData) {
            free(bufferList->mBuffers[0].mData);
            bufferList->mBuffers[0].mData = NULL;
        }
        free(bufferList);
        bufferList = NULL;
    }
    
    [self dispose];//销毁
    
    [self writeFile:self->pcmData];
}

- (void)dispose {
    AudioComponentInstanceDispose(audioUnit);
}

#pragma mark 音频相关的辅助功能
- (NSString *)createFilePath {
    NSString *folderPath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject] stringByAppendingPathComponent:@"wav"];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error;
    if (![fileManager fileExistsAtPath:folderPath]) {
        [fileManager createDirectoryAtPath:folderPath withIntermediateDirectories:YES attributes:nil error:&error];
    }
    
    NSString *filePath = [folderPath stringByAppendingPathComponent:@"recoder.pcm"];
    [fileManager createFileAtPath:filePath contents:nil attributes:nil];
    NSLog(@"filePath is %@",filePath);
    return filePath;
}

- (void)writeFile:(NSData *)data {
    NSString *path = [self createFilePath];
    [data writeToFile:path options:NSDataWritingAtomic error:nil];
}

@end
