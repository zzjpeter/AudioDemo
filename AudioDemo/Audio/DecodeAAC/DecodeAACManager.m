//
//  DecodeAACManager.m
//  AudioDemo
//
//  Created by 朱志佳 on 2019/5/23.
//  Copyright © 2019 朱志佳. All rights reserved.
//

#import "DecodeAACManager.h"

const uint32_t CONST_BUFFER_COUNT = 3;
const uint32_t CONST_BUFFER_SIZE = 0x10000;

@interface DecodeAACManager ()
{
    AudioFileID audioFileID; // An opaque data type that represents an audio file object.
    AudioStreamBasicDescription audioStreamBasicDescrpition; // An audio data format specification for a stream of audio
    AudioStreamPacketDescription *audioStreamPacketDescrption; // Describes one packet in a buffer of audio data where the sizes of the packets differ or where there is non-audio data between audio packets.
    
    AudioQueueRef audioQueue; // Defines an opaque data type that represents an audio queue.
    AudioQueueBufferRef audioBuffers[CONST_BUFFER_COUNT];
    
    SInt64 readedPacket; //参数类型
    u_int32_t packetNums;
    
}
@property (nonatomic , strong) CADisplayLink *mDispalyLink;

@end

@implementation DecodeAACManager

SingleImplementation(manager)

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.mDispalyLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(updateFrame)];
        self.mDispalyLink.frameInterval = 5; // 默认是30FPS的帧率录制
        [self.mDispalyLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
        [self.mDispalyLink setPaused:YES];
    }
    return self;
}

#pragma mark public
- (void)start
{
    [self onStart];
    [self.mDispalyLink setPaused:NO];
}
- (void)stop
{
    [self onEnd];
    [self.mDispalyLink setPaused:YES];
}

#pragma makr private
- (void)onStart {
    [self customAudioConfig];
    AudioQueueSetParameter(audioQueue, kAudioQueueParam_Volume, 1.0); // Sets a playback audio queue parameter value.
    AudioQueueStart(audioQueue, NULL); // Begins playing or recording audio.
}

- (void)onEnd {
    AudioQueueStop(audioQueue, YES);
}

- (void)updateFrame {
    if (self.currentPlayTime) {
        self.currentPlayTime([self getCurrentTime]);
    }
}

#pragma mark 解码
- (void)customAudioConfig {
    
    NSURL *url = [NSURL URLWithString:self.file];
    
    OSStatus status = AudioFileOpenURL((__bridge CFURLRef)url, kAudioFileReadPermission, 0, &audioFileID); //Open an existing audio file specified by a URL.
    if (status != noErr) {
        NSLog(@"打开文件失败 %@", url);
        return ;
    }
    uint32_t size = sizeof(audioStreamBasicDescrpition);
    status = AudioFileGetProperty(audioFileID, kAudioFilePropertyDataFormat, &size, &audioStreamBasicDescrpition); // Gets the value of an audio file property.
    NSAssert(status == noErr, @"error");
    
    status = AudioQueueNewOutput(&audioStreamBasicDescrpition, bufferReady, (__bridge void * _Nullable)(self), NULL, NULL, 0, &audioQueue); // Creates a new playback audio queue object.
    NSAssert(status == noErr, @"error");
    
    if (audioStreamBasicDescrpition.mBytesPerPacket == 0 || audioStreamBasicDescrpition.mFramesPerPacket == 0) {
        uint32_t maxSize;
        size = sizeof(maxSize);
        AudioFileGetProperty(audioFileID, kAudioFilePropertyPacketSizeUpperBound, &size, &maxSize); // The theoretical maximum packet size in the file.
        if (maxSize > CONST_BUFFER_SIZE) {
            maxSize = CONST_BUFFER_SIZE;
        }
        packetNums = CONST_BUFFER_SIZE / maxSize;
        audioStreamPacketDescrption = malloc(sizeof(AudioStreamPacketDescription) * packetNums);
    }
    else {
        packetNums = CONST_BUFFER_SIZE / audioStreamBasicDescrpition.mBytesPerPacket;
        audioStreamPacketDescrption = nil;
    }
    
    char cookies[100];
    memset(cookies, 0, sizeof(cookies));
    // 这里的100 有问题
    AudioFileGetProperty(audioFileID, kAudioFilePropertyMagicCookieData, &size, cookies); // Some file types require that a magic cookie be provided before packets can be written to an audio file.
    if (size > 0) {
        AudioQueueSetProperty(audioQueue, kAudioQueueProperty_MagicCookie, cookies, size); // Sets an audio queue property value.
    }
    
    readedPacket = 0;
    for (int i = 0; i < CONST_BUFFER_COUNT; ++i) {
        AudioQueueAllocateBuffer(audioQueue, CONST_BUFFER_SIZE, &audioBuffers[i]); // Asks an audio queue object to allocate an audio queue buffer.
        if ([self fillBuffer:audioBuffers[i]]) {
            // full
            break;
        }
        NSLog(@"buffer%d full", i);
    }
}

