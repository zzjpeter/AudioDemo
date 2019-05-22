//
//  UIScrollView+iOS11.m
//  VMall
//
//  Created by dev on 2017/12/25.
//  Copyright © 2017年 mohao. All rights reserved.
//

#import "UIScrollView+iOS11.h"
#import <objc/runtime.h>

@implementation UIScrollView(iOS11)


#if __IPHONE_OS_VERSION_MAX_ALLOWED > 110000

+(void)load
{
    Method orgin = class_getInstanceMethod([UIScrollView class], @selector(initWithFrame:));
    Method myF = class_getInstanceMethod(self, @selector(scorllInitWithFrame:));
    method_exchangeImplementations(orgin, myF);
}

-(instancetype)scorllInitWithFrame:(CGRect)frame
{
    [self scorllInitWithFrame:frame];
    
    if (self) {
        if (@available(iOS 11.0,*)) {
            self.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        }
    }
    return self;
}

#endif

@end
