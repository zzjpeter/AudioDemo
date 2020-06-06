//
//  AVAssetManager.h
//  AudioDemo
//
//  Created by 朱志佳 on 2019/6/4.
//  Copyright © 2019 朱志佳. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AVHeader.h"
#import "OpenGLView.h"
NS_ASSUME_NONNULL_BEGIN

@interface AVAssetManager : NSObject

SingleInterface(manager)

@property (nonatomic, strong) OpenGLView *mGLView;

@property (nonatomic,copy) void(^loadAssetSuccess)(BOOL isSuccess);
@property (nonatomic,assign) BOOL hasLoadAssetSuccess;

- (void)start;
- (void)stop;

@end

NS_ASSUME_NONNULL_END
