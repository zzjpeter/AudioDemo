//
//  ViewController.m
//  AudioDemo
//
//  Created by 朱志佳 on 2019/5/5.
//  Copyright © 2019 朱志佳. All rights reserved.
//

#import "ViewController.h"
#import "AudioManager.h"
#import "AudioCommonManager.h"
#import "EncodeH264Manager.h"
#import "DecoderH246Manager.h"
#import "EncodeAACManager.h"
#import "DecodeAACManager.h"
#import "AVAssetManager.h"
#import "AVAudioRecorderVC.h"

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
        
    AudioManager.sharedmanager.isEnableExtendedService = NO;
    
    NSString *file = AudioManager.sharedmanager.writeFile;
    file = [NSBundle.mainBundle pathForResource:@"AudioManager.aac" ofType:nil];
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
        NSLog(@"测试播放+录制");
        [AudioManager.sharedmanager startWithAVAudioSessionCategory:AVAudioSessionCategoryPlayAndRecord];
    }
}

- (IBAction)AUPCMPlayStop:(id)sender {
    [[AudioManager sharedmanager] stop];
}


- (IBAction)AUGraphStart:(id)sender {
    NSString *file = [[NSBundle mainBundle] pathForResource:@"AudioManager.pcm" ofType:nil];
    AudioCommonManager.sharedmanager.audioCommonManagerType = AudioCommonManagerAUGraphType;
    AudioCommonManager.sharedmanager.file = file;
    [AudioCommonManager.sharedmanager startWithAVAudioSessionCategory:AVAudioSessionCategoryPlayAndRecord];//必须有录制类型否则崩溃【因为有mixUnit混音，没有录制就没有混音的源，会导致数据处理异常崩溃】
}
- (IBAction)AUGraphStop:(id)sender {
    [AudioCommonManager.sharedmanager stop];
}


- (IBAction)encodeH264Start:(id)sender {
    [self.view addSubview:self.playView];
    [self.view sendSubviewToBack:self.playView];
    
    CommonVideoConfiguration *configuration = [CommonVideoConfiguration defaultConfiguration];
    configuration.preview = self.playView;
    [[EncodeH264Manager sharedmanager] startWithConfiguration:configuration];
    
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

- (IBAction)jumpToAVAudioRecoderDemo:(id)sender {
    AVAudioRecorderVC *vc = [AVAudioRecorderVC new];
    [self.navigationController pushViewController:vc animated:YES];
}



@end
