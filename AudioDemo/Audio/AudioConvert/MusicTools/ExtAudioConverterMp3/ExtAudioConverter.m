//
//  ExtAudioConverter.m
//  ExtAudioConverter
//
//  Created by zhuzj on 19/4/9.
//  Copyright (c) 2019年 zhuzj. All rights reserved.
//

#import "ExtAudioConverter.h"
#import "lame.h"

typedef struct ExtAudioConverterSettings{
    AudioStreamBasicDescription   inputPCMFormat;
    AudioStreamBasicDescription   outputFormat;
    
    ExtAudioFileRef               inputFile;
    ExtAudioFileRef               outputFile;
    CFStringRef                   inputFilePath;
    CFStringRef                   outputFilePath;
    

    AudioStreamPacketDescription* inputPacketDescriptions;
}ExtAudioConverterSettings;

static void CheckError(OSStatus error, const char *operation)
{
    if (error == noErr) return;
    char errorString[20];
    // See if it appears to be a 4-char-code
    *(UInt32 *)(errorString + 1) = CFSwapInt32HostToBig(error);
    if (isprint(errorString[1]) && isprint(errorString[2]) &&
        isprint(errorString[3]) && isprint(errorString[4])) {
        errorString[0] = errorString[5] = '\'';
        errorString[6] = '\0';
    } else
        // No, format it as an integer
        sprintf(errorString, "%d", (int)error);
    fprintf(stderr, "Error: %s (%s)\n", operation, errorString);
    exit(1);
}

void startConvert(ExtAudioConverterSettings* settings){
    //Determine the proper buffer size and calculate number of packets per buffer
    //for CBR and VBR format
    UInt32 sizePerBuffer = 32*1024;//32KB is a good starting point
    UInt32 framesPerBuffer = sizePerBuffer/sizeof(SInt16);
    
    // allocate destination buffer
    SInt16 *outputBuffer = (SInt16 *)malloc(sizeof(SInt16) * sizePerBuffer);
    
    while (1) {
        AudioBufferList outputBufferList;
        outputBufferList.mNumberBuffers              = 1;
        outputBufferList.mBuffers[0].mNumberChannels = settings->outputFormat.mChannelsPerFrame;
        outputBufferList.mBuffers[0].mDataByteSize   = sizePerBuffer;
        outputBufferList.mBuffers[0].mData           = outputBuffer;
        
        UInt32 framesCount = framesPerBuffer;
        
        CheckError(ExtAudioFileRead(settings->inputFile,
                                    &framesCount,
                                    &outputBufferList),
                   "ExtAudioFileRead failed");
        
        if (framesCount==0) {
            printf("Done reading from input file\n");
            return;
        }
        
        CheckError(ExtAudioFileWrite(settings->outputFile,
                                     framesCount,
                                     &outputBufferList),
                   "ExtAudioFileWrite failed");
    }
}

#pragma mark ExtAudioFileRead读文件【测试发现：不支持pcm（ExtAudioFileRead不支持pcm文件读取）】
void startConvertMP3(ExtAudioConverterSettings* settings){
    //Init lame and set parameters
    lame_t lame = lame_init();
    lame_set_in_samplerate(lame, settings->inputPCMFormat.mSampleRate);
    lame_set_num_channels(lame, settings->inputPCMFormat.mChannelsPerFrame);
    lame_set_VBR(lame, vbr_default);
    lame_init_params(lame);
    
    NSString* outputFilePath = (__bridge NSString*)settings->outputFilePath;
    FILE* outputFile = fopen([outputFilePath cStringUsingEncoding:1], "wb");
    
    UInt32 sizePerBuffer = 32*1024;
    UInt32 framesPerBuffer = sizePerBuffer/sizeof(SInt16);
    
    int write;
    
    // allocate destination buffer
    SInt16 *outputBuffer = (SInt16 *)malloc(sizeof(SInt16) * sizePerBuffer);
    
    while (1) {
        AudioBufferList outputBufferList;
        outputBufferList.mNumberBuffers              = 1;
        outputBufferList.mBuffers[0].mNumberChannels = settings->outputFormat.mChannelsPerFrame;
        outputBufferList.mBuffers[0].mDataByteSize   = sizePerBuffer;
        outputBufferList.mBuffers[0].mData           = outputBuffer;
        
        UInt32 framesCount = framesPerBuffer;
        
        CheckError(ExtAudioFileRead(settings->inputFile,
                                    &framesCount,
                                    &outputBufferList),
                   "ExtAudioFileRead failed");
        
        SInt16 pcm_buffer[framesCount];
        unsigned char mp3_buffer[framesCount];
        memcpy(pcm_buffer,
               outputBufferList.mBuffers[0].mData,
               framesCount);
        if (framesCount==0) {
            printf("Done reading from input file\n");
            //TODO:Add lame_encode_flush for end of file
            fclose(outputFile);
            return;
        }
        
        //the 3rd parameter means number of samples per channel, not number of sample in pcm_buffer
        write = lame_encode_buffer_interleaved(lame,
                                               outputBufferList.mBuffers[0].mData,
                                               framesCount,
                                               mp3_buffer,
                                               0);
        size_t result = fwrite(mp3_buffer,
                               1,
                               write,
                               outputFile);
    }
}


