//
//  LiveManager.h
//  AudioDemo
//
//  Created by 朱志佳 on 2019/6/5.
//  Copyright © 2019 朱志佳. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AVHeader.h"
NS_ASSUME_NONNULL_BEGIN

@interface LiveManager : NSObject

SingleInterface(manager)

- (void)startWithPreView:(UIView *)preView;
- (void)stop;

- (void)changeOnBeaty;
- (void)changeOnCamera;

//权限申请管理
+ (void)requestAccessForAudioCompletionHandler:(void (^)(BOOL granted))handler;
+ (void)requestAccessForVideoCompletionHandler:(void (^)(BOOL granted))handler;

@end

NS_ASSUME_NONNULL_END
