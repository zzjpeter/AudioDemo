//
//  AVAudioRecorderVC.m
//  Voice
//
//  Created by wangfang on 2016/10/12.
//  Copyright © 2016年 onefboy. All rights reserved.
//

#import "AVAudioRecorderVC.h"
#import <AVFoundation/AVFoundation.h>

@interface AVAudioRecorderVC ()<AVAudioRecorderDelegate, AVAudioPlayerDelegate>

@property (strong, nonatomic) UIActivityIndicatorView *activityIndicatorView;
@property (strong, nonatomic) UILabel *recordingLabel;
@property (strong, nonatomic) UILabel *timeLabel;

@property (strong, nonatomic) UIButton *recordButton;// 开始录音按钮
@property (strong, nonatomic) UIButton *stopRecordButton;// 停止录音按钮

@property (strong, nonatomic) UIButton *playRecordButton;// 播放录音
@property (strong, nonatomic) UIButton *stopPlayRecordButton;// 停止播放录音

@property (strong, nonatomic) UIButton *playButton; //播放本地音频文件

@property (strong, nonatomic) AVAudioRecorder *audioRecorder;// 录音
@property (strong, nonatomic) AVAudioPlayer *player;// 只能播放本地文件，X流式媒体

@end

@implementation AVAudioRecorderVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.view.backgroundColor = UIColor.whiteColor;
    
    [self buildView];
    
    [self initAudioRecorder];
}

- (void)buildView {
    UIView *contentView = self.view;
    [contentView addSubview:self.activityIndicatorView];
    [self.activityIndicatorView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(100);
        make.centerX.equalTo(contentView);
    }];
    [contentView addSubview:self.recordingLabel];
    [self.recordingLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.activityIndicatorView.mas_bottom).offset(10);
        make.left.equalTo(contentView);
        make.width.equalTo(contentView);
        make.height.mas_equalTo(30);
    }];
    NSArray *btns = @[self.recordButton, self.stopRecordButton];
    NSArray *btns1 = @[self.playRecordButton, self.stopPlayRecordButton];
    for (UIButton *btn in btns) {
        [contentView addSubview:btn];
    }
    for (UIButton *btn in btns1) {
        [contentView addSubview:btn];
    }
    [btns mas_distributeViewsAlongAxis:MASAxisTypeHorizontal withFixedSpacing:20 leadSpacing:0 tailSpacing:0];
    [btns mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.recordingLabel.mas_bottom).offset(30);
        make.height.mas_equalTo(50);
    }];
    [btns1 mas_distributeViewsAlongAxis:MASAxisTypeHorizontal withFixedSpacing:20 leadSpacing:0 tailSpacing:0];
    [btns1 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.recordButton.mas_bottom).offset(30);
        make.height.mas_equalTo(50);
    }];
    [contentView addSubview:self.timeLabel];
    [self.timeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.playRecordButton.mas_bottom).offset(30);
        make.left.equalTo(contentView);
        make.width.equalTo(contentView);
        make.height.mas_equalTo(30);
    }];
    
    [contentView addSubview:self.playButton];
    [self.playButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.timeLabel.mas_bottom).offset(30);
        make.left.equalTo(contentView);
        make.width.equalTo(contentView);
        make.height.mas_equalTo(30);
    }];
    
    // 初始化
    [self.activityIndicatorView setHidden:YES];
    [self.recordingLabel setHidden:YES];
    [self.stopRecordButton setHidden:YES];
    [self.stopPlayRecordButton setHidden:YES];
    [self.timeLabel setHidden:YES];
}

