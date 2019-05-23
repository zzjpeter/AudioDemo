//
//  EncodeAACManager.h
//  AudioDemo
//
//  Created by 朱志佳 on 2019/5/23.
//  Copyright © 2019 朱志佳. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AVHeader.h"

NS_ASSUME_NONNULL_BEGIN

@interface EncodeAACManager : NSObject

SingleInterface(manager)


- (void)start;
- (void)stop;

@end

NS_ASSUME_NONNULL_END
