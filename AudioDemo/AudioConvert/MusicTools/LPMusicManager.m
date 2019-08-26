//
//  LPMusicManager.m
//  AudioDemo
//
//  Created by 朱志佳 on 2019/8/21.
//  Copyright © 2019 朱志佳. All rights reserved.
//

#import "LPMusicManager.h"
#import "ExtAudioConverter.h"

@interface LPMusicManager ()<AVAudioPlayerDelegate>

@property (nonatomic,strong)AVAudioPlayer *audioPlayer;

@end

@implementation LPMusicManager

SingleImplementation(Manager)

- (instancetype)init
{
    self = [super init];
    if (self) {
        
    }
    return self;
}

/*
 AVAudioPlayer是属于 AVFundation.framework 的一个类，它的功能类似于一个功能强大的播放器。
 AVAudioPlayer每次播放都需要将上一个player对象释放掉，然后重新创建一个player来进行播放,AVAudioPlayer 支持广泛的音频格式，主要是以下这些格式。
 ACC
 AMR(Adaptive multi-Rate，一种语音格式)
 ALAC (Apple lossless Audio Codec)
 iLBC (internet Low Bitrate Codec，另一种语音格式)
 IMA4 (IMA/ADPCM)
 linearPCM (uncompressed)
 u-law 和 a-law
 MP3 (MPEG-Laudio Layer 3)
 */
#pragma mark AVAudioPlayer play (音频播放)
- (void)playByAVAudioPlayerWithPath:(NSString *)filePath {
    
    [self settingAVAudioSessionCategory:AVAudioSessionCategoryPlayback];
    
    NSURL *assetURL = [NSURL URLWithString:filePath];
    NSLog(@"assetPath:%@", assetURL.absoluteString);
    if (!assetURL) {
        NSLog(@"assetURL音频文件路径不存在");
        return;
    }
    
    [self stopPlay];
    
    NSError *error;
    self.audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:assetURL error:&error];
    if (error) {
        NSLog(@"AVAudioPlayer init error:%@", error);
    }
    self.audioPlayer.delegate = self;
    [self.audioPlayer prepareToPlay];
    // 播放音乐
    dispatch_async(dispatch_get_main_queue(), ^{
       [self.audioPlayer play];
    });
}

//设置AVAudioSession 设置其功能(录制、回调、或者录制和回调)
//AVAudioSessionCategory 根据不同的值，来设置走不同的回调1.Record 只走录制回调 2.playback 只走播放回调 3.playAndRecord 录制和播放回调同时都走。
- (BOOL)settingAVAudioSessionCategory:(AVAudioSessionCategory)audioSessionCategory
{
    NSError *error = nil;
    AVAudioSession *session = [AVAudioSession sharedInstance];
    [session setCategory:audioSessionCategory error:&error];
    //[session setPreferredIOBufferDuration:0.1 error:&error]
    [session setActive:YES error:nil];
    if (error) {
        NSLog(@"audiosession setting error is %@",error.localizedDescription);
        return NO;
    }
    return YES;
}

- (void)stopPlay
{
    if (self.audioPlayer) {
        [self.audioPlayer stop];
        self.audioPlayer = nil;
    }
}
/*
 音频文件格式转换 通过AVURLAsset、AVAssetReader、AVAssetWriterInput、AVAssetTrack
 Available file types are: public.aiff-audio, public.3gpp, public.aifc-audio, com.apple.m4v-video, com.apple.m4a-audio, com.apple.coreaudio-format, public.mpeg-4, com.microsoft.waveform-audio, com.apple.quicktime-movie, org.3gpp.adaptive-multi-rate-audio'
 ！！不支持mp3格式
 */
