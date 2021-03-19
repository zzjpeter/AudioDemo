//
//  NSString+Length.h
//  ManageUtil2020
//
//  Created by 朱志佳 on 2020/11/3.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSString (Length)

//自定义规则计算的length
- (NSUInteger)textLength;
+ (NSUInteger)textLength:(NSString *)text;

//限制maxCount后返回的length
+ (NSUInteger)maxCountTextLength:(NSString *)text maxCount:(NSUInteger)maxCount;

@end

NS_ASSUME_NONNULL_END