@implementation ExtAudioConverter

#pragma mark FILE读文件【支持pcm】
+ (BOOL)convertToMp3:(NSString *)inputFile outputFile:(NSString *)outputFile convertSuccess:(ConvertSuccess)convertSuccess
{
    if (!inputFile) {
        inputFile = [[NSBundle mainBundle] pathForResource:kAudioPcmName ofType:nil];
    }
    if (!outputFile) {
        outputFile = pathdwf(@"outputPcmToMp3.mp3");
    }
    @try {
        int read,write;
        //只读方式打开被转换音频文件
        FILE *pcm = fopen([inputFile cStringUsingEncoding:1], "rb");
        fseek(pcm, 4 * 1024, SEEK_CUR);//删除头，否则在前一秒钟会有杂音
        //只写方式打开生成的MP3文件
        FILE *mp3 = fopen([outputFile cStringUsingEncoding:1], "wb");
        
        const int PCM_SIZE = 8192;
        const int MP3_SIZE = 8192;
        short int pcm_buffer[PCM_SIZE * 2];
        unsigned char mp3_buffer[MP3_SIZE];
        //这里要注意，lame的配置要跟AVAudioRecorder的配置一致，否则会造成转换不成功
        lame_t lame = lame_init();
        lame_set_in_samplerate(lame, 44100.0);//采样率
        lame_set_num_channels(lame, 2);
        lame_set_VBR(lame, vbr_default);
        lame_init_params(lame);
        
        do {
            //以二进制形式读取文件中的数据
            read = (int)fread(pcm_buffer, 2 * sizeof(short int), PCM_SIZE, pcm);
            if (read == 0)
                write = lame_encode_flush(lame, mp3_buffer, MP3_SIZE);
            else
                write = lame_encode_buffer_interleaved(lame, pcm_buffer, read, mp3_buffer, MP3_SIZE);
            
            //二进制形式写数据到文件中  mp3_buffer：数据输出到文件的缓冲区首地址  write：一个数据块的字节数  1:指定一次输出数据块的个数   mp3:文件指针
            fwrite(mp3_buffer, write, 1, mp3);
            
        } while (read != 0);
        
        lame_close(lame);
        fclose(mp3);
        fclose(pcm);

    } @catch (NSException *exception) {
        NSLog(@"%@",[exception description]);
    } @finally {
        NSLog(@"MP3生成成功!!!");
        convertSuccess(YES, outputFile);
    }
    return YES;
}


@synthesize inputFile;
@synthesize outputFile;
@synthesize outputSampleRate;
@synthesize outputNumberChannels;
@synthesize outputBitDepth;