#pragma mark 通过AVURLAsset、reader、writer转音频格式支持多种，但是不支持直接转mp3格式
- (void)convertToCaf:(NSString *)filePath newFolderName:(NSString *)newFolderName newFileName:(NSString *)newFileName completionHandler:(CompletionHandler)completionHandler
{
    NSURL *assetURL = [NSURL URLWithString:filePath];
    NSLog(@"assetPath:%@", assetURL.absoluteString);
    if (!assetURL) {
        NSLog(@"assetURL音频文件路径不存在");
        !completionHandler ? : completionHandler(nil, nil);
        return;
    }
    
    AVURLAsset *asset = [AVURLAsset URLAssetWithURL:assetURL options:nil];
    
    NSError *error = nil;
    AVAssetReader *assetReader = [AVAssetReader assetReaderWithAsset:asset error:&error];
    if (error) {
        !completionHandler ? : completionHandler(nil, nil);
        NSLog (@"AVAssetReader init error: %@", error);
        return;
    }
    
    AVAssetReaderOutput *assetReaderOutput = [AVAssetReaderAudioMixOutput
                                              assetReaderAudioMixOutputWithAudioTracks:asset.tracks
                                              audioSettings:nil];
    if (![assetReader canAddOutput: assetReaderOutput]) {
        NSLog (@"assetReader can't add assetReaderOutput ... die!");
        !completionHandler ? : completionHandler(nil, nil);
        return;
    }
    [assetReader addOutput: assetReaderOutput];
    NSString *exportPath = [LPMusicManager getFilePathWithOriginFilePath:filePath newFolderName:TempCachePath newFileName:newFileName pathExtension:@"caf"];
    NSURL *exportURL = [NSURL fileURLWithPath:exportPath];
    AVAssetWriter *assetWriter = [AVAssetWriter assetWriterWithURL:exportURL
                                                          fileType:AVFileTypeCoreAudioFormat
                                                             error:&error];
    if (error) {
        !completionHandler ? : completionHandler(nil, nil);
        NSLog (@"AVAssetWriter init error: %@", error);
        return;
    }
    AudioChannelLayout channelLayout;
    memset(&channelLayout, 0, sizeof(AudioChannelLayout));
    channelLayout.mChannelLayoutTag = kAudioChannelLayoutTag_Stereo;
    NSDictionary *outputSettings = [NSDictionary dictionaryWithObjectsAndKeys:
                                    [NSNumber numberWithInt:kAudioFormatLinearPCM], AVFormatIDKey,
                                    [NSNumber numberWithFloat:44100.0], AVSampleRateKey,
                                    [NSNumber numberWithInt:2], AVNumberOfChannelsKey,
                                    [NSData dataWithBytes:&channelLayout length:sizeof(AudioChannelLayout)], AVChannelLayoutKey,
                                    [NSNumber numberWithInt:16], AVLinearPCMBitDepthKey,
                                    [NSNumber numberWithBool:NO], AVLinearPCMIsNonInterleaved,
                                    [NSNumber numberWithBool:NO],AVLinearPCMIsFloatKey,
                                    [NSNumber numberWithBool:NO], AVLinearPCMIsBigEndianKey,
                                    nil];
    AVAssetWriterInput *assetWriterInput = [AVAssetWriterInput assetWriterInputWithMediaType:AVMediaTypeAudio
                                                                              outputSettings:outputSettings];
    if ([assetWriter canAddInput:assetWriterInput]) {
        [assetWriter addInput:assetWriterInput];
    } else {
        NSLog (@"assetWriter can't add assetWriterInput ... die!");
        !completionHandler ? : completionHandler(nil, nil);
        return;
    }
    
    assetWriterInput.expectsMediaDataInRealTime = NO;
    
    [assetWriter startWriting];
    [assetReader startReading];
    
    AVAssetTrack *soundTrack = [asset.tracks objectAtIndex:0];
    CMTime startTime = CMTimeMake (0, soundTrack.naturalTimeScale);
    [assetWriter startSessionAtSourceTime: startTime];
    
    __block UInt64 convertedByteCount = 0;
    
    dispatch_queue_t mediaInputQueue = dispatch_queue_create("mediaInputQueue", NULL);
    [assetWriterInput requestMediaDataWhenReadyOnQueue:mediaInputQueue
                                            usingBlock: ^
     {
         // NSLog (@"top of block");
         while (assetWriterInput.readyForMoreMediaData) {
             CMSampleBufferRef nextBuffer = [assetReaderOutput copyNextSampleBuffer];
             if (nextBuffer) {
                 // append buffer
                 [assetWriterInput appendSampleBuffer: nextBuffer];
                 //             NSLog (@"appended a buffer (%d bytes)",
                 //                    CMSampleBufferGetTotalSampleSize (nextBuffer));
                 convertedByteCount += CMSampleBufferGetTotalSampleSize (nextBuffer);
             } else {
                 // done!
                 [assetWriterInput markAsFinished];
                 [assetWriter finishWriting];
                 [assetReader cancelReading];
                 NSDictionary *outputFileAttributes = [[NSFileManager defaultManager]
                                                       attributesOfItemAtPath:exportPath
                                                       error:nil];
                 NSLog (@"done. file size is %lld",
                        [outputFileAttributes fileSize]);
                 NSData *data = [CacheHelper getDataByFilePath:exportPath];
                 !completionHandler ? : completionHandler(data, exportPath);
                 // release a lot of stuff
                 break;
             }
         }
         
     }];
}
/*
 音频文件格式转换 通过 AVAssetExportSession 实现
 AVAssetExportSession 支持多种视频格式，但是音频格式的只支持.m4a(AVAssetExportPresetAppleM4A)
 */
