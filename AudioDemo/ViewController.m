//
//  ViewController.m
//  AudioDemo
//
//  Created by 朱志佳 on 2019/5/5.
//  Copyright © 2019 朱志佳. All rights reserved.
//

#import "ViewController.h"
#import "AudioManager.h"
#import "AudioExtManager.h"
#import "EncodeH264Manager.h"
#import "DecoderH246Manager.h"
#import "EncodeAACManager.h"
#import "DecodeAACManager.h"
#import "AudioAUGraphManager.h"
#import "AVAssetManager.h"

@interface ViewController ()

@property (nonatomic,strong) UIView *playView;

@property (nonatomic,strong) LYOpenGLView *playOpenGLView;

@property (nonatomic,strong) OpenGLView *mOpenGLView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (IBAction)AUPCMPlayStart:(id)sender {
    //注意：测试过其他播放其他音频格式的音频文件（如.aac,.m4a,.mp3 可以转码成功播放，但是播放效果完全不对，不知道是不是什么参数设置不对）
    NSString *file = AudioManager.sharedmanager.writeFile;
    file = [NSBundle.mainBundle pathForResource:@"AudioManager.pcm" ofType:nil];
    AudioManager.sharedmanager.file = file;
    if (![CacheHelper checkFileExist:AudioManager.sharedmanager.writeFile]) {
        NSLog(@"开始录制");
        [AudioManager.sharedmanager startWithAVAudioSessionCategory:AVAudioSessionCategoryRecord];
        return;
    }
    
    BOOL onlyPlayback = YES;
    if (onlyPlayback) {
        NSLog(@"开始播放");
        [AudioManager.sharedmanager startWithAVAudioSessionCategory:AVAudioSessionCategoryPlayback];
    }else {
        NSLog(@"测试播放伴奏+耳返");
        [AudioManager.sharedmanager startWithAVAudioSessionCategory:AVAudioSessionCategoryPlayAndRecord];
    }
}

- (IBAction)AUPCMPlayStop:(id)sender {
    [[AudioManager sharedmanager] stop];
}

- (IBAction)AUCommonResourcePlayStart:(id)sender {
    NSString *file = [[NSBundle mainBundle] pathForResource:@"ab.mp4" ofType:nil];//abc.pcm ab.mp4
    [AudioManager sharedmanager].file = file;
    [[AudioManager sharedmanager] startWithAVAudioSessionCategory:AVAudioSessionCategoryPlayback];
}
- (IBAction)AUCommonResourcePlayStop:(id)sender {
    [[AudioManager sharedmanager] stop];
}

- (IBAction)AUExtCommonResourcePlayStart:(id)sender {
    NSString *file = [[NSBundle mainBundle] pathForResource:@"ab.mp4" ofType:nil];//abc.pcm ab.mp4 (abcd.pcm转换后存储的原始音频数据)
    [AudioExtManager sharedmanager].file = file;
    [[AudioExtManager sharedmanager] startWithAVAudioSessionCategory:AVAudioSessionCategoryPlayback];
}
- (IBAction)AUExtCommonResourcePlayStop:(id)sender {
    [[AudioExtManager sharedmanager] stop];
}
- (IBAction)AUGraphStart:(id)sender {
    NSString *file = [[NSBundle mainBundle] pathForResource:@"ab.pcm" ofType:nil];
    [AudioAUGraphManager sharedmanager].file = file;
    [[AudioAUGraphManager sharedmanager] startWithAVAudioSessionCategory:AVAudioSessionCategoryPlayback];
}
- (IBAction)AUGraphStop:(id)sender {
    [[AudioAUGraphManager sharedmanager] stop];
}


- (IBAction)encodeH264Start:(id)sender {
    [self.view addSubview:self.playView];
    [self.view sendSubviewToBack:self.playView];
    [EncodeH264Manager sharedmanager].playView = self.playView;
    [[EncodeH264Manager sharedmanager] start];
}
- (IBAction)encodeH264Stop:(id)sender {
    [[EncodeH264Manager sharedmanager] stop];
}
- (IBAction)decodeH264Start:(id)sender {
    [self.view addSubview:self.playOpenGLView];
    [self.view sendSubviewToBack:self.playOpenGLView];
    [DecoderH246Manager sharedmanager].playView = self.playOpenGLView;
    [[DecoderH246Manager sharedmanager] start];
}
- (IBAction)decodeH264Stop:(id)sender {
    [[DecoderH246Manager sharedmanager] stop];
}

- (IBAction)encodeAACStart:(id)sender {
    [[EncodeAACManager sharedmanager] start];
}
- (IBAction)encodeAACStop:(id)sender {
    [[EncodeAACManager sharedmanager] stop];
}
- (IBAction)decodeAACStart:(id)sender {
    [[DecodeAACManager sharedmanager] start];
}
- (IBAction)decodeAACStop:(id)sender {
    [[DecodeAACManager sharedmanager] stop];
}

- (IBAction)systemSoundPlay:(id)sender {
     [[DecodeAACManager sharedmanager] play];
}

- (IBAction)AVAssetStart:(id)sender {
    [self.view addSubview:self.mOpenGLView];
    [self.view sendSubviewToBack:self.mOpenGLView];
    [AVAssetManager sharedmanager].mGLView = self.mOpenGLView;
    [AVAssetManager sharedmanager].loadAssetSuccess = ^(BOOL isSuccess) {
        if (isSuccess) {
            [[AVAssetManager sharedmanager] start];
        }
    };
    if([AVAssetManager sharedmanager].hasLoadAssetSuccess)
    {
        [[AVAssetManager sharedmanager] start];
    }
}

- (IBAction)AVAssetStop:(id)sender {
     [[AVAssetManager sharedmanager] stop];
}

- (UIView *)playView
{
    if (!_playView) {
        UIView *playView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 300, 300)];
        playView.bottom = self.view.bottom;
        _playView = playView;
    }
    return _playView;
}

- (LYOpenGLView *)playOpenGLView
{
    if (!_playOpenGLView) {
        LYOpenGLView *playView = [[LYOpenGLView alloc] initWithFrame:CGRectMake(0, 0, 300, 300)];
        playView.bottom = self.view.bottom;
        [playView setupGL];
        _playOpenGLView = playView;
    }
    return _playOpenGLView;
}

- (OpenGLView *)mOpenGLView
{
    if (!_mOpenGLView) {
        OpenGLView *playView = [[OpenGLView alloc] initWithFrame:CGRectMake(0, 0, 300, 300)];
        playView.bottom = self.view.bottom;
        [playView setupGL];
        _mOpenGLView = playView;
    }
    return _mOpenGLView;
}


@end
