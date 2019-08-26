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
        self.musicName = [NSString stringWithFormat:@"%@",dict[@"musicName"]];
        self.musicDuration = [NSString stringWithFormat:@"%@",dict[@"musicDuration"]];
        self.musicPath = [NSString stringWithFormat:@"%@",dict[@"musicPath"]];
        self.musicArtist = [NSString stringWithFormat:@"%@",dict[@"musicArtist"]];
        self.musicAlbum = [NSString stringWithFormat:@"%@",dict[@"musicAlbum"]];
        self.musicArtwork = dict[@"musicArtist"];
        self.musicSize = [NSString stringWithFormat:@"%@",dict[@"MusicSize"]];
    }
    return self;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"%@", self.musicPath];
}

@end
