//
//  ByteSortByAddr.h
//  字节序及字节序转换
//
//  Created by xunshian on 16/12/22.
//  Copyright © 2016年 xunshian. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ByteSortByAddr : NSObject

#pragma mark -处理器采用的是大端模式，则返回0；若采用的是小端模式，则返回1
int checkCPU(void);

#pragma mark -32位int大小端转换
// 32位int大小端转换
int32_t BigLittleSwap32(int32_t value);

#pragma mark -364位int大小端转换
// 64位int大小端转换
int64_t BigLittleSwap64(int64_t value);

@end