#pragma mark 初始化AudioRecorder
- (void)initAudioRecorder {
    //----------------AVAudioRecorder----------------
    // 录音会话设置
    NSError *errorSession = nil;
    AVAudioSession * audioSession = AVAudioSession.sharedInstance; // 得到AVAudioSession单例对象
    [audioSession setCategory:AVAudioSessionCategoryPlayAndRecord error: &errorSession];// 设置类别,表示该应用同时支持播放和录音
    [audioSession setActive:YES error: &errorSession];// 启动音频会话管理,此时会阻断后台音乐的播放.
    
    // 设置成扬声器播放
    UInt32 doChangeDefault = 1;
    AudioSessionSetProperty(kAudioSessionProperty_OverrideCategoryDefaultToSpeaker, sizeof(doChangeDefault), &doChangeDefault);
    
    /*
     AVFormatIDKey  音频格式
     
     kAudioFormatLinearPCM
     kAudioFormatMPEG4AAC(AAC)
     kAudioFormatAppleLossless(ALAC)
     kAudioFormatAppleIMA4(IMA4)
     kAudioFormatiLBC
     kAudioFormatULaw
     
     指定kAudioFormatLinearPCM会将未压缩的音频流写入到文件中.这种格式保真度最高,不过相应的文件也最大.选择诸如kAudioFormatMPEG4AAC或者kAudioFormatAppleMA4的压缩格式会显著缩小文件,也能保证高质量的音频内容.
     
     注意,指定的音频格式一定要和URL参数定义的文件类型一致.否则会返回错误信息.
     */
    
    // 创建录音配置信息的字典
    NSDictionary *setting = @{
        AVFormatIDKey : @(kAudioFormatMPEG4AAC),// 音频格式
        AVSampleRateKey : @44100.0f,// 录音采样率(Hz) 如：AVSampleRateKey==8000/44100/96000（影响音频的质量）
        AVNumberOfChannelsKey : @1,// 音频通道数 1 或 2
        AVEncoderBitDepthHintKey : @16,// 线性音频的位深度 8、16、24、32
        AVEncoderAudioQualityKey : @(AVAudioQualityHigh)// 录音的质量
    };
    
    
    // 1.创建存放录音文件的地址（音频流写入文件的本地文件URL）
    NSURL *url = [NSURL URLWithString:[self filePath]];
    
    // 2.初始化 AVAudioRecorder 对象 //注意url的后缀 必须是苹果支持的文件格式后缀名，否则会导致AVAudioRecorder创建失败
    NSError *error;
    self.audioRecorder = [[AVAudioRecorder alloc] initWithURL:url settings:setting error:&error];
    
    if (self.audioRecorder) {
        
        self.audioRecorder.delegate = self;// 3.设置代理
        self.audioRecorder.meteringEnabled = YES;
        
        // 4.设置录音时长，超过这个时间后，会暂停 单位是 秒
        //    [self.audioRecorder recordForDuration:10];
        
        // 5.创建一个音频文件，并准备系统进行录制
        [self.audioRecorder prepareToRecord];
    } else {
        NSLog(@"Error: %@", [error localizedDescription]);
    }
}

#pragma mark - AVAudioRecorderDelegate

- (void)audioRecorderDidFinishRecording:(AVAudioRecorder *)recorder successfully:(BOOL)flag {
    
    NSLog(@"--- 录音结束 ---");
}

#pragma mark - AVAudioPlayerDelegate

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag {
    
    NSLog(@"--- 播放结束 ---");
    
    [self.playRecordButton setTitle:@"播放录音" forState:UIControlStateNormal];
    
    [self.recordingLabel setHidden:YES];
    [self.activityIndicatorView setHidden:YES];
    [self.stopPlayRecordButton setHidden:YES];
    [self.timeLabel setHidden:YES];
}

#pragma mark action
#pragma mark 开始/暂停录音
// 开始/暂停录音
- (void)record:(id)sender {
    
    // 录音前先判断是否正在播放录音
    if ([self.player isPlaying]) {
        [self.player stop];
        [self.playRecordButton setTitle:@"播放录音" forState:UIControlStateNormal];
        
        [self.recordingLabel setHidden:YES];
        [self.activityIndicatorView setHidden:YES];
        [self.stopPlayRecordButton setHidden:YES];
    }
    
    // 判断是否正在录音中
    if (![self.audioRecorder isRecording]) {
        // 开始暂停录音
        [self.audioRecorder record];
        [self.recordButton setTitle:@"暂停录音" forState:UIControlStateNormal];
        
        [self.activityIndicatorView startAnimating];
        
        [self.recordingLabel setText:@"录音中..."];
    } else {
        // 暂停录音
        [self.audioRecorder pause];
        [self.recordButton setTitle:@"开始录音" forState:UIControlStateNormal];
        
        [self.activityIndicatorView stopAnimating];
        
        [self.recordingLabel setText:@"录音暂停"];
    }
    
    [self.recordingLabel setHidden:NO];
    [self.activityIndicatorView setHidden:NO];
    [self.stopRecordButton setHidden:NO];
}

#pragma mark 结束录音
// 结束录音
- (void)stopRecord:(id)sender {
    
    // 停止录制并关闭音频文件
    [self.audioRecorder stop];
    [self.recordButton setTitle:@"开始录音" forState:UIControlStateNormal];
    
    [self.activityIndicatorView stopAnimating];
    [self.recordingLabel setHidden:YES];
    [self.activityIndicatorView setHidden:YES];
    [self.stopRecordButton setHidden:YES];
}

