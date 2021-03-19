//
//  NSString+Length.m
//  ManageUtil2020
//
//  Created by 朱志佳 on 2020/11/3.
//

#import "NSString+Length.h"

@implementation NSString (Length)

- (NSUInteger)textLength {
    return [NSString textLength:self];
}

//unicodeLength
+ (NSUInteger)textLength:(NSString *)text {
    NSUInteger asciiLength = 0;
    for (NSUInteger i = 0; i < text.length; i++) {
        unichar uc = [text characterAtIndex: i];
        asciiLength += isascii(uc) ? 1 : 2;//设置汉字和字母的比例  如何限制4个字符或12个字母 就是1:3  如果限制是6个汉字或12个字符 就是 1:2  一次类推
    }
    NSUInteger unicodeLength = asciiLength;
    return unicodeLength;
}

//限制maxCount后返回的length
+ (NSUInteger)maxCountTextLength:(NSString *)text maxCount:(NSUInteger)maxCount{
    NSUInteger asciiLength = 0;
    for (NSUInteger i = 0; i < text.length; i++) {
        unichar uc = [text characterAtIndex: i];
        asciiLength += isascii(uc) ? 1 : 2;//设置汉字和字母的比例  如何限制4个字符或12个字母 就是1:3  如果限制是6个汉字或12个字符 就是 1:2  一次类推
        if (asciiLength >= maxCount) {
            if (asciiLength == maxCount) {
                return i + 1;
            }
            return i;
            break;
        }
    }
    return 0;
}

@end
