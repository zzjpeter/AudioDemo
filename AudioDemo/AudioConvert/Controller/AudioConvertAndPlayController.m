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


@end
