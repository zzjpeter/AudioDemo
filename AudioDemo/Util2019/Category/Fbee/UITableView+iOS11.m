//
//  UITableView+iOS11.m
//  VMall
//
//  Created by dev on 2017/12/25.
//  Copyright © 2017年 mohao. All rights reserved.
//

#import "UITableView+iOS11.h"
#import <objc/runtime.h>

@implementation UITableView(iOS11)

#if __IPHONE_OS_VERSION_MAX_ALLOWED > 110000

+(void)load
{
    Method orgin = class_getInstanceMethod([UITableView class], @selector(initWithFrame:));
    Method myF = class_getInstanceMethod(self, @selector(tablInitWithFrame:));
    method_exchangeImplementations(orgin, myF);
    
    Method orgin2 = class_getInstanceMethod([UITableView class], @selector(initWithFrame:style:));
    Method myF2 = class_getInstanceMethod(self, @selector(tablInitWithFrame:style:));
    method_exchangeImplementations(orgin2, myF2);
}

-(instancetype)tablInitWithFrame:(CGRect)frame
{
    [self tablInitWithFrame:frame];
    
    if (self) {
        self.estimatedRowHeight = 0;
        self.estimatedSectionHeaderHeight = 0;
        self.estimatedSectionFooterHeight = 0;
    }
    return self;
}

-(instancetype)tablInitWithFrame:(CGRect)frame style:(UITableViewStyle)style
{
    [self tablInitWithFrame:frame style:style];
    
    if (self) {
        self.estimatedRowHeight = 0;
        self.estimatedSectionHeaderHeight = 0;
        self.estimatedSectionFooterHeight = 0;
    }
    return self;
}

#endif

@end
