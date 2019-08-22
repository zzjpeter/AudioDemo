//
//  AudioConvertAndPlayController.m
//  AudioDemo
//
//  Created by 朱志佳 on 2019/8/21.
//  Copyright © 2019 朱志佳. All rights reserved.
//

#import "AudioConvertAndPlayController.h"
#import "LPMusicManager.h"
#import "LPMusicTool.h"
#import "ExtAudioConverter.h"

@interface AudioConvertAndPlayController ()

@end

@implementation AudioConvertAndPlayController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.title = @"音频转码和简单播放demo";
}

- (IBAction)convertToCaf:(id)sender {
    NSArray<LPMusicMsgModel *> *musicMsgModels = [LPMusicTool getLocalMusicListMsgModel];
    LPMusicMsgModel *musicMsgModel = musicMsgModels.firstObject;
    NSString *filePath = musicMsgModel.musicPath;
    [[LPMusicManager sharedManager] convertToCaf:filePath completionHandler:^(NSData * _Nullable data, NSString * _Nullable filePath) {
        if (data) {
            [[LPMusicManager sharedManager] playByAVAudioPlayerWithPath:filePath];
        }
    }];
}

- (IBAction)convertToM4a:(id)sender {
    NSArray<LPMusicMsgModel *> *musicMsgModels = [LPMusicTool getLocalMusicListMsgModel];
    LPMusicMsgModel *musicMsgModel = musicMsgModels.firstObject;
    NSString *filePath = musicMsgModel.musicPath;
    [[LPMusicManager sharedManager] convertToM4a:filePath completionHandler:^(NSData * _Nullable data, NSString * _Nullable filePath) {
        if (data) {
            [[LPMusicManager sharedManager] playByAVAudioPlayerWithPath:filePath];
        }
    }];
}

- (IBAction)convertToMp3:(id)sender {
    [ExtAudioConverter convertDefault:^(BOOL success, NSString *outputPath) {
        if (success) {
            NSLog(@"当前线程:%@###文件转换格式后路径:%@",[NSThread currentThread],outputPath);
            dispatch_async(dispatch_get_main_queue(), ^{
                [[LPMusicManager sharedManager] playByAVAudioPlayerWithPath:outputPath];;
            });
        }
    } inputFile:nil];
}

- (IBAction)playOriginMusic:(id)sender {
    NSString *outputPath = [[NSBundle mainBundle] pathForResource:kAudioName ofType:nil];
    dispatch_async(dispatch_get_main_queue(), ^{
        [[LPMusicManager sharedManager] playByAVAudioPlayerWithPath:outputPath];;
    });
}

@end

