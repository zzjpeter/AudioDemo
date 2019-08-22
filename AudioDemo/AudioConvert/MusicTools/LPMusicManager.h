//
//  LPMusicManager.h
//  AudioDemo
//
//  Created by 朱志佳 on 2019/8/21.
//  Copyright © 2019 朱志佳. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AVHeader.h"

typedef void (^CompletionHandler)(NSData *_Nullable data);

NS_ASSUME_NONNULL_BEGIN

@interface LPMusicManager : NSObject

SingleInterface(manager)

//AVAudioPlayer play (音频播放)
- (void)playByAVAudioPlayerWithPath:(NSString *)filePath;

//音频文件格式转换 通过AVURLAsset、AVAssetReader、AVAssetWriterInput、AVAssetTrack
- (void)convertToCAF:(NSString *)filePath completionHandler:(CompletionHandler)completionHandler;
//音频文件格式转换

@end

NS_ASSUME_NONNULL_END
