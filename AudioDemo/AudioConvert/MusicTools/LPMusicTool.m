//
//  LPMusicTool.m
//  HeadPhone
//
//  Created by 王刚 on 2018/3/14.
//  Copyright © 2018年 iOS-iMac. All rights reserved.
//

#import "LPMusicTool.h"
#import <AVFoundation/AVAsset.h>
#import <AVFoundation/AVMetadataItem.h>
#import <MediaPlayer/MediaPlayer.h>
#import "LPMusicMsgModel.h"

@implementation LPMusicTool

+(NSMutableArray<LPMusicMsgModel *> *)getLocalMusicListMsgModel
{
    NSArray *localMusicList = [self getLocalMusicListMsg];
    NSMutableArray *arrayM = [NSMutableArray new];
    for (NSDictionary *dictMusicMsg in localMusicList) {
        LPMusicMsgModel * model = [[LPMusicMsgModel alloc] initWithDict:[dictMusicMsg mutableCopy]];
        [arrayM addObject:model];
    }
    return arrayM;
}

+(NSArray *)getLocalMusicListMsg{
    NSMutableArray * arrResult = [[NSMutableArray alloc] init];
    //从iPod库读取音乐文件
    MPMediaQuery * mediaQuery = [[MPMediaQuery alloc] init];
    //读取文件
    MPMediaPropertyPredicate * albumNamePredicate = [MPMediaPropertyPredicate predicateWithValue:[NSNumber numberWithInt:MPMediaTypeMusic] forProperty:MPMediaItemPropertyMediaType];
    [mediaQuery addFilterPredicate:albumNamePredicate];

    NSArray * itemsFromGenericQuery = [mediaQuery items];

    for (MPMediaItem * song in itemsFromGenericQuery) {
        NSString * songTitle = [song valueForKey:MPMediaItemPropertyTitle];
        NSString * songPath = [song valueForKey:MPMediaItemPropertyAssetURL];
        NSURL *songUrl = song.assetURL;
        NSString * songArtist = [song valueForKey:MPMediaItemPropertyArtist];
        NSString * songAlbum = [song valueForKey:MPMediaItemPropertyAlbumTitle];
        //歌曲插图（如果没有插图，则返回nil）
        MPMediaItemArtwork * artwork = [song valueForProperty: MPMediaItemPropertyArtwork];
        //歌曲时长
        NSNumber * duration = [NSNumber numberWithDouble:[[song valueForProperty:MPMediaItemPropertyPlaybackDuration] doubleValue]];
        int second = [duration intValue];
        NSString *songDurationSeconds = [NSString stringWithFormat:@"%d", second];
        NSString * songDuration = [NSString stringWithFormat:@"%d:%d",second/60,second%60];
        //获取歌曲大小属性，方法待确认
        
        if (songArtist == nil) {
            songArtist = @"未知歌手";
        }
        if (artwork) {
            NSLog(@"\n%@\n%@\n%@\n%@\n%@\n---------------------------",songTitle,songPath,songArtist,songAlbum,songDuration);
            NSDictionary * dict = @{keyForSongTitle:songTitle,
                                    keyForSongDuration:songDuration,
                                    keyForSongDurationSeconds:songDurationSeconds,
                                    keyForSongPath:songUrl,
                                    keyForSongArtist:songArtist,
                                    keyForSongAlbum:songAlbum,
                                    keyForSongPicture:artwork,
                                    keyForSongSize:@""
                                    };
            [arrResult addObject:dict];
        }else{
            NSDictionary * dict = @{keyForSongTitle:songTitle,
                                    keyForSongDuration:songDuration,
                                    keyForSongDurationSeconds:songDurationSeconds,
                                    keyForSongPath:songUrl,
                                    keyForSongArtist:songArtist,
                                    keyForSongAlbum:songAlbum,
                                    keyForSongSize:@""
                                    };
            [arrResult addObject:dict];
        }
    }
    return [arrResult copy];
}

