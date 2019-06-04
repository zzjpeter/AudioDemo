//
//  AudioSampleManager.h
//  AudioDemo
//
//  Created by 朱志佳 on 2019/5/5.
//  Copyright © 2019 朱志佳. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AVHeader.h"
NS_ASSUME_NONNULL_BEGIN
@class AudioSampleManager;
@protocol AudioManagerDelegate <NSObject>

- (AudioBufferList *)onRequestAudioData;
- (void)onPlayToEnd:(AudioSampleManager *)AudioSampleManager;

@end

@interface AudioSampleManager : NSObject

@property (nonatomic, weak) id<AudioManagerDelegate> delegate;

SingleInterface(manager)
@property (nonatomic,copy)NSString *file;//写入 或者 读取文件的路径
@property (nonatomic,assign)BOOL isReadNeedConvert;//音频播放是否需要格式转换（注意：audio unit 默认是只支持pcm数据音频文件，需要播放其他格式数据文件如.mp3的就需要 转码数据格式convert 到pcm）
@property (nonatomic,copy)NSString *convertFile;//读取的音频文件数据 转换格式后 写入的路径 自定义的。

@property (nonatomic,assign) BOOL isPlayBackDataFromDelegate;//从代理中获取播放数据。

//录制和播放 通过audioSessionCategory 参数设置
- (void)startWithAVAudioSessionCategory:(AVAudioSessionCategory)audioSessionCategory;
- (void)start;
- (void)stop;
- (void)finished;
- (double)getCurrentTime;
@end

NS_ASSUME_NONNULL_END
