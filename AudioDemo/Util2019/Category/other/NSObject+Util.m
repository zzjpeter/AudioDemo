//
//  NSObject+Util.m
//  ManageUtil2018
//
//  Created by 朱志佳 on 2019/5/17.
//  Copyright © 2019 zhuzj. All rights reserved.
//

#import "NSObject+Util.h"

@implementation NSObject (Util)

+ (Class)qn_class {
    return [self class];
}

+ (instancetype)qn_cast:(id)any warnOnFailure:(BOOL)warnOnFailure {
    return [self qn_cast:any warnOnFailure:warnOnFailure filepath:NULL line:-1];
}

+ (instancetype)qn_cast:(id)any warnOnFailure:(BOOL)warnOnFailure filepath:(const char * _Nullable)filepath line:(int)line {
    if (any) {
        if ([any isKindOfClass:[self class]]) {
            return any;
        } else if (warnOnFailure) {
            
        }
    }
    return nil;
}

//生成唯一ID
+ (NSString *)uniqueUUID
{
    return [[NSUUID UUID] UUIDString];
}

@end
