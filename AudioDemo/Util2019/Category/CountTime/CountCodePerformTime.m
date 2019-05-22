//
//  CountCodePerformTime.m
//  计算一段代码执行的时间
//
//  Created by xunshian on 16/11/22.
//  Copyright © 2016年 xunshian. All rights reserved.
//

#import "CountCodePerformTime.h"

@implementation CountCodePerformTime


/**
 方式一：获取一段代码执行时间
 
 #define TICK   NSDate *startTime = [NSDate date]
 #define TOCK   NSLog(@"Time: %f", -[startTime timeIntervalSinceNow])
 
 TICK
 
 //在这写入要计算时间的代码
 
 ...
 
 TOCK
 
 打印出来为代码执行时间 单位s
 */
#pragma mark --查看开始和结束时间--打印并返回
+ (NSDate *)checkStartTime{
    
    NSDate *startTime = [NSDate date];
    NSLog(@"code startTime = %@",startTime);
    return startTime;
}

#pragma mark --获取代码结束时间
+ (NSDate *)checkEndTime{
    
    NSDate *endDate = [NSDate date];
    NSLog(@"code EndTime: %@",endDate );
    return endDate;
}

#pragma mark --获取代码执行时间
+ (NSTimeInterval )getDuratinTime:(NSDate *)startTime{
    
    NSTimeInterval durationTime = -[startTime timeIntervalSinceNow];
    NSLog(@"code DurationTime: %f", durationTime);
    return durationTime;
}


/**
 方式二：获取一段代码执行时间
 
 CFAbsoluteTimestartTime =CFAbsoluteTimeGetCurrent();
 
 //在这写入要计算时间的代码
 
 ...
 
 CFAbsoluteTimelinkTime = (CFAbsoluteTimeGetCurrent() - startTime);
 
 NSLog(@"Linked in %f ms", linkTime *1000.0);
 
 打印出来为代码执行时间 单位ms
 */
#pragma mark --获取开始时间
+ (double)getStartTime{
    
    CFAbsoluteTime startTime =CFAbsoluteTimeGetCurrent();
    NSLog(@"startTime =%f",startTime);
    return startTime;
}

#pragma mark --获取代码执行时间－－打印并返回
+ (double)getDuratinTimeCF:(double)startTime{
    
    CFAbsoluteTime linkTime = (CFAbsoluteTimeGetCurrent() - startTime);
    
    double linkTime_ms = linkTime *1000.0;
    NSLog(@"durationTime in %f ms",linkTime_ms);
    
    return linkTime_ms;
}


#pragma mark --获取结束时间
+ (double)getEndTime{
    
    CFAbsoluteTime endTime =CFAbsoluteTimeGetCurrent();
    NSLog(@"endTime =%f",endTime);
    return endTime;
}

@end
