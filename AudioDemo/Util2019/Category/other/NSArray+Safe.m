//
//  NSArray+Safe.m
//  ManageUtil2018
//
//  Created by 朱志佳 on 2019/5/17.
//  Copyright © 2019 zhuzj. All rights reserved.
//

#import "NSArray+Safe.h"

@implementation NSArray (Safe)

- (id)safeObjectAtIndex:(NSUInteger)index {
    if (index < self.count) {
        return [self objectAtIndex:index];
    }
    
    return nil;
}

@end