//Check if the input combination is valid
-(BOOL)validateInput:(ExtAudioConverterSettings*)settigs{
    //Set default output format
    if (self.outputSampleRate==0) {
        self.outputSampleRate = 44100;
    }
    
    if (self.outputNumberChannels==0) {
        self.outputNumberChannels = 2;
    }
    
    if (self.outputBitDepth==0) {
        self.outputBitDepth = 16;
    }
    
    if (self.outputFormatID==0) {
        self.outputFormatID = kAudioFormatLinearPCM;
    }
    
    if (self.outputFileType==0) {
        //caf type is the most powerful file format
        self.outputFileType = kAudioFileCAFType;
    }
    
    BOOL valid = YES;
    //The file format and data format match documentatin is at: https://developer.apple.com/library/ios/documentation/MusicAudio/Conceptual/CoreAudioOverview/SupportedAudioFormatsMacOSX/SupportedAudioFormatsMacOSX.html
    switch (self.outputFileType) {
        case kAudioFileWAVEType:{//for wave file format
            //WAVE file type only support PCM, alaw and ulaw
            valid = self.outputFormatID==kAudioFormatLinearPCM || self.outputFormatID==kAudioFormatALaw || self.outputFormatID==kAudioFormatULaw;
            break;
        }
        case kAudioFileAIFFType:{
            //AIFF only support PCM format
            valid = self.outputFormatID==kAudioFormatLinearPCM;
            break;
        }
        case kAudioFileAAC_ADTSType:{
            //aac only support aac data format
            valid = self.outputFormatID==kAudioFormatMPEG4AAC;
            break;
        }
        case kAudioFileAC3Type:{
            //convert from PCM to ac3 format is not supported
            valid = NO;
            break;
        }
        case kAudioFileAIFCType:{
            //TODO:kAudioFileAIFCType together with kAudioFormatMACE3/kAudioFormatMACE6/kAudioFormatQDesign2/kAudioFormatQUALCOMM pair failed
            //Since MACE3:1/MACE6:1 is obsolete, they're not supported yet
            valid = self.outputFormatID==kAudioFormatLinearPCM || self.outputFormatID==kAudioFormatULaw || self.outputFormatID==kAudioFormatALaw || self.outputFormatID==kAudioFormatAppleIMA4 || self.outputFormatID==kAudioFormatQDesign2 || self.outputFormatID==kAudioFormatQUALCOMM;
            break;
        }
        case kAudioFileCAFType:{
            //caf file type support almost all data format
            //TODO:not all foramt are supported, check them out
            valid = YES;
            break;
        }
        case kAudioFileMP3Type:{
            //TODO:support mp3 type
            valid = self.outputFormatID==kAudioFormatMPEGLayer3;
            break;
        }
        case kAudioFileMPEG4Type:{
            valid = self.outputFormatID==kAudioFormatMPEG4AAC;
            break;
        }
        case kAudioFileM4AType:{
            valid = self.outputFormatID==kAudioFormatMPEG4AAC || self.outputFormatID==kAudioFormatAppleLossless;
            break;
        }
        case kAudioFileNextType:{
            valid = self.outputFormatID==kAudioFormatLinearPCM || self.outputFormatID==kAudioFormatULaw;
            break;
        }
        case kAudioFileSoundDesigner2Type:{
            valid = self.outputFormatID==kAudioFormatLinearPCM;
            break;
        }
            //TODO:check iLBC format
        default:
            break;
    }
    
    if (!valid) {
        NSLog(@"the file format and data format pair is not valid");
    }
    
    return valid;
}

-(NSString*)descriptionForAudioFormat:(AudioStreamBasicDescription) audioFormat
{
    NSMutableString *description = [NSMutableString new];
    
    // From https://developer.apple.com/library/ios/documentation/MusicAudio/Conceptual/AudioUnitHostingGuide_iOS/ConstructingAudioUnitApps/ConstructingAudioUnitApps.html (Listing 2-8)
    char formatIDString[5];
    UInt32 formatID = CFSwapInt32HostToBig (audioFormat.mFormatID);
    bcopy (&formatID, formatIDString, 4);
    formatIDString[4] = '\0';
    
    [description appendString:@"\n"];
    [description appendFormat:@"Sample Rate:         %10.0f \n",  audioFormat.mSampleRate];
    [description appendFormat:@"Format ID:           %10s \n",    formatIDString];
    [description appendFormat:@"Format Flags:        %10d \n",    (unsigned int)audioFormat.mFormatFlags];
    [description appendFormat:@"Bytes per Packet:    %10d \n",    (unsigned int)audioFormat.mBytesPerPacket];
    [description appendFormat:@"Frames per Packet:   %10d \n",    (unsigned int)audioFormat.mFramesPerPacket];
    [description appendFormat:@"Bytes per Frame:     %10d \n",    (unsigned int)audioFormat.mBytesPerFrame];
    [description appendFormat:@"Channels per Frame:  %10d \n",    (unsigned int)audioFormat.mChannelsPerFrame];
    [description appendFormat:@"Bits per Channel:    %10d \n",    (unsigned int)audioFormat.mBitsPerChannel];
    
    // Add flags (supposing standard flags).
    [description appendString:[self descriptionForStandardFlags:audioFormat.mFormatFlags]];
    
    return [NSString stringWithString:description];
}