+(NSArray *)getDucumentMusicListMsg{
    //初始化返回数组
    NSMutableArray * arrResult = [[NSMutableArray alloc] init];
    //文件管理器
    NSFileManager * fileManager = [NSFileManager defaultManager];
    //获取沙盒路径
    NSArray * documentPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString * documentPath = [documentPaths objectAtIndex:0];
    //获取所有documentPath路径下的所有子文件名
    NSError * err = nil;
    NSArray * arrFilesName = [fileManager contentsOfDirectoryAtPath:documentPath error:&err];
    //遍历数组，先获取到子文件路径，再根据子文件路径获取到文件的所有信息
    for (int i = 0; i<arrFilesName.count; i++) {
        //子文件名
        NSString * subFileName = arrFilesName[i];
        //子文件路径
        NSString * subFilePath = [documentPath stringByAppendingPathComponent:subFileName];
        //首先识别文件格式，获取歌曲其他信息
        if ([subFileName containsString:@"mp3"]) {
            NSDictionary * dictMusicMsg = [self getMusicDetailMsgWithFilePath:subFilePath fileManager:fileManager];
            LPMusicMsgModel * model = [[LPMusicMsgModel alloc] initWithDict:[dictMusicMsg mutableCopy]];
            [arrResult addObject:model];
        }
    }
    return arrResult;
}

+(LPMusicMsgModel *)getMusicDetailMsgModelWithFilePath:(NSString *)filePath
{
    NSFileManager * fileManager = [NSFileManager defaultManager];
    NSDictionary * dictMusicMsg = [self getMusicDetailMsgWithFilePath:filePath fileManager:fileManager];
    LPMusicMsgModel * model = [[LPMusicMsgModel alloc] initWithDict:[dictMusicMsg mutableCopy]];
    return model;
}

+(NSDictionary *)getMusicDetailMsgWithFilePath:(NSString *)filePath fileManager:(NSFileManager *)fileManager{
    filePath = [filePath stringByURLEncode];
    //路径地址
    NSURL * musicURL = [NSURL fileURLWithPath:filePath];
    //根据路径地址获取AVURLAsset对象
    AVURLAsset * musicAsset = [AVURLAsset URLAssetWithURL:musicURL options:nil];
    //初始化存储音乐文件信息的字典
    NSMutableDictionary * msgInfoDict = [[NSMutableDictionary alloc] init];
    //--存储歌曲时长--
    CMTime duration = musicAsset.duration;
    float musicDurationSeconds = CMTimeGetSeconds(duration);
    int minute = (int)musicDurationSeconds/60;
    int second = (int)musicDurationSeconds%60;
    NSString * musicDuration = [NSString stringWithFormat:@"%d:%d",minute,second];
    NSString * musicDurationSecondsStr = [NSString stringWithFormat:@"%lf",musicDurationSeconds];
    [msgInfoDict setObject:musicDuration forKey:keyForSongDuration];
    [msgInfoDict setObject:musicDurationSecondsStr forKey:keyForSongDurationSeconds];
    //--存储歌曲路径--
    [msgInfoDict setObject:filePath forKey:keyForSongPath];
    //获取文件中数据格式类型
    for (NSString * format in [musicAsset availableMetadataFormats]) {
        //获取特定格式类型
        for (AVMetadataItem * metadataItem in [musicAsset metadataForFormat:format]) {
            if ([metadataItem.commonKey isEqualToString:@"artwork"]){
//                //或略图如果没有会获取不到造成崩溃
//                NSString * mime = [(NSDictionary *)metadataItem.value objectForKey:@"MIME"];
//                NSLog(@"mime: %@",mime);
//
//                [infoDict setObject:mime forKey:@"artwork"];
            }
            else if([metadataItem.commonKey isEqualToString:@"title"]){
                NSString * title = (NSString *)metadataItem.value;
                //--存储音乐名--
                [msgInfoDict setObject:title forKey:keyForSongTitle];
            }
            else if([metadataItem.commonKey isEqualToString:@"artist"]){
                NSString *artist = (NSString *)metadataItem.value;
                //--存储歌手--
                [msgInfoDict setObject:artist forKey:keyForSongArtist];
            }
            else if([metadataItem.commonKey isEqualToString:@"albumName"]){
                NSString *albumName = (NSString *)metadataItem.value;
                //--存储音乐集--
                [msgInfoDict setObject:albumName forKey:keyForSongAlbum];
            }
        }
    }
    if (!fileManager) {
        fileManager = [NSFileManager defaultManager];
    }
    //文件其他信息
    NSDictionary * dictItems = [fileManager attributesOfItemAtPath:filePath error:nil];
    //歌曲大小，单位bytes
    NSString * fileSize = [NSString stringWithFormat:@"%@",dictItems[@"NSFileSize"]];
    float musicSize = [fileSize intValue];
    //1G == 1024 M == 1024*1024 K == 1024*1024*1024 byte
    musicSize = musicSize / (1024*1024);
    [msgInfoDict setObject:[NSString stringWithFormat:@"%.1f",musicSize] forKey:keyForSongSize];
    //返回歌曲详情字典
    return msgInfoDict;
}

