//
//  LPMusicMsgModel.h
//  HeadPhone
//
//  Created by 王刚 on 2018/3/20.
//  Copyright © 2018年 iOS-iMac. All rights reserved.
//

#import <MediaPlayer/MediaPlayer.h>

#define keyForSongTitle @"musicName"
#define keyForSongDuration @"musicDuration"
#define keyForSongDurationSeconds @"musicDurationSeconds"
#define keyForSongPath @"musicPath"
#define keyForSongArtist @"musicArtist"
#define keyForSongAlbum @"musicAlbum"
#define keyForSongSize @"MusicSize"
#define keyForSongPicture @"musicPic"

@interface BaseModel : NSObject

//将字典内的复制给申明的响应属性
-(instancetype)initWithDict:(NSMutableDictionary *)dict;
+(instancetype)modelWithDict:(NSMutableDictionary *)dict;

@end

@interface LPMusicMsgModel : BaseModel

@property (nonatomic, strong) NSString * musicName;                         //歌名
@property (nonatomic, strong) NSString * musicDuration;                     //歌曲时长
@property (nonatomic, strong) NSString * musicDurationSeconds;              //歌曲时长 单位s
@property (nonatomic, strong) NSString * musicPath;                         //歌曲地址
@property (nonatomic, strong) NSString * musicArtist;                       //歌手
@property (nonatomic, strong) NSString * musicAlbum;                        //歌曲唱片集
@property (nonatomic, strong) NSString * musicSize;                         //歌曲大小
@property (nonatomic, strong) MPMediaItemArtwork * musicArtwork;            //封面缩略图

@end
