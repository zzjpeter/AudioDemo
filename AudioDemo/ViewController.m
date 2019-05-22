//
//  ViewController.m
//  AudioDemo
//
//  Created by 朱志佳 on 2019/5/5.
//  Copyright © 2019 朱志佳. All rights reserved.
//

#import "ViewController.h"
#import "AudioManager.h"
#import "AudioEncodeH264Manager.h"

@interface ViewController ()

@property (nonatomic,strong) UIView *playView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (IBAction)recordAction:(id)sender {
    [[AudioManager sharedAudioManager] start];
}
- (IBAction)stopAction:(id)sender {
    [[AudioManager sharedAudioManager] stop];
}
- (IBAction)encodeH264Start:(id)sender {
    [self.view addSubview:self.playView];
    [AudioEncodeH264Manager sharemanager].playView = self.playView;
    [[AudioEncodeH264Manager sharemanager] play];
}
- (IBAction)encodeH264Stop:(id)sender {
    [[AudioEncodeH264Manager sharemanager] stop];
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

@end
