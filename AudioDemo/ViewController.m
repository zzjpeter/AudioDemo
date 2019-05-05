//
//  ViewController.m
//  AudioDemo
//
//  Created by 朱志佳 on 2019/5/5.
//  Copyright © 2019 朱志佳. All rights reserved.
//

#import "ViewController.h"
#import "AudioManager.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (IBAction)recordAction:(id)sender {
    [[AudioManager sharedAudioManager] startRecoder];
}
- (IBAction)stopAction:(id)sender {
    [[AudioManager sharedAudioManager] stopRecoder];
}

@end
