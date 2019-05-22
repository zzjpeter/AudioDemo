//
//  NSString+Empty.m
//  ManageUtil2018
//
//  Created by 朱志佳 on 2019/5/17.
//  Copyright © 2019 zhuzj. All rights reserved.
//

#import "NSString+Empty.h"

@implementation NSString (Empty)

+(BOOL)isEmptyString:(NSString *)str
{
    if (!str) {
        return YES;
    }
    
    if ([str isKindOfClass:[NSNull class]]) {
        return YES;
    }
    
    if (str.length == 0) {
        return YES;
    }
    
    if ([str isEqualToString:@""]) {
        return YES;
    }
    
    return NO;
}

@end