+(NSArray *)getApplicationMusicListMsg{
    NSMutableArray * arrResult = [[NSMutableArray alloc] init];
    //文件管理器
    NSFileManager * fileManager = [NSFileManager defaultManager];
    //获取音乐数组
    NSArray * musicArray = [NSBundle pathsForResourcesOfType:@"mp3" inDirectory:[[NSBundle mainBundle] resourcePath]];
    for (NSString * musicPath in musicArray) {
        NSDictionary * dictMusicMsg = [self getMusicDetailMsgWithFilePath:musicPath fileManager:fileManager];
        LPMusicMsgModel * model = [[LPMusicMsgModel alloc] initWithDict:[dictMusicMsg mutableCopy]];
        [arrResult addObject:model];
    }
    return arrResult;
}


+ (void)convertToMp3FileName:(NSString *)filename assetURL:(NSURL *)assetURL completionHandler:(void (^)(NSData *data))completionHandler
{
    if (!assetURL) {
        !completionHandler ? : completionHandler(nil);
        NSLog(@"assetURL 不存在");
        return;
    }
    
    AVURLAsset *asset = [AVURLAsset URLAssetWithURL:assetURL options:nil];
    
    AVAssetExportSession *exporter = [[AVAssetExportSession alloc]
                                      initWithAsset:asset
                                      presetName: AVAssetExportPresetAppleM4A];
    NSLog (@"created exporter. supportedFileTypes: %@", exporter.supportedFileTypes);
    exporter.outputFileType = @"com.apple.m4a-audio";

    NSString *exportFile = [CacheHelper getNewFilePathWithOriginFilePath:nil newFolderPath:CachePath newFileName:filename pathExtension:@"m4a"];
    NSURL* exportURL = [NSURL fileURLWithPath:exportFile];
    exporter.outputURL = exportURL;
    // do the export
    [exporter exportAsynchronouslyWithCompletionHandler:^
     {
         int exportStatus = exporter.status;
         switch (exportStatus) {
             case AVAssetExportSessionStatusFailed: {
                 // log error to text view
                 NSError *exportError = exporter.error;
                 NSLog (@"AVAssetExportSessionStatusFailed: %@", exportError);
                 break;
             }
             case AVAssetExportSessionStatusCompleted: {
                NSData *data = [NSData dataWithContentsOfFile:exportFile];
                 !completionHandler ? : completionHandler(data);
                 NSLog (@"AVAssetExportSessionStatusCompleted");
                 break;
             }
             case AVAssetExportSessionStatusUnknown: {
                 NSLog (@"AVAssetExportSessionStatusUnknown");
                 break;
             }
             case AVAssetExportSessionStatusExporting: {
                 NSLog (@"AVAssetExportSessionStatusExporting");
                 break;
             }
             case AVAssetExportSessionStatusCancelled: {
                 NSLog (@"AVAssetExportSessionStatusCancelled");
                 break;
             }
             case AVAssetExportSessionStatusWaiting: {
                 NSLog (@"AVAssetExportSessionStatusWaiting");
                 break;
             }
             default:
             {
                 NSLog (@"didn't get export status");
             }
         }
     }];
}

@end
