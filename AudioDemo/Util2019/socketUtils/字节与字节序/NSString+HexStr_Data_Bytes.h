//
//  NSString+HexStr_Data_Bytes.h
//  ManageUtil2018
//
//  Created by zhuzj2020 on 2020/6/14.
//  Copyright © 2020 zhuzj. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSString (HexStr_Data_Bytes)

#pragma mark 16进制字符串 转成 NSData
+ (NSData *)convertHexStrToData:(NSString *)hexStr;

#pragma mark NSString 转成 16进制的字符串
+ (NSString *)convertStringToHexStr:(NSString *)str;
#pragma mark 16进制的字符串 转成 NSString(上面方法的逆操作)
+ (NSString *)convertHexStrToString:(NSString *)hexStr;


#pragma mark 16进制字符串 转成 16进制NSData demo 如@"FE010000000429C6"转成<FE010000 000429C6> ;
+(NSData*)stringToHexData:(NSString*)hexStr;
#pragma mark 16进制data 转成 16进制字符串
+(NSString*)hexStringFromData:(NSData*)myD;

#pragma mark 16进制字符串 转成 字节数组  @"AA21f0c1762a3abc299c013abe7dbcc50001DD" 转成 Byte buffer[] = { 0xAA, 0x21, 0xf0, 0xc1, 0x76, 0x2a, 0x3a, ... , 0x01, 0xDD }
-(NSData*)hexToBytes;

@end

NS_ASSUME_NONNULL_END
