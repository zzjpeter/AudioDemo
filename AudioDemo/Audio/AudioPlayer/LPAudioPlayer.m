//
//  LPAudioPlayer.m
//  LesParkExplore
//
//  Created by cgh on 2018/11/13.
//

#import "LPAudioPlayer.h"
#import <AVFoundation/AVFoundation.h>

@implementation AudioModel


@end

@interface LPAudioPlayer() <AVAudioPlayerDelegate>

@property (nonatomic, strong) AVAudioPlayer * backPlayer;                       /** 背景音乐播放器*/

@property (nonatomic, strong) AVAudioPlayer * clickPlayer;                      /** 按钮音乐播放器*/

@property (nonatomic, strong) AVAudioPlayer * resultPlayer;                     /** 结果音乐播放器*/

@property (nonatomic, strong) NSOperationQueue * queue;                         /** 队列*/

@property (nonatomic, strong) AudioModel *lastBgAudioModel;                     /** 最后一次播放的背景音乐*/

@property (nonatomic, assign) BOOL needReplay;                                  /** 是否需要恢复播放*/


@end
@implementation LPAudioPlayer

+ (instancetype)sharedAudioPlayer {
    static LPAudioPlayer * audioPlayer = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        audioPlayer = [[LPAudioPlayer alloc] init];
    });
    return audioPlayer;
}

- (void)playBackGroundAudioWithAudioModel:(AudioModel *)audioModel {
    self.lastBgAudioModel = audioModel;
    // 先停止正在播放的
    [self stopBackGroundPlayer];
    
    @weakify(self);
    [self.queue addOperationWithBlock:^{
        @strongify(self);
        
        // 生成一个循环播放的播放器
        self.backPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL URLWithString:audioModel.filePath] error:nil];
        self.backPlayer.delegate = self;
        self.backPlayer.numberOfLoops = -1;
        self.backPlayer.meteringEnabled = YES;
        
        [self.backPlayer prepareToPlay];
        BOOL success = [self.backPlayer play];
        NSLog(@"背景音效播放%@",success ? @"成功" : @"失败");
    }];
}

- (void)replayBackGroundAudio {
    [self playBackGroundAudioWithAudioModel:self.lastBgAudioModel];
}

- (void)playClickAudioWithAudioModel:(AudioModel *)audioModel {
    
    // 先停止正在播放的
    [self stopClickPlayer];
    
    @weakify(self);
    [self.queue addOperationWithBlock:^{
        @strongify(self);
        
        // 生成一个循环播放的播放器
        self.clickPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL URLWithString:audioModel.filePath] error:nil];
        self.clickPlayer.delegate = self;
        self.clickPlayer.meteringEnabled = YES;
        [self.clickPlayer prepareToPlay];
        BOOL success = [self.clickPlayer play];
        NSLog(@"点击音效播放%@",success ? @"成功" : @"失败");
        
    }];
}

/** 播放结果音效, 调用同及参数按钮播放*/
- (void)playResultAudioWithAudioModel:(AudioModel *)audioModel {
    // 先停止正在播放的
    [self stopResultPlayer];
    @weakify(self);
    [self.queue addOperationWithBlock:^{
        @strongify(self);
        
        // 生成一个循环播放的播放器
        self.resultPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL URLWithString:audioModel.filePath] error:nil];
        self.resultPlayer.delegate = self;
        //self.resultPlayer.numberOfLoops = MAXFLOAT;
        self.resultPlayer.meteringEnabled = YES;
        [self.resultPlayer prepareToPlay];
        BOOL success = [self.resultPlayer play];
        NSLog(@"结果音效播放%@",success ? @"成功" : @"失败");
    }];
}

- (void)stopBackGroundPlayer {
    if (![self.backPlayer isPlaying]) return;
    [self.backPlayer stop];
    self.backPlayer = nil;
}

- (void)stopClickPlayer {
    if (![self.clickPlayer isPlaying]) return;
    [self.clickPlayer stop];
    self.clickPlayer = nil;
}

- (void)stopResultPlayer {
    if (![self.resultPlayer isPlaying]) return;
    [self.resultPlayer stop];
    self.resultPlayer = nil;
}

- (void)stopAllAudioPlayer {
    [self.queue cancelAllOperations];
    [self stopBackGroundPlayer];
    [self stopClickPlayer];
    [self stopResultPlayer];
}

- (BOOL)backPlayerIsPlaying {
    if (self.backPlayer) {
        return self.backPlayer.isPlaying;
    }
    return NO;
}

- (void)enterToBack {
    if (self.backPlayer.isPlaying) {
        [self.backPlayer pause];
        self.needReplay = YES;
    }
}

- (void)becomeFront {
    if (self.needReplay) {
        [self.backPlayer play];
        self.needReplay = NO;
    }
}


#pragma mark - AVAudioPlayerDelegate
- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag
{
    NSLog(@"音频文件播放结束");
}
- (void)audioPlayerDecodeErrorDidOccur:(AVAudioPlayer *)player error:(NSError *)error
{
    NSLog(@"音频文件解码失败");
}

#pragma mark - SetterAndGetter
- (NSOperationQueue *)queue {
    if (!_queue) {
        _queue = [[NSOperationQueue alloc] init];
        _queue.maxConcurrentOperationCount = 1;
    }
    return _queue;
}

@end