#pragma mark fileUrl 文件路径
- (NSString *)file
{
    if (!_file) {
        NSString *file = [CacheHelper pathForCommonFile:@"abc.aac" withType:0];
        if (![CacheHelper checkfile:file]) {
            file = [[NSBundle mainBundle] pathForResource:@"abc" ofType:@"aac"];
        }
        _file = file;
    }
    return _file;
}

#pragma mark -解码回调
void bufferReady(void *inUserData,AudioQueueRef inAQ,
                 AudioQueueBufferRef buffer){
    NSLog(@"refresh buffer");
    DecodeAACManager* decoder = (__bridge DecodeAACManager *)inUserData;
    if (!decoder) {
        NSLog(@"decoder nil");
        return ;
    }
    if ([decoder fillBuffer:buffer]) {
        NSLog(@"decoder end");
    }
    
}

- (bool)fillBuffer:(AudioQueueBufferRef)buffer {
    bool full = NO;
    uint32_t bytes = 0, packets = (uint32_t)packetNums;
    OSStatus status = AudioFileReadPackets(audioFileID, NO, &bytes, audioStreamPacketDescrption, readedPacket, &packets, buffer->mAudioData); // Reads packets of audio data from an audio file.
    
    NSAssert(status == noErr, ([NSString stringWithFormat:@"error status %d", status]) );
    if (packets > 0) {
        buffer->mAudioDataByteSize = bytes;
        AudioQueueEnqueueBuffer(audioQueue, buffer, packets, audioStreamPacketDescrption);
        readedPacket += packets;
    }
    else {
        AudioQueueStop(audioQueue, NO);
        full = YES;
    }
    
    return full;
}

#pragma mark 获取当前播放时间 单位s
- (double)getCurrentTime {
    Float64 timeInterval = 0.0;
    if (audioQueue) {
        AudioQueueTimelineRef timeLine;
        AudioTimeStamp timeStamp;
        OSStatus status = AudioQueueCreateTimeline(audioQueue, &timeLine); // Creates a timeline object for an audio queue.
        if(status == noErr)
        {
            AudioQueueGetCurrentTime(audioQueue, timeLine, &timeStamp, NULL); // Gets the current audio queue time.
            timeInterval = timeStamp.mSampleTime * 1000000 / audioStreamBasicDescrpition.mSampleRate; // The number of sample frames per second of the data in the stream.
        }
    }
    return timeInterval;
}

#pragma mark iOS系统音效 播放短音乐 与解码播放音乐无关
/*
 简单来说，音频可以分为2种
 （1）音效
 又称“短音频”，通常在程序中的播放时长为1~2秒
 在应用程序中起到点缀效果，提升整体用户体验
 （2）音乐
 　　比如游戏中的“背景音乐”，一般播放时间较长
 
 二、音效的播放
 
 1.获得音效文件的路径
 
 　　NSURL *url = [[NSBundle mainBundle] URLForResource:@"m_03.wav" withExtension:nil];
 
 2.加载音效文件，得到对应的音效ID
 
 　　SystemSoundID soundID = 0;
 
 　　AudioServicesCreateSystemSoundID((__bridge CFURLRef)(url), &soundID);
 
 3.播放音效
 
 　　AudioServicesPlaySystemSound(soundID);
 
 注意：音效文件只需要加载1次
 
 4.音效播放常见函数总结
 
 加载音效文件
 
 　　AudioServicesCreateSystemSoundID(CFURLRef inFileURL, SystemSoundID *outSystemSoundID)
 
 释放音效资源
 
 　　AudioServicesDisposeSystemSoundID(SystemSoundID inSystemSoundID)
 
 播放音效
 
 　　AudioServicesPlaySystemSound(SystemSoundID inSystemSoundID)
 
 播放音效带点震动
 
 　　AudioServicesPlayAlertSound(SystemSoundID inSystemSoundID)
 */
- (void)play{
    NSString *audioFile = [CacheHelper pathForCommonFile:@"abc.aac" withType:0];
    if (![CacheHelper checkfile:audioFile]) {
        audioFile = [[NSBundle mainBundle] pathForResource:@"abc" ofType:@"aac"];
    }
    audioFile = [[NSBundle mainBundle] pathForResource:@"abc" ofType:@"aac"];
    NSURL *audioURL = [NSURL URLWithString:audioFile];
    SystemSoundID soundID;
    //Creates a system sound object.
    AudioServicesCreateSystemSoundID((__bridge CFURLRef)(audioURL), &soundID);
    //2.加载音效文件，创建音效ID（SoundID,一个ID对应一个音效文件）
    //Registers a callback function that is invoked when a specified system sound finishes playing.
    AudioServicesAddSystemSoundCompletion(soundID, NULL, NULL, &playCallback, (__bridge void * _Nullable)(self));
    
    AudioServicesPlayAlertSound(soundID);
    //AudioServicesPlaySystemSound(soundID);
    NSLog(@"音效soundID:%ld",(long)soundID);
}
void playCallback(SystemSoundID ID, void  * clientData){
    DecodeAACManager* manager = (__bridge DecodeAACManager *)clientData;
    NSLog(@"音效播放音乐完成回调 音效soundID:%ld",(long)ID);
    //把需要销毁的音效文件的ID传递给它 即可销毁
    AudioServicesDisposeSystemSoundID(ID);
}

@end
