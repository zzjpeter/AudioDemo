//
//  TransformUtil.h
//  iOS蓝牙中的进制转换
//
//  Created by xunshian on 16/12/30.
//  Copyright © 2016年 zzj. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TransformUtil : NSObject

#pragma mark -Byte转NSData
//假设我们要向蓝牙发送0x1B9901这条数据
- (void)byteToDataDemo;

#pragma mark -NSString转NSData //例如：FFEE13
- (NSData *)hexToBytes:(NSString *)hexStr;//例如：FFEE13


//0x1B = 27 0x99 = 153  180 = 0xb4
//Ox1B + 0x99 = 0xb4
#pragma mark -求校验和 例如0x1B9901 data就是data=<1b99014b>
- (NSData *)getCheckSum:(NSString *)byteStr;

#pragma mark -将十进制转化为十六进制
- (NSString *)ToHex:(int)tmpid;

#pragma mark -10进制转2进制--参数length 是值2进制数的位数，只能比当前值大 才行
//  十进制转二进制
- (NSString *)toBinarySystemWithDecimalSystem:(int)num length:(int)length;

#pragma mark -二进制转十进制
//  二进制转十进制
- (NSString *)toDecimalWithBinary:(NSString *)binary;

#pragma mark -16进制和2进制互转－－参数hex 16进制和2进制  参数binary 2进制和16进制
- (NSString *)getBinaryByhex:(NSString *)hex binary:(NSString *)binary;

#pragma mark -int转NSData
- (NSData *) setId:(int)Id;

#pragma mark -NSData转int
//接受到的数据0x00000a0122
////4字节表示的int
//NSData *intData = [data subdataWithRange:NSMakeRange(2, 4)];
//int value = CFSwapInt32BigToHost(*(int*)([intData bytes]));//655650
////2字节表示的int
//NSData *intData = [data subdataWithRange:NSMakeRange(4, 2)];
//int value = CFSwapInt16BigToHost(*(int*)([intData bytes]));//290
////1字节表示的int
//char *bs = (unsigned char *)[[data subdataWithRange:NSMakeRange(5, 1) ] bytes];
//int value = *bs;//34
//补充内容，因为没有三个字节转int的方法，这里补充一个通用方法
- (unsigned)parseIntFromData:(NSData *)data;

@end
