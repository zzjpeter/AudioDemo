//
//  NSString+Find.m
//  TestResolveURL
//
//  Created by zhuzj on 2018/4/3.
//  Copyright © 2018年 zhuzj. All rights reserved.
//

#import "NSString+Find.h"

@implementation NSString (Find)

//获取这个字符串中的所有xxx的所在的index
+ (NSMutableArray *)getRangeStr:(NSString *)text findText:(NSString *)findText{
    
    NSMutableArray *arrayRanges = [NSMutableArray new];
    
    if (findText == nil && [findText isEqualToString:@""]) {
        return nil;
    }
    
    NSRange rang = [text rangeOfString:findText]; //获取第一次出现的range
    
    if (rang.location != NSNotFound && rang.length != 0) {
        
        [arrayRanges addObject:[NSNumber numberWithInteger:rang.location]];//将第一次的加入到数组中
        
        NSRange rang1 = {0,0};
        
        NSInteger location = 0;
        
        NSInteger length = 0;
        
        for (int i = 0;; i++)
        {
            if (0 == i) {//去掉这个xxx
                
                location = rang.location + rang.length;
                
                length = text.length - rang.location - rang.length;
                
                rang1 = NSMakeRange(location, length);
                
            }else
            {
                
                location = rang1.location + rang1.length;
                
                length = text.length - rang1.location - rang1.length;
                
                rang1 = NSMakeRange(location, length);
                
            }
            
            //在一个range范围内查找另一个字符串的range
            rang1 = [text rangeOfString:findText options:NSLiteralSearch range:rang1];
            
            if (rang1.location == NSNotFound && rang1.length == 0) {
                break;
            }else{
                //添加符合条件的location进数组
                [arrayRanges addObject:[NSNumber numberWithInteger:rang1.location]];
            }
        }
        
        return arrayRanges;
        
    }
    return nil;
    
}

+ (NSMutableArray *)getRangeStr1:(NSString *)text findText:(NSString *)findText{
    
    if (findText == nil && [findText isEqualToString:@""]) {
        return nil;
    }
    
    NSMutableArray *ranges = [NSMutableArray new];
    NSMutableString *tempText = [NSMutableString stringWithString:text];
    NSInteger location = 0;
    NSInteger length = 0;
    NSRange rang = {0,tempText.length};
    while (1) {
        
        //在rang 中 查找符合条件的 子集rang1
        NSRange rang1 = [text rangeOfString:findText options:NSLiteralSearch range:rang];
        
        //找到一个
        if (rang1.location != NSNotFound && rang1.length != 0) {
            
            [ranges addObject:[NSNumber numberWithInteger:rang1.location]];
            
            //下一次开始查找位置
            location = rang1.location + rang1.length;
            length = tempText.length - rang1.location - rang1.length;
            
            rang = NSMakeRange(location, length);
        }else{
            break;
        }
    }
    
    //    NSLog(@"ranges:%@",ranges);
    if (ranges.count > 0) {
        return ranges;
    }
    
    return nil;
}


+ (NSString *)getNewStrWithStr:(NSString *)text findText:(NSString *)findText endText:(NSString *)endText{
    
    
    NSString *newText = nil;
    
    //成对找 并处理
    findText =@"\"balance\":";
    endText = @",";
    
    if (findText == nil && [findText isEqualToString:@""]) {
        return nil;
    }
    
    if (endText == nil && [endText isEqualToString:@""]) {
        return nil;
    }
    
    NSMutableString *tempText = [NSMutableString stringWithString:text];
    NSInteger location = 0;
    NSInteger length = tempText.length;
    NSRange rang = {0,tempText.length};
    while (1) {
        
        NSRange rang1 = [tempText rangeOfString:findText options:NSLiteralSearch range:rang];
        
        //找到一个
        if (rang1.location != NSNotFound && rang1.length != 0) {
            
            
            NSInteger beginLocation = rang1.location + rang1.length;
            NSInteger remainLength = tempText.length - beginLocation;
            NSRange remainRange = NSMakeRange(beginLocation, remainLength);
            
            NSRange rang2 = [tempText rangeOfString:endText options:NSLiteralSearch range:remainRange];
            
            if (rang2.location != NSNotFound && rang2.length != 0) {
                //插入  先插入后面的 再插入前面的
                [tempText insertString:@"\"" atIndex:rang2.location + rang2.length -1];
                [tempText insertString:@"\"" atIndex:beginLocation];
                
                
                //下一次开始查找位置
                location = beginLocation + rang2.length + 2;
                length = tempText.length - location;
                
                rang = NSMakeRange(location, length);
            }else{
                break;
            }
            
            
        }else{
            break;
        }
    }
    
    if (tempText) {
        newText = [tempText copy];
    }
    //NSLog(@"newText:%@",newText);
    
    return newText;
    
}



@end
