//
//  CountCodePerformTime.h
//  计算一段代码执行的时间
//
//  Created by xunshian on 16/11/22.
//  Copyright © 2016年 xunshian. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreFoundation/CoreFoundation.h>

//1.如何快速的查看一段代码的执行时间。
#define TICK   NSDate *startTime = [NSDate date]
#define TOCK   NSLog(@"Time: %f", -[startTime timeIntervalSinceNow])

@interface CountCodePerformTime : NSObject


/**
方式一：获取一段代码执行时间
 */
#pragma mark --查看开始和结束时间--打印并返回
+ (NSDate *)checkStartTime;


#pragma mark --获取代码结束时间
+ (NSDate *)checkEndTime;

#pragma mark --获取代码执行时间
+ (NSTimeInterval )getDuratinTime:(NSDate *)startTime;


/**
 方式二：获取一段代码执行时间
 */
#pragma mark --获取开始时间
#pragma mark --获取开始时间
+ (double)getStartTime;
#pragma mark --获取代码执行时间－－打印并返回
+ (double)getDuratinTimeCF:(double)startTime;
#pragma mark --获取结束时间
+ (double)getEndTime;

@end
