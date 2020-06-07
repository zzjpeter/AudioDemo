//
//  LPMusicManager.h
//  AudioDemo
//
//  Created by 朱志佳 on 2019/8/21.
//  Copyright © 2019 朱志佳. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Music.h"
#import "LPMusicTool.h"
typedef void (^CompletionHandler)(NSData *_Nullable data, NSString *_Nullable filePath);

#import <MediaPlayer/MediaPlayer.h>
typedef void (^LPGeneralAuthorizationCompletion) (void);//授权回调

NS_ASSUME_NONNULL_BEGIN

@interface LPMusicManager : NSObject

SingleInterface(Manager)

+ (LPMusicMsgModel *)getMusicDetailMsgModelWithFilePath:(NSString *)filePath;

//AVAudioPlayer play (音频播放)
- (void)playByAVAudioPlayerWithPath:(NSString *_Nullable)filePath;

/*
 音频文件格式转换 通过AVURLAsset、AVAssetReader、AVAssetWriterInput、AVAssetTrack
 Available file types are: public.aiff-audio, public.3gpp, public.aifc-audio, com.apple.m4v-video, com.apple.m4a-audio, com.apple.coreaudio-format, public.mpeg-4, com.microsoft.waveform-audio, com.apple.quicktime-movie, org.3gpp.adaptive-multi-rate-audio'
 ！！不支持mp3格式
 */
#pragma mark 通过AVURLAsset、reader、writer转音频格式支持多种，但是不支持直接转mp3格式
- (void)convertToCaf:(NSString *_Nullable)filePath
       newFolderName:(NSString *_Nullable)newFolderName
         newFileName:(NSString *_Nullable)newFileName
   completionHandler:(CompletionHandler)completionHandler;
/*
 音频文件格式转换 通过 AVAssetExportSession 实现
 AVAssetExportSession 支持多种视频格式，但是音频格式的只支持.m4a(AVAssetExportPresetAppleM4A)
  ！！不支持mp3格式
 */
#pragma mark 通过AVAssetExportSession支持多种视频格式但转音频格式只支持.m4a，不支持直接转mp3格式
 - (void)convertToM4a:(NSString *_Nullable)filePath
        newFolderName:(NSString *_Nullable)newFolderName
          newFileName:(NSString *_Nullable)newFileName
    completionHandler:(CompletionHandler)completionHandler;
#pragma mark 支持多种音频格式转mp3格式，通过lame这个mp3音频转换库实现
- (void)convertToMP3:(NSString *_Nullable)filePath
       newFolderName:(NSString *_Nullable)newFolderName
         newFileName:(NSString *_Nullable)newFileName
   completionHandler:(CompletionHandler)completionHandler;
//先转.mp4再转.mp3
- (void)convertToM4aThanToMP3:(NSString *_Nullable)filePath
                newFolderName:(NSString *_Nullable)newFolderName
                  newFileName:(NSString *_Nullable)newFileName
            completionHandler:(CompletionHandler)completionHandler;

#pragma mark Tool
+ (NSString *)getFilePathWithOriginFilePath:(NSString *)originFilePath
                              newFolderName:(NSString *)newFolderName
                                newFileName:(NSString *)newFileName
                              pathExtension:(NSString *)pathExtension;
#pragma mark - Apple Music
- (void)p_requestAppleMusicAccessWithAuthorizedHandler:(LPGeneralAuthorizationCompletion)authorizedHandler
                                   unAuthorizedHandler:(LPGeneralAuthorizationCompletion)unAuthorizedHandler;

@end

NS_ASSUME_NONNULL_END
