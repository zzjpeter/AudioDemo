//
//  NSString+Find.h
//  TestResolveURL
//
//  Created by zhuzj on 2018/4/3.
//  Copyright © 2018年 zhuzj. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (Find)

//获取这个字符串中的所有xxx的所在的index
+ (NSMutableArray *)getRangeStr:(NSString *)text findText:(NSString *)findText;
+ (NSMutableArray *)getRangeStr1:(NSString *)text findText:(NSString *)findText;


//处理返回值json字符串的 特殊方法。在特定位置插入 引号 ""。解决系统NSJSONSerialization处理高精度数字的bug 1e+23 变成 9.99999999e+22
+ (NSString *)getNewStrWithStr:(NSString *)text findText:(NSString *)findText endText:(NSString *)endText;

@end
