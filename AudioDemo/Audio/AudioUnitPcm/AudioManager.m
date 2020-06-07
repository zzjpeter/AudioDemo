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
#define NO_MORE_DATA (-12306)

static const uint32_t CONST_BUFFER_SIZES = 0x10000;//65536 = 16^4 = (2^4)^4

@interface AudioManager ()
{
    OSStatus status;//状态
    NSInputStream *inputSteam;//从文件中读取音频数据播放
    AudioStreamBasicDescription audioOutputFormat;//Describe format // 描述格式
    NSFileHandle *fileWriteHandle;//写入录制的音频数据
    NSFileHandle *fileConverterWriteHandle;//写入读取的音频数据 转换格式后 文件句柄
    
    //auido decoder
    AudioFileID audioFileID;
    AudioStreamBasicDescription audioInputFormat;//从文件中获取
    AudioStreamPacketDescription *audioInputPacketFormat;
    SInt64 readedPacket; // 已读的packet数量
    UInt64 packetNums; // 总的packet数量
    UInt64 packetNumsInBuffer; // buffer中最多的buffer数量
    Byte *convertBuffer;
    AudioConverterRef audioConverter;
    
    //auido decoder 通过 ExtAudioFileRef实现
    ExtAudioFileRef exAudioFile;
    SInt64 readedFrame; // 已读的frame数量
    UInt64 totalFrame; // 总的Frame数量
}
@property (nonatomic,assign) AudioUnit audioUnit;//AudioComponentInstanceNew 中初始化
@property (nonatomic,assign) AudioBufferList *bufferList;//设置录制缓冲区大小
@property (nonatomic,strong) AVAudioSessionCategory audioSessionCategory;//模式1.播放 2.录制 3.播放并录制
@property (nonatomic,assign) AudioBufferList *playBufferList;//设置播放缓冲区大小

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
- (void)setupAudioUnit{
    
    status = noErr;
    
    BOOL isPlay = NO;//是否播放
    AVAudioSessionCategory audioSessionCategory = self.audioSessionCategory;//类型本质是字符串
    
    if (audioSessionCategory == AVAudioSessionCategoryPlayAndRecord ||
        audioSessionCategory == AVAudioSessionCategoryPlayback) {
        if (![CacheHelper checkFileExist:self.file]) {
            NSLog(@"播放文件不存在");
            return;
        }
    }
    
    if (audioSessionCategory == AVAudioSessionCategoryPlayAndRecord) {
        isPlay = YES;
        [self initReadFileHandle];
        [self initWriteFileHandle];
    }else if (audioSessionCategory == AVAudioSessionCategoryPlayback){
        isPlay = YES;
        [self initReadFileHandle];
    }else if (audioSessionCategory == AVAudioSessionCategoryRecord){
        [self initWriteFileHandle];
    }
    
    NSLog(@"file:%@",self.file);
    NSLog(@"writeFile:%@",self.writeFile);
    NSLog(@"ConvertFile:%@",self.convertFile);
    
    [self printType];
    
    [self setupAudioUnitBase];
}

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
- (void)setupAudioUnitBase{
    
    status = noErr;
    
    //1.注意:此处代码必须设置 AVAudioSessionCategory
    if(![self settingAVAudioSessionCategory:self.audioSessionCategory])
    {
        return;
    }
    
    //2.Audio Unit具体设置
    [self initAudioUnit];
    
    //3.数据 从设备(麦克风)输入到应用 和 从应用输出到设备(扬声器)
    [self enableIOForRecordingAndPlay];
    
    //4 Describe format //获取 或者 设置输入描述格式
    [self initOrGetAudioInputFormat];
    
    //4.1 Describe format // 描述格式
    [self initAudioOutputFormat];
    
    //5.数据 I/OUnit输出到应用application 和 应用application输入到I/OUnit
    [self enableStreamIOUnitAndApplication];
    
    //6.设置audioUnit的录制和播放回调
    [self setCallBackForRecordAndPlay];
    
    //7.处理数据缓冲区
    [self handleBufferList];
    
    //8.通过设置输入输出格式创建音频转码器
    [self createAudioConverter:audioInputFormat audioOutputFormat:audioOutputFormat];
    
    // Initialise // 初始化
    //是初始化AudioUnit，需要在设置好absd之后调用；初始化是一个耗时的操作，需要分配buffer、申请系统资源等；
    status = AudioUnitInitialize(self.audioUnit);
    checkStatus(status, "AudioUnitInitialize");
    
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

#pragma mark 1.settingAVAudioSessionCategory
- (BOOL)settingAVAudioSessionCategory:(AVAudioSessionCategory)audioSessionCategory
{
    //注意:此处代码必须设置
    //1、设置AVAudioSession 设置其功能(录制、回调、或者录制和回调)
    NSError *error = nil;
    [[AVAudioSession sharedInstance] setCategory:audioSessionCategory error:&error];//AVAudioSessionCategory 根据不同的值，来设置走不同的回调1.Record 只走录制回调 2.playback 只走播放回调 3.playAndRecord 录制和播放回调同时都走。
    //默认值0.022,但是0.022对于自建的转码器（似乎不太友善会导致播放效果异常。），但对于ExtendedAudioFile内置的转码器却是ok的，所以个人认为是某些参数设置不对导致的。
    [[AVAudioSession sharedInstance] setPreferredIOBufferDuration:0.1 error:&error];
    if (error) {
        NSLog(@"audiosession error is %@",error.localizedDescription);
        return NO;
    }
    return YES;
}
#pragma mark 2.创建AudioUnit
- (void)initAudioUnit
{
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
    checkStatus(status, "AudioComponentInstanceNew");
}
#pragma mark 3.从设备(麦克风)输入到应用 和 从应用输出到设备(扬声器)
//1.设备（麦克风）输入数据到I/O Unit 和 4.I/O Unit输出数据到设备（扬声器）的数据格式
- (void)enableIOForRecordingAndPlay
{
    OSStatus status;
    //Enable IO for recording // 为录制打开 IO
    //1.设备（麦克风）输入数据到I/O Unit 和 4.I/O Unit输出数据到设备（扬声器）的数据格式
    UInt32 flag = 1;
    status = AudioUnitSetProperty(self.audioUnit,
                                  kAudioOutputUnitProperty_EnableIO,
                                  kAudioUnitScope_Input,
                                  kInputBus,
                                  &flag,
                                  sizeof(flag));
    checkStatus(status, "AudioUnitSetProperty kAudioUnitScope_Input kInputBus");
    
    //Enable IO for playback // 为播放打开 IO
    //4.I/O Unit输出数据到设备（扬声器）的数据格式
    status = AudioUnitSetProperty(self.audioUnit,
                                  kAudioOutputUnitProperty_EnableIO,
                                  kAudioUnitScope_Output,
                                  kOutputBus,
                                  &flag,
                                  sizeof(flag));
    checkStatus(status, "AudioUnitSetProperty kAudioUnitScope_Output kOutputBus");
}
#pragma mark 4.初始化音频文件数据的输入格式（一般是解码获取或者指定）
- (void)initOrGetAudioInputFormat
{
    //该方法里面的设置对非pcm音频文件有效，对于pcm音频文件根本不需要该设置【因为获取audioInputFormat是为了创建音频格式转码器的】
    NSURL *url = [NSURL URLWithString:self.file];
    
    if (self.isEnableExtendedService) {
        
        // Extend Audio File
        status = ExtAudioFileOpenURL((__bridge CFURLRef)url, &exAudioFile);
        checkStatus(status, "ExtAudioFileOpenURL");
        
        UInt32 size = sizeof(AudioStreamBasicDescription);
        status = ExtAudioFileGetProperty(exAudioFile, kExtAudioFileProperty_FileDataFormat, &size, &audioInputFormat);// 读取文件格式
        checkStatus(status, "ExtAudioFileGetProperty audioInputFormat");
        
        [self printAudioStreamBasicDescription:audioInputFormat isOutput:NO];
        if (audioInputFormat.mFormatID) {
            self.isReadNeedConvert = YES;
            NSLog(@"非pcm格式的音频数据，需要音频转码（转码通过ExtendedAudioFile内置的转码器实现）");
        }
        
        return;
    }
    
    status = AudioFileOpenURL((__bridge CFURLRef)url, kAudioFileReadPermission, 0, &audioFileID);
    checkStatus(status,"AudioFileOpenURL");
    
    UInt32 size = sizeof(AudioStreamBasicDescription);
    status = AudioFileGetProperty(audioFileID, kAudioFilePropertyDataFormat, &size, &audioInputFormat);// 读取文件格式
    
    size = sizeof(packetNums);
    status = AudioFileGetProperty(audioFileID,
                                  kAudioFilePropertyAudioDataPacketCount,
                                  &size,
                                  &packetNums); // 读取文件packets总数
    readedPacket = 0;
    
    UInt32 sizePerPacket = audioInputFormat.mFramesPerPacket;
    if (sizePerPacket == 0) {
        size = sizeof(sizePerPacket);
        status = AudioFileGetProperty(audioFileID, kAudioFilePropertyMaximumPacketSize, &size, &sizePerPacket); // 读取单个packet的最大数量
        checkStatus(status, "AudioFileGetProperty sizePerPacket");
    }
    
    audioInputPacketFormat = malloc(sizeof(AudioStreamPacketDescription) * (CONST_BUFFER_SIZES / sizePerPacket + 1));
    checkStatus(status, "malloc AudioStreamPacketDescription");
    
    [self printAudioStreamBasicDescription:audioInputFormat isOutput:NO];
    if (audioInputFormat.mFormatID) {
        self.isReadNeedConvert = YES;
        NSLog(@"非pcm格式的音频数据，需要音频转码（转码通过创建的AudioConverterRef转码器实现）");
    }
}

#pragma mark 4.1初始化音频文件数据输出格式
- (void)initAudioOutputFormat
{
    memset(&audioOutputFormat, 0, sizeof(audioOutputFormat));
    audioOutputFormat.mSampleRate         = 44100.00;//44.1KHz // 采样率
    audioOutputFormat.mFormatID           = kAudioFormatLinearPCM;// PCM格式
    audioOutputFormat.mFormatFlags        = kAudioFormatFlagIsSignedInteger;// 整形
    audioOutputFormat.mFramesPerPacket    = 1;// 每个packet只有1帧
    audioOutputFormat.mChannelsPerFrame   = 1;// 声道数
    audioOutputFormat.mBitsPerChannel     = 16;// 位深
    audioOutputFormat.mBytesPerFrame      = 2;// 每帧只有2个byte 声道*位深
    audioOutputFormat.mBytesPerPacket     = 2;// 每个Packet只有2个byte 声道*位深*帧数
    [self printAudioStreamBasicDescription:audioOutputFormat isOutput:YES];
}

#pragma mark 5.数据 I/OUnit输出到应用application 和 应用application输入到I/OUnit
//2.I/O Unit输出数据到应用appliction 和 3.应用application输出数据到I/O Unit
- (void)enableStreamIOUnitAndApplication
{
    //Application format // 设置应用处理音频的格式
    //2.I/O Unit输出数据到应用appliction 和 3.应用application输出数据到I/O Unit
    status = AudioUnitSetProperty(self.audioUnit,
                                  kAudioUnitProperty_StreamFormat,
                                  kAudioUnitScope_Output,
                                  kInputBus,
                                  &audioOutputFormat,
                                  sizeof(audioOutputFormat));
    checkStatus(status, "AudioUnitSetProperty kAudioUnitScope_Output kInputBus");
    //3.应用application输出数据到I/O Unit
    status = AudioUnitSetProperty(self.audioUnit,
                                  kAudioUnitProperty_StreamFormat,
                                  kAudioUnitScope_Input,
                                  kOutputBus,
                                  &audioOutputFormat,
                                  sizeof(audioOutputFormat));
    checkStatus(status, "AudioUnitSetProperty kAudioUnitScope_Input kOutputBus");
}

#pragma mark 6.设置audioUnit的录制和播放回调
- (void)setCallBackForRecordAndPlay
{
    //set input callback // 设置数据采集回调函数
    AURenderCallbackStruct callbackStruct;
    callbackStruct.inputProc = recordingCallback;
    callbackStruct.inputProcRefCon = (__bridge void * _Nullable)self;
    status = AudioUnitSetProperty(self.audioUnit,
                                  kAudioOutputUnitProperty_SetInputCallback,//用来设置回调
                                  kAudioUnitScope_Global,
                                  kInputBus,
                                  &callbackStruct,
                                  sizeof(callbackStruct));
    checkStatus(status, "AudioUnitSetProperty recordingCallback");
    
    //set output callback // 设置声音输出回调函数。当speaker需要数据时就会调用回调函数去获取数据。它是 "拉" 数据的概念。
    callbackStruct.inputProc = playbackCallback;
    callbackStruct.inputProcRefCon = (__bridge void * _Nullable)self;
    status = AudioUnitSetProperty(self.audioUnit,
                                  kAudioUnitProperty_SetRenderCallback,//用来设置回调
                                  kAudioUnitScope_Global,
                                  kOutputBus,
                                  &callbackStruct,
                                  sizeof(callbackStruct));
    checkStatus(status, "AudioUnitSetProperty playbackCallback");
}
#pragma mark 7.处理数据缓冲区
- (void)handleBufferList
{
    //Disable buffer allocation for the recorder (optional - do this if we want to pass in our own) // 关闭为录制分配的缓冲区（我们想使用我们自己分配的）
    UInt32 flag = 0;
    status = AudioUnitSetProperty(self.audioUnit,
                                  kAudioUnitProperty_ShouldAllocateBuffer,
                                  kAudioUnitScope_Output,
                                  kInputBus,
                                  &flag,
                                  sizeof(flag));
    // TODO: Allocate our own buffers if we want
    //创建并设置缓冲区大小（成功开启录制时，创建缓冲区。关闭录制时，销毁缓冲区）
    uint32_t numberBuffers = 1;
    UInt32 bufferSize = CONST_BUFFER_SIZES;
    [self initBufferList:bufferSize numberBuffers:numberBuffers];
}
//7.1设置录制 和 播放数据缓冲区
- (void)initBufferList:(UInt32)bufferSize numberBuffers:(uint32_t)numberBuffers
{
    AudioBufferList *bufferList = (AudioBufferList*)malloc(sizeof(AudioBufferList));
    bufferList->mNumberBuffers = numberBuffers;
    bufferList->mBuffers[0].mData = malloc(bufferSize);
    bufferList->mBuffers[0].mDataByteSize = bufferSize;
    bufferList->mBuffers[0].mNumberChannels = 1;
    self.bufferList = bufferList;
    
    AudioBufferList *playBufferList = (AudioBufferList*)malloc(sizeof(AudioBufferList));
    playBufferList->mNumberBuffers = numberBuffers;
    playBufferList->mBuffers[0].mData = malloc(bufferSize);
    playBufferList->mBuffers[0].mDataByteSize = bufferSize;
    playBufferList->mBuffers[0].mNumberChannels = 1;
    self.playBufferList = playBufferList;
}
#pragma mark 8.通过设置输入输出格式创建音频转码器
- (void)createAudioConverter:(AudioStreamBasicDescription)audioInputFormat audioOutputFormat:(AudioStreamBasicDescription)audioOutputFormat
{
    if (self.isEnableExtendedService) {
        
        uint32_t size = sizeof(AudioStreamBasicDescription);
        status = ExtAudioFileSetProperty(exAudioFile, kExtAudioFileProperty_ClientDataFormat, size, &audioOutputFormat);
        checkStatus(status, "ExtAudioFileSetProperty outputFormat");
        
        // 初始化不能太前，如果未设置好输入输出格式，获取的总frame数不准确
        size = sizeof(totalFrame);
        status = ExtAudioFileGetProperty(exAudioFile,
                                         kExtAudioFileProperty_FileLengthFrames,
                                         &size,
                                         &totalFrame);
        checkStatus(status, "ExtAudioFileGetProperty totalFrame");
        readedFrame = 0;
        
        return;
    }
    
    audioConverter = NULL;
    convertBuffer = malloc(CONST_BUFFER_SIZES);
    OSStatus status = AudioConverterNew(&audioInputFormat, &audioOutputFormat, &audioConverter);
    checkStatus(status, "AudioConverterNew 通过设置输入输出格式创建音频转码器");
}
// 检测状态
static void checkStatus(OSStatus status, const char *operation){
    if (status != noErr) {
        printf("Error: %ld: %s\n",(long)status, operation);
        //exit(1);
    }
}

#pragma mark 处理 录制文件写入fileHandle
- (void)initWriteFileHandle
{
    NSString *file = self.writeFile;
    [[NSFileManager defaultManager] removeItemAtPath:file error:nil];
    [[NSFileManager defaultManager] createFileAtPath:file contents:nil attributes:nil];
    fileWriteHandle = [NSFileHandle fileHandleForWritingAtPath:file];
}
- (void)closeWriteFileHandle
{
    [fileWriteHandle closeFile];
    fileWriteHandle = NULL;
}
#pragma mark 处理 播放文件的fileHandle
- (void)initReadFileHandle
{
    NSString *file = self.file;
    
    if ([file.pathExtension isEqualToString:@"pcm"]) {//直接用inputstream读取 播放即可
        inputSteam = [[NSInputStream alloc] initWithFileAtPath:file];
        if (!inputSteam) {
            NSLog(@"打开文件失败 %@", file);
        }
        else {
            [inputSteam open];
        }
    }else {//需要读取后 进行转码后 才能播放
        NSString *convertFile = self.convertFile;
        [[NSFileManager defaultManager] removeItemAtPath:convertFile error:nil];
        [[NSFileManager defaultManager] createFileAtPath:convertFile contents:nil attributes:nil];
        fileConverterWriteHandle = [NSFileHandle fileHandleForWritingAtPath:convertFile];
    }
}
- (void)closeReadFileHandle
{
    [inputSteam close];
    inputSteam = nil;
    
    [fileConverterWriteHandle closeFile];
    fileConverterWriteHandle = NULL;
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
    checkStatus(status, "AudioOutputUnitStart");
}
- (void)onStart
{
}
#pragma mark 关闭 Audio Unit
- (void)stop {
    //And to stop:
    OSStatus status = AudioOutputUnitStop(self.audioUnit);
    checkStatus(status, "AudioOutputUnitStop");
    
    [self closeBufferList];
    
    [self finished];//销毁
    
    [self onStop];
}
//1.释放数据缓冲区
- (void)closeBufferList
{
    if (self.bufferList != NULL) {
        if (self.bufferList->mBuffers[0].mData) {
            free(self.bufferList->mBuffers[0].mData);
            self.bufferList->mBuffers[0].mData = NULL;
        }
        free(self.bufferList);
        self.bufferList = NULL;
    }
    
    if (self.playBufferList != NULL) {
        if (self.playBufferList->mBuffers[0].mData) {
            free(self.playBufferList->mBuffers[0].mData);
            self.playBufferList->mBuffers[0].mData = NULL;
        }
        free(self.playBufferList);
        self.playBufferList = NULL;
    }
}
//2.结束Audio Unit
- (void)finished {
    AudioUnitUninitialize(self.audioUnit);
    AudioComponentInstanceDispose(self.audioUnit);
    self.audioUnit = nil;
}
//3.结束文件处理
- (void)onStop{
    
    if ([self.delegate respondsToSelector:@selector(onPlayToEnd:)]) {
        [self.delegate onPlayToEnd:self];
    }
    
    [self closeReadFileHandle];
    
    //[self writeFile:self.pcmData];
    self.pcmData = [NSMutableData new];//reset
    [self closeWriteFileHandle];
}
#pragma mark fileUrl 文件路径处理
- (NSString *)file
{
    if (!_file) {
        NSString *file = [CacheHelper pathForCommonFile:[self fileName:0] withType:0];
        _file = file;
    }
    return _file;
}

- (NSString *)writeFile {
    if (!_writeFile) {
        NSString *file = [CacheHelper pathForCommonFile:[self fileName:1] withType:0];
        _writeFile = file;
    }
    return _writeFile;
}

- (NSString *)convertFile
{
    if (!_convertFile) {
        NSString *file = [CacheHelper pathForCommonFile:[self fileName:2] withType:0];
        _convertFile = file;
    }
    return _convertFile;
}

-(NSString *)fileName:(NSInteger)type {
    NSMutableString *strM = [NSMutableString stringWithFormat:@"%@",NSStringFromClass(AudioManager.class)];
    switch (type) {
        case 1:
        {
            [strM appendString:@"_write"];
            break;
        }
        case 2:
        {
            [strM appendString:@"_convert"];
            break;
        }
        default:
            break;
    }
    [strM appendString:@".pcm"];
    return strM;
}

#pragma mark 录制和播放回调 delegate
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
                                 self.bufferList);//数据处理到缓冲区的数据结构中
        checkStatus(status, "AudioUnitRender");
        
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
    
    if (!self->_isReadNeedConvert)
    {
        //1.直接读取音频数据播放
        ioData->mBuffers[0].mDataByteSize = (UInt32)[self->inputSteam read:ioData->mBuffers[0].mData maxLength:(NSInteger)ioData->mBuffers[0].mDataByteSize];//从文件中读取pcm数据
    }else
    {
        //2.读取音频数据转码后播放
        AudioBufferList *bufferList = self.playBufferList;
        
        if (self.isEnableExtendedService) {
            
            bufferList->mBuffers[0].mDataByteSize = CONST_BUFFER_SIZES;
            OSStatus status = ExtAudioFileRead(self->exAudioFile, &inNumberFrames, bufferList);
            if (status) {
                NSLog(@"转换格式失败:%ld", (long)status);
            }
            
            if (self->audioOutputFormat.mBytesPerFrame != 0) {
                self->readedFrame += bufferList->mBuffers[0].mDataByteSize / self->audioOutputFormat.mBytesPerFrame;//Bytes per Frame = 2，所以是每2bytes一帧
            }
            
        }else {
            
            OSStatus status = AudioConverterFillComplexBuffer(self->audioConverter, lyInInputDataProc, inRefCon, &inNumberFrames, bufferList, NULL);
            if (status) {
                NSLog(@"转换格式失败:%ld", (long)status);
            }
            
            
        }
        
        memcpy(ioData->mBuffers[0].mData, bufferList->mBuffers[0].mData, bufferList->mBuffers[0].mDataByteSize);
        ioData->mBuffers[0].mDataByteSize = bufferList->mBuffers[0].mDataByteSize;
        
        NSData *aPcmData = [NSData dataWithBytes:bufferList->mBuffers[0].mData length:bufferList->mBuffers[0].mDataByteSize];
        [self writeConvertData:aPcmData];//2.直接追加到fileHandle指定的文件中
    }
    
    NSLog(@"playbackCallback:size:%ld",(long)ioData->mBuffers[0].mDataByteSize);
    
    if (ioData->mBuffers[0].mDataByteSize <= 0) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self stop];
        });
    }
    
    return noErr;
}

