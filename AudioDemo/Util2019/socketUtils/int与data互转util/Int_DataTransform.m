//
//  Int_DataTransform.m
//  iOS里int与NSData互转
//
//  Created by xunshian on 16/12/26.
//  Copyright © 2016年 xunshian. All rights reserved.
//

#import "Int_DataTransform.h"

@implementation Int_DataTransform

#pragma mark -借助字符串 int － str －data
//int --> NSData
+ (NSData *)intTransformToData_ByStr:(int )aInt{
    
    int someInt = aInt;
    NSString *aString = [NSString stringWithFormat:@"%d",someInt];
    NSData *someData = [aString dataUsingEncoding:NSUTF8StringEncoding];
    return someData;
}

#pragma mark -借助字符串 data － str －int
//NSData --> int
+ (int )dataTransformToInt_ByStr:(NSData *)data{
    
    NSData* someData = data;
    NSString *aString = [[NSString alloc] initWithData:someData encoding:NSUTF8StringEncoding];
    int someInt = [aString intValue];
    
    return someInt;
}




#pragma mark -借助字节数组 int － ByteArr －data
//int --> NSData
+ (NSData *)intTransformToData_ByByteArr:(int )aInt{
    
    int i  = aInt;
    NSData *someData = [NSData dataWithBytes:&i length:sizeof(i)];
    return someData;
}

#pragma mark -借助字节数组 data － ByteArr －int 2
//NSData --> int
+ (int )dataTransformToInt_ByByteArr:(NSData *)data{
    
    NSRange range = NSMakeRange(0,4); //这几个数字具体的位置
    
    //开辟内存空间
    Byte bytes[4];//i  = 253; bytes = 253
    
    //赋值
    [data getBytes:bytes range:range];
    //[data getBytes:bytes length:range.length];
    
    
    int num;
#if 0
    num = (int)bytes[0];//i = 253 num = 253  //i = 345 num = 89 显然数值不对[原因：数值小于oxff也即255时，是没有问题的。但是如果大于255，就需要 进行移位 处理 进行加和了 如上]
#elif 1
    //大小端导致 应该采用处理方式2
    
    //处理方式1
    //num = (bytes[0]<<24) + (bytes[1]<<16) + (bytes[2]<<8) + bytes[3];
    
    //处理方式2
    num = (int)(bytes[3]<<24) + (bytes[2]<<16) + (bytes[1]<<8) + bytes[0];//i = 253 j = 253  //i = 345 j = 345
#endif
    
    //NSLog(@"bytes num =%d",num);

    return num;
}


#pragma mark -借助字节数组 data － ByteArr －int 2
//NSData --> int
+ (int )dataTransformToInt_ByByteArr1:(Byte *)bytes{

    int num;
#if 0
    num = (int)bytes[0];//i = 253 num = 253  //i = 345 num = 89 显然数值不对[原因：数值小于oxff也即255时，是没有问题的。但是如果大于255，就需要 进行移位 处理 进行加和了 如上]
#elif 1
    //大小端导致 应该采用处理方式2
    
    //处理方式1
    //num = (bytes[0]<<24) + (bytes[1]<<16) + (bytes[2]<<8) + bytes[3];
    
    //处理方式2
    num = (int)(bytes[3]<<24) + (bytes[2]<<16) + (bytes[1]<<8) + bytes[0];//i = 253 j = 253  //i = 345 j = 345
#endif
    
    //NSLog(@"bytes num =%d",num);
    
    return num;
}

@end