-(NSString*)descriptionForStandardFlags:(UInt32) mFormatFlags
{
    NSMutableString *description = [NSMutableString new];
    
    if (mFormatFlags & kAudioFormatFlagIsFloat)
    { [description appendString:@"kAudioFormatFlagIsFloat \n"]; }
    if (mFormatFlags & kAudioFormatFlagIsBigEndian)
    { [description appendString:@"kAudioFormatFlagIsBigEndian \n"]; }
    if (mFormatFlags & kAudioFormatFlagIsSignedInteger)
    { [description appendString:@"kAudioFormatFlagIsSignedInteger \n"]; }
    if (mFormatFlags & kAudioFormatFlagIsPacked)
    { [description appendString:@"kAudioFormatFlagIsPacked \n"]; }
    if (mFormatFlags & kAudioFormatFlagIsAlignedHigh)
    { [description appendString:@"kAudioFormatFlagIsAlignedHigh \n"]; }
    if (mFormatFlags & kAudioFormatFlagIsNonInterleaved)
    { [description appendString:@"kAudioFormatFlagIsNonInterleaved \n"]; }
    if (mFormatFlags & kAudioFormatFlagIsNonMixable)
    { [description appendString:@"kAudioFormatFlagIsNonMixable \n"]; }
    if (mFormatFlags & kAudioFormatFlagsAreAllClear)
    { [description appendString:@"kAudioFormatFlagsAreAllClear \n"]; }
    if (mFormatFlags & kLinearPCMFormatFlagIsFloat)
    { [description appendString:@"kLinearPCMFormatFlagIsFloat \n"]; }
    if (mFormatFlags & kLinearPCMFormatFlagIsBigEndian)
    { [description appendString:@"kLinearPCMFormatFlagIsBigEndian \n"]; }
    if (mFormatFlags & kLinearPCMFormatFlagIsSignedInteger)
    { [description appendString:@"kLinearPCMFormatFlagIsSignedInteger \n"]; }
    if (mFormatFlags & kLinearPCMFormatFlagIsPacked)
    { [description appendString:@"kLinearPCMFormatFlagIsPacked \n"]; }
    if (mFormatFlags & kLinearPCMFormatFlagIsAlignedHigh)
    { [description appendString:@"kLinearPCMFormatFlagIsAlignedHigh \n"]; }
    if (mFormatFlags & kLinearPCMFormatFlagIsNonInterleaved)
    { [description appendString:@"kLinearPCMFormatFlagIsNonInterleaved \n"]; }
    if (mFormatFlags & kLinearPCMFormatFlagIsNonMixable)
    { [description appendString:@"kLinearPCMFormatFlagIsNonMixable \n"]; }
    if (mFormatFlags & kLinearPCMFormatFlagsSampleFractionShift)
    { [description appendString:@"kLinearPCMFormatFlagsSampleFractionShift \n"]; }
    if (mFormatFlags & kLinearPCMFormatFlagsSampleFractionMask)
    { [description appendString:@"kLinearPCMFormatFlagsSampleFractionMask \n"]; }
    if (mFormatFlags & kLinearPCMFormatFlagsAreAllClear)
    { [description appendString:@"kLinearPCMFormatFlagsAreAllClear \n"]; }
    if (mFormatFlags & kAppleLosslessFormatFlag_16BitSourceData)
    { [description appendString:@"kAppleLosslessFormatFlag_16BitSourceData \n"]; }
    if (mFormatFlags & kAppleLosslessFormatFlag_20BitSourceData)
    { [description appendString:@"kAppleLosslessFormatFlag_20BitSourceData \n"]; }
    if (mFormatFlags & kAppleLosslessFormatFlag_24BitSourceData)
    { [description appendString:@"kAppleLosslessFormatFlag_24BitSourceData \n"]; }
    if (mFormatFlags & kAppleLosslessFormatFlag_32BitSourceData)
    { [description appendString:@"kAppleLosslessFormatFlag_32BitSourceData \n"]; }
    
    return [NSString stringWithString:description];
}