#pragma mark 通过AVAssetExportSession支持多种视频格式但转音频格式只支持.m4a，不支持直接转mp3格式
- (void)convertToM4a:(NSString *)filePath newFolderName:(NSString *)newFolderName newFileName:(NSString *)newFileName completionHandler:(CompletionHandler)completionHandler
{
    NSURL *assetURL = [NSURL URLWithString:filePath];
    NSLog(@"assetPath:%@", assetURL.absoluteString);
    if (!assetURL) {
        NSLog(@"assetURL音频文件路径不存在");
        !completionHandler ? : completionHandler(nil, nil);
        return;
    }
    
    AVURLAsset *asset = [AVURLAsset URLAssetWithURL:assetURL options:nil];
    
    NSLog(@"allExportPresets: %@",[AVAssetExportSession allExportPresets]);
    NSLog(@"compatible presets for Asset: %@",[AVAssetExportSession exportPresetsCompatibleWithAsset:asset]);
    
    AVAssetExportSession *exporter = [[AVAssetExportSession alloc]
                                      initWithAsset:asset
                                      presetName:AVAssetExportPresetAppleM4A];
    NSLog (@"exporter supportedFileTypes: %@", exporter.supportedFileTypes);
    
    exporter.outputFileType = AVFileTypeAppleM4A;
    NSString *exportPath = [LPMusicManager getFilePathWithOriginFilePath:filePath newFolderName:TempCachePath newFileName:newFileName pathExtension:@"m4a"];
    NSURL* exportURL = [NSURL fileURLWithPath:exportPath];
    exporter.outputURL = exportURL;
    // do the export
    [exporter exportAsynchronouslyWithCompletionHandler:^
     {
         NSData *data = [NSData dataWithContentsOfFile:exportPath];
         switch (exporter.status) {
             case AVAssetExportSessionStatusFailed: {
                 // log error to text view
                 NSError *exportError = exporter.error;
                 NSLog (@"AVAssetExportSessionStatusFailed: %@", exportError);
                 break;
             }
             case AVAssetExportSessionStatusCompleted: {
                 NSDictionary *outputFileAttributes = [[NSFileManager defaultManager]
                                                       attributesOfItemAtPath:exportPath
                                                       error:nil];
                 NSLog (@"done. file size is %lld",
                        [outputFileAttributes fileSize]);
                 NSLog (@"AVAssetExportSessionStatusCompleted");
                 break;
             }
             case AVAssetExportSessionStatusUnknown: {
                 NSLog (@"AVAssetExportSessionStatusUnknown");
                 break;
             }
             case AVAssetExportSessionStatusExporting: {
                 NSLog (@"AVAssetExportSessionStatusExporting");
                 break;
             }
             case AVAssetExportSessionStatusCancelled: {
                 NSLog (@"AVAssetExportSessionStatusCancelled");
                 break;
             }
             case AVAssetExportSessionStatusWaiting: {
                 NSLog (@"AVAssetExportSessionStatusWaiting");
                 break;
             }
             default:
             {
                 NSLog (@"didn't get export status");
                 break;
             }
         }
         !completionHandler ? : completionHandler(data, exportPath);
     }];
}
#pragma mark 支持多种音频格式转mp3格式，通过lame这个mp3音频转换库实现
- (void)convertToMP3:(NSString *)filePath newFolderName:(NSString *)newFolderName newFileName:(NSString *)newFileName completionHandler:(CompletionHandler)completionHandler
{
    [ExtAudioConverter convertDefault:^(BOOL success, NSString *outputPath) {
        if (success) {
            NSData *data = [NSData dataWithContentsOfFile:outputPath];
            !completionHandler ? : completionHandler(data, outputPath);
        }
    } inputFile:filePath outputFile:nil];
}

- (void)convertToM4aThanToMP3:(NSString *)filePath newFolderName:(NSString *)newFolderName newFileName:(NSString *)newFileName completionHandler:(CompletionHandler)completionHandler
{
    [self convertToM4a:filePath newFolderName:nil newFileName:nil completionHandler:^(NSData * _Nullable data, NSString * _Nullable filePath) {
        [self convertToMP3:filePath newFolderName:nil newFileName:nil completionHandler:^(NSData * _Nullable data, NSString * _Nullable filePath) {
            !completionHandler ? : completionHandler(data, filePath);
        }];
    }];
}

#pragma mark - AVAudioPlayerDelegate
- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag
{
    NSLog(@"播放结束");
}
- (void)audioPlayerDecodeErrorDidOccur:(AVAudioPlayer *)player error:(NSError *)error
{
    NSLog(@"解码失败");
}

#pragma mark Tool
+ (NSString *)getFilePathWithOriginFilePath:(NSString *)originFilePath
                              newFolderName:(NSString *)newFolderName
                                newFileName:(NSString *)newFileName
                              pathExtension:(NSString *)pathExtension
{
    if (!newFolderName) {
        newFolderName = CachePath;
    }
    NSString *exportPath = [CacheHelper getNewFilePathWithOriginFilePath:originFilePath newFolderPath:newFolderName newFileName:newFileName pathExtension:pathExtension];
    if ([CacheHelper checkFileExist:exportPath]) {
        [CacheHelper deleteFileAtFilePath:exportPath];
    }
    return exportPath;
}

@end