OSStatus lyInInputDataProc(AudioConverterRef inAudioConverter, UInt32 *ioNumberDataPackets, AudioBufferList *ioData, AudioStreamPacketDescription **outDataPacketDescription, void *inUserData)
{
    AudioManager *self = (__bridge AudioManager *)(inUserData);
    
    UInt32 byteSize = CONST_BUFFER_SIZES;
    OSStatus status = AudioFileReadPacketData(self->audioFileID, NO, &byteSize, self->audioInputPacketFormat, self->readedPacket, ioNumberDataPackets, self ->convertBuffer);
    
    if (outDataPacketDescription) { // 这里要设置好packetFormat，否则会转码失败
        *outDataPacketDescription = self->audioInputPacketFormat;
    }
    
    if(status) {
        NSLog(@"读取文件失败");
    }
    
    if (!status && ioNumberDataPackets > 0) {
        ioData->mBuffers[0].mDataByteSize = byteSize;
        ioData->mBuffers[0].mData = self->convertBuffer;
        self->readedPacket += *ioNumberDataPackets;
        return noErr;
    }
    else {
        return NO_MORE_DATA;
    }
    
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
    [fileWriteHandle writeData:aPcmData];
}
- (void)writeConvertData:(NSData *)aPcmData
{
    [fileConverterWriteHandle writeData:aPcmData];
}
#pragma mark 打印 printAudioStreamBasicDescription
- (void)printAudioStreamBasicDescription:(AudioStreamBasicDescription)asbd isOutput:(BOOL)isOutput{
    char formatID[5];
    UInt32 mFormatID = CFSwapInt32HostToBig(asbd.mFormatID);
    bcopy (&mFormatID, formatID, 4);
    formatID[4] = '\0';
    if (isOutput) {
        printf("流输出格式\n");
    }else{
        printf("流输入格式\n");
    }
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

- (void)printType {
    NSString *type = @"audioUnit";
    if(self.isEnableExtendedService) {
        type = @"ExtendedAudioFile";
    }
    NSLog(@"音频录制播放功能通过%@实现",type);
}

#pragma mark getCurrentTime
- (double)getCurrentTime {
    
    if (self.isEnableExtendedService) {
        Float64 timeInterval = (readedFrame * 1.0) / totalFrame;
        return timeInterval;
    }
    
    Float64 timeInterval = (readedPacket * 1.0) / packetNums;
    return timeInterval;
    
}
@end