#pragma mark API
-(BOOL)convert:(ConvertSuccess)convertSuccess{
    ExtAudioConverterSettings settings = {0};
    
    //Check if source file or output file is null
    if (self.inputFile==NULL) {
        NSLog(@"Source file is not set");
        convertSuccess(NO, nil);
        return NO;
    }
    
    if (self.outputFile==NULL) {
        NSLog(@"Output file is no set");
        convertSuccess(NO, nil);
        return NO;
    }
    
    //Create ExtAudioFileRef
    NSURL* sourceURL = [NSURL fileURLWithPath:self.inputFile];
    CheckError(ExtAudioFileOpenURL((__bridge CFURLRef)sourceURL,
                                   &settings.inputFile),
               "ExtAudioFileOpenURL failed");
    
    if (![self validateInput:&settings]) {
        convertSuccess(NO, nil);
        return NO;
    }
    
    settings.outputFormat.mSampleRate       = self.outputSampleRate;
    settings.outputFormat.mBitsPerChannel   = self.outputBitDepth;
    if (self.outputFormatID==kAudioFormatMPEG4AAC) {
        settings.outputFormat.mBitsPerChannel = 0;
    }
    settings.outputFormat.mChannelsPerFrame = self.outputNumberChannels;
    settings.outputFormat.mFormatID         = self.outputFormatID;
    
    if (self.outputFormatID==kAudioFormatLinearPCM) {
        settings.outputFormat.mBytesPerFrame   = settings.outputFormat.mChannelsPerFrame * settings.outputFormat.mBitsPerChannel/8;
        settings.outputFormat.mBytesPerPacket  = settings.outputFormat.mBytesPerFrame;
        settings.outputFormat.mFramesPerPacket = 1;
        settings.outputFormat.mFormatFlags     = kAudioFormatFlagIsSignedInteger | kAudioFormatFlagIsPacked;
        //some file type only support big-endian
        if (self.outputFileType==kAudioFileAIFFType || self.outputFileType==kAudioFileSoundDesigner2Type || self.outputFileType==kAudioFileAIFCType || self.outputFileType==kAudioFileNextType) {
            settings.outputFormat.mFormatFlags |= kAudioFormatFlagIsBigEndian;
        }
    }else{
        UInt32 size = sizeof(settings.outputFormat);
        CheckError(AudioFormatGetProperty(kAudioFormatProperty_FormatInfo,
                                          0,
                                          NULL,
                                          &size,
                                          &settings.outputFormat),
                   "AudioFormatGetProperty kAudioFormatProperty_FormatInfo failed");
    }
    NSLog(@"output format:%@",[self descriptionForAudioFormat:settings.outputFormat]);
    
    //Create output file
    //if output file path is invalid, this returns an error with 'wht?'
    NSURL* outputURL = [NSURL fileURLWithPath:self.outputFile];
    
    //create output file
    settings.outputFilePath = (__bridge CFStringRef)(self.outputFile);
    settings.inputFilePath = (__bridge CFStringRef)(self.inputFile);
    if (settings.outputFormat.mFormatID!=kAudioFormatMPEGLayer3) {
        CheckError(ExtAudioFileCreateWithURL((__bridge CFURLRef)outputURL,
                                             self.outputFileType,
                                             &settings.outputFormat,
                                             NULL,
                                             kAudioFileFlags_EraseFile,
                                             &settings.outputFile),
                   "Create output file failed, the output file type and output format pair may not match");
    }
    
    //Set input file's client data format
    //Must be PCM, thus as we say, "when you convert data, I want to receive PCM format"
    //必须是PCM，正如我们所说，“当你转换数据时，我想要接收PCM格式”
    if (settings.outputFormat.mFormatID==kAudioFormatLinearPCM) {
        settings.inputPCMFormat = settings.outputFormat;
    }else{
        settings.inputPCMFormat.mFormatID = kAudioFormatLinearPCM;
        settings.inputPCMFormat.mSampleRate = settings.outputFormat.mSampleRate;
        //TODO:set format flags for both OS X and iOS, for all versions
        settings.inputPCMFormat.mFormatFlags = kAudioFormatFlagIsPacked | kAudioFormatFlagIsSignedInteger;
        //TODO:check if sixze of SInt16 is always suitable
        settings.inputPCMFormat.mBitsPerChannel = 8 * sizeof(SInt16);
        settings.inputPCMFormat.mChannelsPerFrame = settings.outputFormat.mChannelsPerFrame;
        //TODO:check if this is suitable for both interleaved/noninterleaved
        settings.inputPCMFormat.mBytesPerPacket = settings.inputPCMFormat.mBytesPerFrame = settings.inputPCMFormat.mChannelsPerFrame*sizeof(SInt16);
        settings.inputPCMFormat.mFramesPerPacket = 1;
    }
    NSLog(@"Client data format:%@",[self descriptionForAudioFormat:settings.inputPCMFormat]);
    
    CheckError(ExtAudioFileSetProperty(settings.inputFile,
                                       kExtAudioFileProperty_ClientDataFormat,
                                       sizeof(settings.inputPCMFormat),
                                       &settings.inputPCMFormat),
               "Setting client data format of input file failed");
    
    //If the file has a client data format, then the audio data in ioData is translated from the client format to the file data format, via theExtAudioFile's internal AudioConverter.
    if (settings.outputFormat.mFormatID!=kAudioFormatMPEGLayer3) {
        CheckError(ExtAudioFileSetProperty(settings.outputFile,
                                           kExtAudioFileProperty_ClientDataFormat,
                                           sizeof(settings.inputPCMFormat),
                                           &settings.inputPCMFormat),
                   "Setting client data format of output file failed");
    }
    
    
    printf("Start converting...\n");
    if (settings.outputFormat.mFormatID==kAudioFormatMPEGLayer3) {
        startConvertMP3(&settings);
    }else{
        startConvert(&settings);
    }
    
    
    ExtAudioFileDispose(settings.inputFile);
    //AudioFileClose/ExtAudioFileDispose function is needed, or else for .wav output file the duration will be 0
    ExtAudioFileDispose(settings.outputFile);
    convertSuccess(YES, self.outputFile);
    return YES;
}

