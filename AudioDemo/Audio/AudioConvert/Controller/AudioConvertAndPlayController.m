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
    [[LPMusicManager sharedManager] convertToCaf:filePath newFolderName:nil newFileName:@"Caf" completionHandler:^(NSData * _Nullable data, NSString * _Nullable filePath) {
        if (data) {
            NSLog(@"当前线程:%@",[NSThread currentThread]);
            NSLog(@"destination assetPath:%@",filePath);
            dispatch_async(dispatch_get_main_queue(), ^{
                [[LPMusicManager sharedManager] playByAVAudioPlayerWithPath:filePath];;
            });
        }
    }];
}

- (IBAction)convertToM4a:(id)sender {
    NSArray<LPMusicMsgModel *> *musicMsgModels = [LPMusicTool getLocalMusicListMsgModel];
    LPMusicMsgModel *musicMsgModel = musicMsgModels.firstObject;
    NSString *filePath = musicMsgModel.musicPath;
    [[LPMusicManager sharedManager] convertToM4a:filePath newFolderName:nil newFileName:@"M4a" completionHandler:^(NSData * _Nullable data, NSString * _Nullable filePath) {
        if (data) {
            NSLog(@"当前线程:%@",[NSThread currentThread]);
            NSLog(@"destination assetPath:%@",filePath);
            dispatch_async(dispatch_get_main_queue(), ^{
                [[LPMusicManager sharedManager] playByAVAudioPlayerWithPath:filePath];;
            });
        }
    }];
}

- (IBAction)convertToMp3:(id)sender {
    [[LPMusicManager sharedManager] convertToMP3:nil newFolderName:nil newFileName:nil completionHandler:^(NSData * _Nullable data, NSString * _Nullable filePath) {
        if (data) {
            NSLog(@"当前线程:%@",[NSThread currentThread]);
            NSLog(@"destination assetPath:%@",filePath);
            dispatch_async(dispatch_get_main_queue(), ^{
                [[LPMusicManager sharedManager] playByAVAudioPlayerWithPath:filePath];;
            });
        }
    }];
}

- (IBAction)covertPcmToMp3:(id)sender {
    NSString *filePath = [NSBundle.mainBundle pathForResource:@"in.pcm" ofType:nil];
    [ExtAudioConverter convertToMp3:filePath outputFile:nil convertSuccess:^(BOOL success, NSString *filePath) {
        NSLog(@"当前线程:%@",[NSThread currentThread]);
        NSLog(@"destination assetPath:%@",filePath);
        dispatch_async(dispatch_get_main_queue(), ^{
            [[LPMusicManager sharedManager] playByAVAudioPlayerWithPath:filePath];;
        });
    }];
}

- (IBAction)convertToM4aThanToMp3:(id)sender {
    
    NSArray<LPMusicMsgModel *> *musicMsgModels = [LPMusicTool getLocalMusicListMsgModel];
    LPMusicMsgModel *musicMsgModel = musicMsgModels.firstObject;
    NSString *filePath = musicMsgModel.musicPath;
    [[LPMusicManager sharedManager] convertToM4aThanToMP3:filePath newFolderName:nil newFileName:nil completionHandler:^(NSData * _Nullable data, NSString * _Nullable filePath) {
        if (data) {
            NSLog(@"当前线程:%@",[NSThread currentThread]);
            NSLog(@"destination assetPath:%@",filePath);
            dispatch_async(dispatch_get_main_queue(), ^{
                [[LPMusicManager sharedManager] playByAVAudioPlayerWithPath:filePath];;
            });
        }
    }];
    
}


- (IBAction)playOriginMusic:(id)sender {
    NSString *outputPath = [[NSBundle mainBundle] pathForResource:kAudioName ofType:nil];
    dispatch_async(dispatch_get_main_queue(), ^{
        [[LPMusicManager sharedManager] playByAVAudioPlayerWithPath:outputPath];;
    });
}

- (IBAction)playMusicWithFileName
{
    NSString *outputPath = [[NSBundle mainBundle] pathForResource:@"忘不了曾经的你.mp3" ofType:nil];
    LPMusicMsgModel *model = [LPMusicManager getMusicDetailMsgModelWithFilePath:outputPath];
    NSLog(@"model:%@",model);
    [[LPMusicManager sharedManager] playByAVAudioPlayerWithPath:outputPath];;
}


@end

