//
//  NSArray+Safe.h
//  ManageUtil2018
//
//  Created by 朱志佳 on 2019/5/17.
//  Copyright © 2019 zhuzj. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSArray (Safe)

- (id)safeObjectAtIndex:(NSUInteger)index;

@end

NS_ASSUME_NONNULL_END
