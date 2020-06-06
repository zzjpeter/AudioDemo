//
//  NSString+TTAdd.h
//  VMall
//
//  Created by ning liu on 2017/11/23.
//  Copyright © 2017年 mohao. All rights reserved.
//
#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "NSString+Empty.h"

@interface NSString (TTAdd)

//@莫 获取多语言大写首字母
-(NSString *)firstCharactor;

//+(BOOL)isEmptyString:(NSString *)str;

//@宁
-(float)heightByWidth:(float)width font:(UIFont *)font lineSpacing:(float)lineHeight alignment:(NSTextAlignment)alignment lineBreakMode:(NSLineBreakMode)breakMode;
-(float)widthByHeight:(float)height font:(UIFont *)font lineSpacing:(float)lineHeight alignment:(NSTextAlignment)alignment lineBreakMode:(NSLineBreakMode)breakMode;
-(float)heightByWidth:(float)width font:(UIFont *)font;
-(float)widthByHeight:(float)height font:(UIFont *)font;

-(NSString *)dateFormatterFromFor:(NSString *)fromFor toFor:(NSString *)toFor;

@end
