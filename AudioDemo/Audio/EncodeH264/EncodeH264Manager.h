//
//  EncodeH264Manager.h
//  AudioDemo
//
//  Created by 朱志佳 on 2019/5/22.
//  Copyright © 2019 朱志佳. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "Single.h"
#import "ZHeader.h"

NS_ASSUME_NONNULL_BEGIN

@interface EncodeH264Manager : NSObject

SingleInterface(manager)

@property (nonatomic,strong) UIView *playView;//播放视频的view 必须提前在play之前设置

- (void)play;
- (void)stop;

@end

NS_ASSUME_NONNULL_END
