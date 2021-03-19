//
//  ByteSortByAddr.m
//  字节序及字节序转换
//
//  Created by xunshian on 16/12/22.
//  Copyright © 2016年 xunshian. All rights reserved.
//

#import "ByteSortByAddr.h"
#include <stdio.h>
#include <stdint.h>

@implementation ByteSortByAddr

//此程序在int为占2字节以上的编译器上执行，下面示例的说明是在int为4字节的编译器上执行的结果
//剖析
//由于联合体union的存放顺序是所有成员都从低地址开始存放，利用该特性就可以轻松地获得了CPU对内存采用Little-Endian还是Big-Endian模式读写。
// 若处理器采用的是大端模式，则返回0；若采用的是小端模式，则返回1。
int checkCPU()
{
    union
    {
        int a;
        char b;
    } c;
    
    c.a = 1;
    return c.b==1;
}



// 32位int大小端转换
int32_t BigLittleSwap32(int32_t value)
{
    return ((value & 0x000000FF) << 24 |
            (value & 0x0000FF00) << 8  |
            (value & 0x00FF0000) >> 8  |
            (value & 0xFF000000) >> 24 );
}


// 64位int大小端转换
int64_t BigLittleSwap64(int64_t value)
{
    return ((value & 0x00000000000000FF) << 56 |
            (value & 0x000000000000FF00) << 40 |
            (value & 0x0000000000FF0000) << 24 |
            (value & 0x00000000FF000000) << 8  |
            (value & 0x000000FF00000000) >> 8  |
            (value & 0x0000FF0000000000) >> 24 |
            (value & 0x00FF000000000000) >> 40 |
            (value & 0xFF00000000000000) >> 56);
}

//注意
//假如你们公司后台是java开发的，而之间又要进行数据传输，那么可能 就会涉及大小端的数据问题。因为java默认是大端，iOS采用的是小端模式，所以需要转化。具体操作如下：
//1.先进行大小端判断
int checkCPUendian() {//返回1，为小端；反之，为大端；
    union
    {
        unsigned int  a;
        unsigned char b;
    }c;
    c.a = 1;
    return 1 == c.b;
}
//2.再将小端转化为大端, 利用C语言函数ntohl()进行转换
//int newSize = size;
//if (checkCPUendian() == 1) {
//    newSize = ntohl(size);//小端转大端
//}


@end
