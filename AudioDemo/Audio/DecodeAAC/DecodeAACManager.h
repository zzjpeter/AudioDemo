//
//  DecodeAACManager.h
//  AudioDemo
//
//  Created by 朱志佳 on 2019/5/23.
//  Copyright © 2019 朱志佳. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AVHeader.h"
NS_ASSUME_NONNULL_BEGIN


@interface DecodeAACManager : NSObject

@property (nonatomic,copy) void(^currentPlayTime)(NSTimeInterval currentPlayTime);

SingleInterface(manager)

@property (nonatomic,copy) NSString *file;

- (void)start;
- (void)stop;

- (void)play;//iOS系统音效 播放短音乐 与解码播放音乐无关

@end

NS_ASSUME_NONNULL_END
