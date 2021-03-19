
//
//  TransformUtil.m
//  iOS蓝牙中的进制转换
//
//  Created by xunshian on 16/12/30.
//  Copyright © 2016年 zzj. All rights reserved.
//

#import "TransformUtil.h"

@implementation TransformUtil

/**
最近在忙一个蓝牙项目，在处理蓝牙数据的时候，经常遇到进制之间的转换，蓝牙处理的是16进制（NSData），而我们习惯的计数方式是10进制，为了节省空间，蓝牙也会把16进制（NSData）拆成2进制记录。这里我们研究下如何在他们之间进行转换。 */
#pragma mark -Byte转NSData
//假设我们要向蓝牙发送0x1B9901这条数据
- (void)byteToDataDemo{
    
    Byte value[3]={0};
    value[0]=0x1B;
    value[1]=0x99;
    value[2]=0x01;
    NSData * data = [NSData dataWithBytes:&value length:sizeof(value)];
    
    NSLog(@"Byte转NSData :%@",data);
    
//    优点：这种方法比较简单，没有进行转换，直接一个字节一个字节的拼装好发送出去。
//    缺点：当发送数据比较长时会很麻烦，而且不易更改。
}

#pragma mark -NSString转NSData //例如：FFEE13
- (NSData *)hexToBytes:(NSString *)hexstr
{
    NSMutableData* data = [NSMutableData data];
    int idx;
    for (idx = 0; idx+2 <= hexstr.length; idx+=2) {
        NSRange range = NSMakeRange(idx, 2);
        NSString* hexStr = [hexstr substringWithRange:range];
        //NSLog(@"hexStr: %@",hexStr);
        NSScanner* scanner = [NSScanner scannerWithString:hexStr];
        unsigned int intValue;
        [scanner scanHexInt:&intValue];
        //NSLog(@"intValue: %d",intValue);
        [data appendBytes:&intValue length:1];
    }
    NSLog(@"data = %@",data);
    
    return data;
    
    /**
     2016-12-30 14:05:01.718 iOS蓝牙中的进制转换[530:299369] hexStr: FF
     2016-12-30 14:05:01.721 iOS蓝牙中的进制转换[530:299369] intValue: 255
     2016-12-30 14:05:01.721 iOS蓝牙中的进制转换[530:299369] hexStr: EE
     2016-12-30 14:05:01.722 iOS蓝牙中的进制转换[530:299369] intValue: 238
     2016-12-30 14:05:01.722 iOS蓝牙中的进制转换[530:299369] hexStr: 13
     2016-12-30 14:05:01.722 iOS蓝牙中的进制转换[530:299369] intValue: 19
     2016-12-30 14:05:01.723 iOS蓝牙中的进制转换[530:299369] data = <ffee13>
     */
    
//    优点：比较直观，可以一次转换一长条数据，对于一些功能简单的蓝牙程序，这种转换能处理大部分情况。
//    缺点：只能发送一些固定的指令，不能参与计算。
}


/**
 求校验和
 接下来探讨下发送的数据需要计算的情况。
 最常用的发送数据需要计算的场景是求校验和（CHECKSUM）。这个根据硬件厂商来定，常见的求校验和的规则有：
 
 如果发送数据长度为n字节，则CHECKSUM为前n-1字节之和的低字节
 CHECKSUM=0x100-CHECKSUM（上一步的校验和）
 如果我要发送带上校验和的0x1B9901，方法就是：
 */

//一个字节 对应二进制8位  对应十六进制2位  一个int 一般对应二进制32位 对应十六进制8位

//0x1B = 27 0x99 = 153  0x01 = 1   181 = 0xb5
//Ox1B + 0x99 +0x01 = 0xb5
#pragma mark -求校验和 例如0x1B9901 data就是data=<1b99014b>
- (NSData *)getCheckSum:(NSString *)byteStr{
    
    int length = (int)byteStr.length/2;
    NSData *data = [self hexToBytes:byteStr];
    Byte *bytes = (unsigned char *)[data bytes];
    Byte sum = 0;
    for (int i = 0; i<length; i++) {
        sum += bytes[i];
    }
    int sumT = sum;
    int at = 256 -  sumT;
    
    printf("校验和：%d\n",at);
    if (at == 256) {
        at = 0;
    }
    NSString *str = [NSString stringWithFormat:@"%@%@",byteStr,[self ToHex:at]];
    return [self hexToBytes:str];
}

//将十进制转化为十六进制
#pragma mark -将十进制转化为十六进制
- (NSString *)ToHex:(int)tmpid
{
    NSString *nLetterValue;
    NSString *str =@"";
    int ttmpig;
    for (int i = 0; i<9; i++) {
        ttmpig=tmpid%16;
        tmpid=tmpid/16;
        switch (ttmpig)
        {
            case 10:
                nLetterValue =@"A";break;
            case 11:
                nLetterValue =@"B";break;
            case 12:
                nLetterValue =@"C";break;
            case 13:
                nLetterValue =@"D";break;
            case 14:
                nLetterValue =@"E";break;
            case 15:
                nLetterValue =@"F";break;
            default:
                nLetterValue = [NSString stringWithFormat:@"%u",ttmpig];
                
        }
        str = [nLetterValue stringByAppendingString:str];
        if (tmpid == 0) {
            break;
        }
    }
    //不够一个字节凑0
    if(str.length == 1){
        return [NSString stringWithFormat:@"0%@",str];
    }else{
        return str;
    }
}

