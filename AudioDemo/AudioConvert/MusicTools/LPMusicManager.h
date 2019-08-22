//
//  LPMusicManager.h
//  AudioDemo
//
//  Created by 朱志佳 on 2019/8/21.
//  Copyright © 2019 朱志佳. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AVHeader.h"

typedef void (^CompletionHandler)(NSData *_Nullable data, NSString *_Nullable filePath);

NS_ASSUME_NONNULL_BEGIN

@interface LPMusicManager : NSObject

SingleInterface(Manager)

//AVAudioPlayer play (音频播放)
- (void)playByAVAudioPlayerWithPath:(NSString *)filePath;

/*
 音频文件格式转换 通过AVURLAsset、AVAssetReader、AVAssetWriterInput、AVAssetTrack
 Available file types are: public.aiff-audio, public.3gpp, public.aifc-audio, com.apple.m4v-video, com.apple.m4a-audio, com.apple.coreaudio-format, public.mpeg-4, com.microsoft.waveform-audio, com.apple.quicktime-movie, org.3gpp.adaptive-multi-rate-audio'
 ！！不支持mp3格式
 */
- (void)convertToCaf:(NSString *)filePath completionHandler:(CompletionHandler)completionHandler;
/*
 音频文件格式转换 通过 AVAssetExportSession 实现
 AVAssetExportSession 支持多种视频格式，但是音频格式的只支持.m4a(AVAssetExportPresetAppleM4A)
  ！！不支持mp3格式
 */
- (void)convertToM4a:(NSString *)filePath completionHandler:(CompletionHandler)completionHandler;

@end

NS_ASSUME_NONNULL_END
