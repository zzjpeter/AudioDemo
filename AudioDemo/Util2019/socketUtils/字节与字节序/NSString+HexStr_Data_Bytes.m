//
//  NSString+HexStr_Data_Bytes.m
//  ManageUtil2018
//
//  Created by zhuzj2020 on 2020/6/14.
//  Copyright © 2020 zhuzj. All rights reserved.
//

#import "NSString+HexStr_Data_Bytes.h"

@implementation NSString (HexStr_Data_Bytes)

+ (NSData *)convertHexStrToData:(NSString *)hexStr{
    if (!hexStr || [hexStr length] == 0) {
        return nil;
    }
    
    NSMutableData *hexData = [[NSMutableData alloc] initWithCapacity:8];
    NSRange range;
    if ([hexStr length] % 2 == 0) {
        range = NSMakeRange(0, 2);
    } else {
        range = NSMakeRange(0, 1);
    }
    for (NSInteger i = range.location; i < [hexStr length]; i += 2) {
        unsigned int anInt;
        NSString *hexCharStr = [hexStr substringWithRange:range];
        //NSLog(@"hexCharStr = %@",hexCharStr);
        NSScanner *scanner = [[NSScanner alloc] initWithString:hexCharStr];
        
        [scanner scanHexInt:&anInt];
        //NSLog(@"anInt: %d",anInt);
        
        NSData *entity = [[NSData alloc] initWithBytes:&anInt length:1];
        [hexData appendData:entity];
        
        range.location += range.length;
        range.length = 2;
    }
    
    NSLog(@"hexData = %@",hexData);
    return hexData;
}

+ (NSString *)convertStringToHexStr:(NSString *)str {
    if (!str || [str length] == 0) {
        return @"";
    }
    
    NSData *data = [str dataUsingEncoding:NSUTF8StringEncoding];
    
    NSMutableString *string = [[NSMutableString alloc] initWithCapacity:[data length]];
    
    [data enumerateByteRangesUsingBlock:^(const void *bytes, NSRange byteRange, BOOL *stop) {
        unsigned char *dataBytes = (unsigned char*)bytes;
        for (NSInteger i = 0; i < byteRange.length; i++) {
            NSString *hexStr = [NSString stringWithFormat:@"%x", (dataBytes[i]) & 0xff];
            if ([hexStr length] == 2) {
                [string appendString:hexStr];
            } else {
                [string appendFormat:@"0%@", hexStr];
            }
        }
    }];
    
    NSLog(@"HexStr = %@",string);
    return string;
}

+ (NSString *)convertHexStrToString:(NSString *)hexStr{
    
   NSData *data = [self convertHexStrToData:hexStr];
    
    NSString *string  = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
     NSLog(@"string = %@",string);
    
    if(string)
    {
        NSLog(@"hexStr to str 成功");
        return string;
    }
    
    NSLog(@"hexStr to str 失败");
    return nil;
}

+(NSData*)stringToHexData:(NSString*)hexStr{
    
    unsigned long len=[hexStr length]/2;// Target length
    
    unsigned char*buf=malloc(len);
    
    unsigned char*whole_byte=buf;
    
    char byte_chars[3]={'\0','\0','\0'};
    
    for(int i=0;i<[hexStr length]/2;i++){
        
        byte_chars[0]=[hexStr characterAtIndex:i*2];
        
        byte_chars[1]=[hexStr characterAtIndex:i*2+1];
        
        *whole_byte=strtol(byte_chars,NULL,16);
        
        whole_byte++;
        
    }
    NSData*data=[NSData dataWithBytes:buf length:len];
    
    free(buf);
    
    return data;
    
}

+(NSString*)hexStringFromData:(NSData*)myD{
    
    Byte*bytes=(Byte*)[myD bytes];//下面是Byte 转换为16进制。
    NSString*hexStr=@"";
    
    for(int i=0;i<[myD length];i++){
        
        NSString*newHexStr=[NSString stringWithFormat:@"%x",bytes[i]&0xff];
        if([newHexStr length]==1){
            
            hexStr=[NSString stringWithFormat:@"%@0%@",hexStr,newHexStr];
            
        } else {
            
            hexStr=[NSString stringWithFormat:@"%@%@",hexStr,newHexStr];
            
        }
    }
    return hexStr;
        
}

-(NSData*)hexToBytes{
    
    NSMutableData* data = [NSMutableData data];
    
    int idx;
    
    for (idx = 0; idx+2 <= self.length; idx+=2) {
        
        NSRange range = NSMakeRange(idx, 2);
        
        NSString* hexStr = [self substringWithRange:range];
        
        NSScanner* scanner = [NSScanner scannerWithString:hexStr];
        
        unsigned int intValue;
        
        [scanner scanHexInt:&intValue];
        
        [data appendBytes:&intValue length:1];
        
    }
    
    return data;
    
}


@end