/**
 拆分数据
 这种是比较麻烦的，举个栗子：在传输某条信息时，我想把时间放进去，不能用时间戳，还要节省空间，这样就出现了一种新的方式存储时间。
 这里再补充一些C语言知识：
 
 一个字节8位（bit）
 char 1字节 int 4字节 unsigned 2字节 float 4字节
 存储时间的条件是：
 
 只用四个字节（32位）
 前5位表示年（从2000年算起），接着4位表示月，接着5位表示日，接着5位表示时，接着6位表示分，接着3位表示星期，剩余4位保留。
 这样直观的解决办法就是分别取出现在时间的年月日时分星期，先转成2进制，再转成16进制发出去。当然你这么写进去，读的时候就要把16进制数据先转成2进制再转成10进制显示。我们就按这个简单粗暴的思路来，准备工作如下：
 
 */

#pragma mark -10进制转2进制--参数length 是值2进制数的位数，只能比当前值大 才行
//  十进制转二进制
- (NSString *)toBinarySystemWithDecimalSystem:(int)num length:(int)length
{
    int remainder = 0;      //余数
    int divisor = 0;        //除数
    
    NSString * prepare = @"";
    
    while (true)
    {
        remainder = num%2;
        divisor = num/2;
        num = divisor;
        prepare = [prepare stringByAppendingFormat:@"%d",remainder];
        
        if (divisor == 0)
        {
            break;
        }
    }
    //倒序输出
    NSString * result = @"";
    for (int i = length -1; i >= 0; i --)
    {
        if (i <= prepare.length - 1) {
            result = [result stringByAppendingFormat:@"%@",
                      [prepare substringWithRange:NSMakeRange(i , 1)]];
            
        }else{
            result = [result stringByAppendingString:@"0"];
            
        }
    }
    return result;
}


#pragma mark -二进制转十进制
//  二进制转十进制
- (NSString *)toDecimalWithBinary:(NSString *)binary
{
    int ll = 0 ;
    int  temp = 0 ;
    for (int i = 0; i < binary.length; i ++)
    {
        temp = [[binary substringWithRange:NSMakeRange(i, 1)] intValue];
        temp = temp * powf(2, binary.length - i - 1);
        ll += temp;
    }
    
    NSString * result = [NSString stringWithFormat:@"%d",ll];
    
    return result;
}

#pragma mark -16进制和2进制互转－－参数hex 16进制和2进制  参数binary 2进制和16进制
- (NSString *)getBinaryByhex:(NSString *)hex binary:(NSString *)binary
{
    NSMutableDictionary  *hexDic = [[NSMutableDictionary alloc] init];
    hexDic = [[NSMutableDictionary alloc] initWithCapacity:16];
    [hexDic setObject:@"0000" forKey:@"0"];
    [hexDic setObject:@"0001" forKey:@"1"];
    [hexDic setObject:@"0010" forKey:@"2"];
    [hexDic setObject:@"0011" forKey:@"3"];
    [hexDic setObject:@"0100" forKey:@"4"];
    [hexDic setObject:@"0101" forKey:@"5"];
    [hexDic setObject:@"0110" forKey:@"6"];
    [hexDic setObject:@"0111" forKey:@"7"];
    [hexDic setObject:@"1000" forKey:@"8"];
    [hexDic setObject:@"1001" forKey:@"9"];
    [hexDic setObject:@"1010" forKey:@"a"];
    [hexDic setObject:@"1011" forKey:@"b"];
    [hexDic setObject:@"1100" forKey:@"c"];
    [hexDic setObject:@"1101" forKey:@"d"];
    [hexDic setObject:@"1110" forKey:@"e"];
    [hexDic setObject:@"1111" forKey:@"f"];
    
    NSMutableString *binaryString=[[NSMutableString alloc] init];
    if (hex.length) {
        for (int i=0; i<[hex length]; i++) {
            NSRange rage;
            rage.length = 1;
            rage.location = i;
            NSString *key = [hex substringWithRange:rage];
            [binaryString appendString:hexDic[key]];
        }
        
    }else{
        for (int i=0; i<binary.length; i+=4) {
            NSString *subStr = [binary substringWithRange:NSMakeRange(i, 4)];
            int index = 0;
            for (NSString *str in hexDic.allValues) {
                index ++;
                if ([subStr isEqualToString:str]) {
                    [binaryString appendString:hexDic.allKeys[index-1]];
                    break;
                }
            }
        }
    }
    return binaryString;
}

/**
有了这几种转换函数，完成上面的功能就容易多了，具体怎么操作这里就不写一一出来了。但总感觉怪怪的，这么一个小功能怎么要写这么一大堆代码，当然还可以用C语言的方法去解决。这里主要是为了展示iOS中数据如何转换，C语言的实现方法这里就不写了，有兴趣的同学可以研究下。
 */

//附带两个函数
#pragma mark -int转NSData
- (NSData *) setId:(int)Id {
    //用4个字节接收
    Byte bytes[4];
    bytes[0] = (Byte)(Id>>24);
    bytes[1] = (Byte)(Id>>16);
    bytes[2] = (Byte)(Id>>8);
    bytes[3] = (Byte)(Id);
    NSData *data = [NSData dataWithBytes:bytes length:4];
    
    NSLog(@"int 转data %d:%@",Id,data);
    return data;
}

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
- (unsigned)parseIntFromData:(NSData *)data{
    
    NSString *dataDescription = [data description];
    NSString *dataAsString = [dataDescription substringWithRange:NSMakeRange(1, [dataDescription length]-2)];
    
    unsigned intData = 0;
    NSScanner *scanner = [NSScanner scannerWithString:dataAsString];
    [scanner scanHexInt:&intData];
    
    NSLog(@"NSData转int:%@:%d",data,intData);
    return intData;
}

@end
