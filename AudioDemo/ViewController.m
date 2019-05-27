//
//  ViewController.m
//  AudioDemo
//
//  Created by 朱志佳 on 2019/5/5.
//  Copyright © 2019 朱志佳. All rights reserved.
//

#import "ViewController.h"
#import "AudioManager.h"
#import "EncodeH264Manager.h"
#import "DecoderH246Manager.h"
#import "EncodeAACManager.h"
#import "DecodeAACManager.h"

@interface ViewController ()

@property (nonatomic,strong) UIView *playView;
@property (nonatomic,strong) LYOpenGLView *playOpenGLView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
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

- (IBAction)recordAction:(id)sender {
    [[AudioManager sharedmanager] startWithAVAudioSessionCategory:AVAudioSessionCategoryRecord];
}
- (IBAction)stopAction:(id)sender {
    [[AudioManager sharedmanager] stop];
}
- (IBAction)systemSoundPlay:(id)sender {
     [[DecodeAACManager sharedmanager] play];
}

- (IBAction)AUPCMPlayStart:(id)sender {
    //[[AudioManager sharedmanager] start];
    [AudioManager sharedmanager].file = [CacheHelper pathForCommonFile:@"abcd.pcm" withType:0];
    [[AudioManager sharedmanager] startWithAVAudioSessionCategory:AVAudioSessionCategoryPlayback];
}
- (IBAction)AUPCMPlayStop:(id)sender {
    [[AudioManager sharedmanager] stop];
}

- (IBAction)AUCommonResourcePlayStart:(id)sender {
    NSString *file = [[NSBundle mainBundle] pathForResource:@"ab.mp4" ofType:nil];
    [AudioManager sharedmanager].file = file;
    [[AudioManager sharedmanager] startWithAVAudioSessionCategory:AVAudioSessionCategoryPlayback];
}
- (IBAction)AUCommonResourcePlayStop:(id)sender {
    [[AudioManager sharedmanager] stop];
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

@end
