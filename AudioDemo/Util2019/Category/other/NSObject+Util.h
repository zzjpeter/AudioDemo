//
//  NSObject+Util.h
//  ManageUtil2018
//
//  Created by 朱志佳 on 2019/5/17.
//  Copyright © 2019 zhuzj. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSObject (Util)

+ (Class)qn_class;
+ (instancetype)qn_cast:(id)any warnOnFailure:(BOOL)warnOnFailure;
+ (instancetype)qn_cast:(id)any warnOnFailure:(BOOL)warnOnFailure filepath:(const char * _Nullable)filepath line:(int)line;

+ (NSString *)uniqueUUID;//生成唯一ID

@end

NS_ASSUME_NONNULL_END
