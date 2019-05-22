//
//  NSString+URL.h
//  FbeeAPP
//
//  Created by zhuzj on 2018/4/3.
//  Copyright © 2018年 mohao. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (Money)

/**
 * 金额的格式转化
 * str : 金额的字符串
 * numberStyle : 金额转换的格式
 * return  NSString : 转化后的金额格式字符串
 */
+ (NSString *)stringChangeMoneyWithStr:(NSString *)str numberStyle:(NSNumberFormatterStyle)numberStyle;


@end
