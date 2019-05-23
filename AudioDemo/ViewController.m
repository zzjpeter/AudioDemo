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

@interface ViewController ()

@property (nonatomic,strong) UIView *playView;
@property (nonatomic,strong) LYOpenGLView *playOpenGLView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.view addSubview:self.playOpenGLView];
}

- (IBAction)recordAction:(id)sender {
    [[AudioManager sharedAudioManager] start];
}
- (IBAction)stopAction:(id)sender {
    [[AudioManager sharedAudioManager] stop];
}
- (IBAction)encodeH264Start:(id)sender {
    [self.view addSubview:self.playView];
    [EncodeH264Manager sharemanager].playView = self.playView;
    [[EncodeH264Manager sharemanager] start];
}
- (IBAction)encodeH264Stop:(id)sender {
    [[EncodeH264Manager sharemanager] stop];
}

- (IBAction)decodeH264Start:(id)sender {
    [self.view addSubview:self.playOpenGLView];
    [DecoderH246Manager sharemanager].playView = self.playOpenGLView;
    [[DecoderH246Manager sharemanager] start];
}
- (IBAction)decodeH264Stop:(id)sender {
    [[DecoderH246Manager sharemanager] stop];
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