#pragma mark 播放录音
// 播放录音
- (void)playRecord:(id)sender {
    
    // 播放前先判断是否正在录音
    if ([self.audioRecorder isRecording]) {
        [self.audioRecorder stop];
        [self.recordButton setTitle:@"开始录音" forState:UIControlStateNormal];
        
        [self.activityIndicatorView stopAnimating];
        [self.recordingLabel setHidden:YES];
        [self.activityIndicatorView setHidden:YES];
        [self.stopRecordButton setHidden:YES];
    }
    
    //----------------AVAudioPlayer----------------
    NSError *playerError;
    self.player = [[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL fileURLWithPath:[self filePath]] error:&playerError];
    
    if (self.player) {
        
        // 设置播放循环次数
        [self.player setNumberOfLoops:0];
        
        // 音量，0-1之间
        [self.player setVolume:1];
        
        [self.player setDelegate:self];
        
        // 分配播放所需的资源，并将其加入内部播放队列
        [self.player prepareToPlay];
    } else {
        NSLog(@"Error: %@", [playerError localizedDescription]);
    }
    
    
    // 判断是否正在播放录音中
    if (![self.player isPlaying]) {
        // 开始播放录音
        [self.player play];
        [self.playRecordButton setTitle:@"暂停播放" forState:UIControlStateNormal];
        
        [self.activityIndicatorView startAnimating];
        
        [self.recordingLabel setText:@"播放中..."];
    } else {
        // 暂停播放录音
        [self.player pause];
        [self.playRecordButton setTitle:@"播放录音" forState:UIControlStateNormal];
        
        [self.activityIndicatorView stopAnimating];
        
        [self.recordingLabel setText:@"播放暂停"];
    }
    
    self.timeLabel.text = [NSString stringWithFormat:@"音频时长：%f秒", self.player.duration];
    
    [self.recordingLabel setHidden:NO];
    [self.activityIndicatorView setHidden:NO];
    [self.stopPlayRecordButton setHidden:NO];
    [self.timeLabel setHidden:NO];
}

#pragma mark 结束播放录音
// 停止播放录音
- (void)stopPlayRecord:(id)sender {
    [self.player stop];
    [self.playRecordButton setTitle:@"播放录音" forState:UIControlStateNormal];
    
    [self.recordingLabel setHidden:YES];
    [self.activityIndicatorView setHidden:YES];
    [self.stopPlayRecordButton setHidden:YES];
    [self.timeLabel setHidden:YES];
}

#pragma mark 播放
- (void)playMusic:(id)sender {
    
    // 播放前先判断是否正在录音
    if ([self.audioRecorder isRecording]) {
        [self.audioRecorder stop];
        [self.recordButton setTitle:@"开始录音" forState:UIControlStateNormal];
        
        [self.activityIndicatorView stopAnimating];
        [self.recordingLabel setHidden:YES];
        [self.activityIndicatorView setHidden:YES];
        [self.stopRecordButton setHidden:YES];
    }
    
    NSString *path = [[NSBundle mainBundle] pathForResource:@"ab.mp3" ofType:nil];
    
    NSError *playerError;
    self.player = [[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL fileURLWithPath:path] error:&playerError];
    
    if (self.player) {
        
        // 设置播放循环次数
        [self.player setNumberOfLoops:0];
        
        // 音量，0-1之间
        [self.player setVolume:1];
        
        [self.player setDelegate:self];
        
        // 分配播放所需的资源，并将其加入内部播放队列
        [self.player prepareToPlay];
    } else {
        NSLog(@"Error: %@", [playerError localizedDescription]);
    }
    
    [self.player play];
    
    [self.activityIndicatorView startAnimating];
    
    self.timeLabel.text = [NSString stringWithFormat:@"音频时长：%f秒", self.player.duration];
    
    [self.recordingLabel setText:@"播放中..."];
    
    [self.recordingLabel setHidden:NO];
    [self.activityIndicatorView setHidden:NO];
    [self.stopPlayRecordButton setHidden:NO];
    [self.timeLabel setHidden:NO];
    
}

#pragma mark - getter
#pragma mark 文件路径
// 获取沙盒路径
- (NSString *)filePath {
    NSString *path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    NSString *filePath = [path stringByAppendingPathComponent:@"voice.caf"];
    return filePath;
}

#pragma mark setter/getter
- (UIActivityIndicatorView *)activityIndicatorView {
    if (!_activityIndicatorView) {
        UIActivityIndicatorView *view = ({
            UIActivityIndicatorView *view = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
            view;
        });
        _activityIndicatorView = view;
    }
    return _activityIndicatorView;
}

- (UILabel *)recordingLabel {
    if (!_recordingLabel) {
        UILabel *label = ({
            UILabel *label = [UILabel new];
            label.text = @"录音中...";
            label.font = [UIFont systemFontOfSize:14.0 weight:UIFontWeightRegular];
            label.textColor = UIColorFromRGB(0xAAAAAA);
            label.textAlignment = NSTextAlignmentCenter;
            label;
        });
        _recordingLabel = label;
    }
    return _recordingLabel;
}

