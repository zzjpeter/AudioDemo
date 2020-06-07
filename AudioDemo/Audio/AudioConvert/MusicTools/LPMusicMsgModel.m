//
//  LPMusicMsgModel.m
//  HeadPhone
//
//  Created by 王刚 on 2018/3/20.
//  Copyright © 2018年 iOS-iMac. All rights reserved.
//

#import "LPMusicMsgModel.h"

@implementation BaseModel

-(instancetype)initWithDict:(NSMutableDictionary *)dict{
    self = [super init];
    if (self) {
        
    }
    return self;
}

+(instancetype)modelWithDict:(NSMutableDictionary *)dict{
    return [[self alloc] initWithDict:dict];
}

@end

@implementation LPMusicMsgModel
-(instancetype)initWithDict:(NSMutableDictionary *)dict{
    self = [super initWithDict:dict];
    if (self) {
        self.musicName = [NSString stringWithFormat:@"%@",dict[keyForSongTitle]];
        self.musicDuration = [NSString stringWithFormat:@"%@",dict[keyForSongDuration]];
        self.musicDurationSeconds = [NSString stringWithFormat:@"%@",dict[keyForSongDurationSeconds]];
        self.musicPath = [NSString stringWithFormat:@"%@",dict[keyForSongPath]];
        self.musicArtist = [NSString stringWithFormat:@"%@",dict[keyForSongArtist]];
        self.musicAlbum = [NSString stringWithFormat:@"%@",dict[keyForSongAlbum]];
        self.musicSize = [NSString stringWithFormat:@"%@",dict[keyForSongSize]];
        self.musicArtwork = dict[keyForSongPicture];
    }
    return self;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"\n musicName:%@\n musicDuration:%@\n musicDurationSeconds:%@\n musicPath:%@\n musicArtist:%@\n musicAlbum:%@\n musicSize:%@\n ", self.musicName, self.musicDuration,  self.musicDurationSeconds, self.musicPath, self.musicArtist, self.musicAlbum, self.musicSize];
}

@end