+ (void)convertDefault:(ConvertSuccess)convertSuccess inputFile:(NSString *)inputFile outputFile:(NSString *)outputFile
{
    if (!inputFile) {
        inputFile = [[NSBundle mainBundle] pathForResource:kAudioName ofType:nil];
    }
    if (!outputFile) {
        outputFile = pathdwf(@"output.mp3");
    }
    [self convertWithInputFile:inputFile
                           outputFile:outputFile
                     outputSampleRate:8000
                 outputNumberChannels:2
                       outputBitDepth:BitDepth_16
                       outputFormatID:kAudioFormatMPEGLayer3
                       outputFileType:kAudioFileMP3Type
                convertSuccess:convertSuccess];
}

+ (void)convertWithInputFile:(NSString *)inputFile
                  outputFile:(NSString *)outputFile
            outputSampleRate:(int)outputSampleRate
        outputNumberChannels:(int)outputNumberChannels
              outputBitDepth:(enum BitDepth)outputBitDepth
              outputFormatID:(AudioFormatID)outputFormatID
              outputFileType:(AudioFileTypeID)outputFileType
              convertSuccess:(ConvertSuccess)convertSuccess
{
    ExtAudioConverter* converter = [[ExtAudioConverter alloc] init];
    converter.inputFile = inputFile;
    converter.outputFile = outputFile;
    converter.outputSampleRate = outputSampleRate;
    converter.outputNumberChannels = outputNumberChannels;
    converter.outputBitDepth = outputBitDepth;
    converter.outputFormatID = outputFormatID;
    converter.outputFileType = outputFileType;
    dispatch_async(dispatch_queue_create(NULL, DISPATCH_QUEUE_SERIAL), ^{
         [converter convert:convertSuccess];
    });
}

@end