- (UIButton *)recordButton {
    if (!_recordButton) {
        UIButton *btn = ({
            UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
            [btn setTitle:@"开始录音" forState:UIControlStateNormal];
            btn.titleLabel.font = [UIFont systemFontOfSize:14.0 weight:UIFontWeightRegular];
            [btn setTitleColor:UIColorFromRGB(0xAAAAAA) forState:UIControlStateNormal];
            btn.backgroundColor = UIColorFromRGB(0xFFFFFF);
            btn.layer.cornerRadius = 0.0;
            [btn addTarget:self action:@selector(record:) forControlEvents:UIControlEventTouchUpInside];
            //btn.adjustsImageWhenHighlighted = NO;
            btn;
        });
        _recordButton = btn;
    }
    return _recordButton;
}

- (UIButton *)stopRecordButton {
    if (!_stopRecordButton) {
        UIButton *btn = ({
            UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
            [btn setTitle:@"停止录音" forState:UIControlStateNormal];
            btn.titleLabel.font = [UIFont systemFontOfSize:14.0 weight:UIFontWeightRegular];
            [btn setTitleColor:UIColorFromRGB(0xAAAAAA) forState:UIControlStateNormal];
            btn.backgroundColor = UIColorFromRGB(0xFFFFFF);
            btn.layer.cornerRadius = 0.0;
            [btn addTarget:self action:@selector(stopRecord:) forControlEvents:UIControlEventTouchUpInside];
            //btn.adjustsImageWhenHighlighted = NO;
            btn;
        });
        _stopRecordButton = btn;
    }
    return _stopRecordButton;
}

- (UIButton *)playRecordButton {
    if (!_playRecordButton) {
        UIButton *btn = ({
            UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
            [btn setTitle:@"播放录音" forState:UIControlStateNormal];
            btn.titleLabel.font = [UIFont systemFontOfSize:14.0 weight:UIFontWeightRegular];
            [btn setTitleColor:UIColorFromRGB(0xAAAAAA) forState:UIControlStateNormal];
            btn.backgroundColor = UIColorFromRGB(0xFFFFFF);
            btn.layer.cornerRadius = 0.0;
            [btn addTarget:self action:@selector(playRecord:) forControlEvents:UIControlEventTouchUpInside];
            //btn.adjustsImageWhenHighlighted = NO;
            btn;
        });
        _playRecordButton = btn;
    }
    return _playRecordButton;
}

- (UIButton *)stopPlayRecordButton {
    if (!_stopPlayRecordButton) {
        UIButton *btn = ({
            UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
            [btn setTitle:@"结束播放" forState:UIControlStateNormal];
            btn.titleLabel.font = [UIFont systemFontOfSize:14.0 weight:UIFontWeightRegular];
            [btn setTitleColor:UIColorFromRGB(0xAAAAAA) forState:UIControlStateNormal];
            btn.backgroundColor = UIColorFromRGB(0xFFFFFF);
            btn.layer.cornerRadius = 0.0;
            [btn addTarget:self action:@selector(stopPlayRecord:) forControlEvents:UIControlEventTouchUpInside];
            //btn.adjustsImageWhenHighlighted = NO;
            btn;
        });
        _stopPlayRecordButton = btn;
    }
    return _stopPlayRecordButton;
}

- (UIButton *)playButton {
    if (!_playButton) {
        UIButton *btn = ({
            UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
            [btn setTitle:@"播放本地音频" forState:UIControlStateNormal];
            btn.titleLabel.font = [UIFont systemFontOfSize:14.0 weight:UIFontWeightRegular];
            [btn setTitleColor:UIColorFromRGB(0xAAAAAA) forState:UIControlStateNormal];
            btn.backgroundColor = UIColorFromRGB(0xFFFFFF);
            btn.layer.cornerRadius = 0.0;
            [btn addTarget:self action:@selector(playMusic:) forControlEvents:UIControlEventTouchUpInside];
            //btn.adjustsImageWhenHighlighted = NO;
            btn;
        });
        _playButton = btn;
    }
    return _playButton;
}

- (UILabel *)timeLabel {
    if (!_timeLabel) {
        UILabel *label = ({
            UILabel *label = [UILabel new];
            label.text = @"时间:";
            label.font = [UIFont systemFontOfSize:14.0 weight:UIFontWeightRegular];
            label.textColor = UIColorFromRGB(0xAAAAAA);
            label.textAlignment = NSTextAlignmentCenter;
            label;
        });
        _timeLabel = label;
    }
    return _timeLabel;
}



@end

