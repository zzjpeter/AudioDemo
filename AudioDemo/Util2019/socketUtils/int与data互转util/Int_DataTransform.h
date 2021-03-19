//
//  Int_DataTransform.h
//  iOS里int与NSData互转
//
//  Created by xunshian on 16/12/26.
//  Copyright © 2016年 xunshian. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Int_DataTransform : NSObject

#pragma mark -***********************
#pragma mark -下面方法常用在 代码中
#pragma mark -***********************
#pragma mark -借助字符串 int － str －data
//int --> NSData
+ (NSData *)intTransformToData_ByStr:(int )aInt;

#pragma mark -借助字符串 data － str －int
//NSData --> int
+ (int )dataTransformToInt_ByStr:(NSData *)data;


#pragma mark -***********************
#pragma mark -下面方法常用在 socket通信 自定义包头
#pragma mark -***********************

#pragma mark -借助字节数组 int － ByteArr －data
//int --> NSData
+ (NSData *)intTransformToData_ByByteArr:(int )aInt;




#pragma mark -借助字节数组 data － ByteArr －int
//NSData --> int
+ (int )dataTransformToInt_ByByteArr:(NSData *)data;

#pragma mark -借助字节数组 data － ByteArr －int 2
//NSData --> int
+ (int )dataTransformToInt_ByByteArr1:(Byte *)bytes;

@end
