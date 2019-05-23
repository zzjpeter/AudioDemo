//
//  DecoderH246Manager.h
//  AudioDemo
//
//  Created by 朱志佳 on 2019/5/22.
//  Copyright © 2019 朱志佳. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "ZHeader.h"
#import "LYOpenGLView.h"

NS_ASSUME_NONNULL_BEGIN

@interface DecoderH246Manager : NSObject

SingleInterface(manager)

@property (nonatomic,strong)LYOpenGLView *playView;
- (void)start;
- (void)stop;

@end

NS_ASSUME_NONNULL_END
