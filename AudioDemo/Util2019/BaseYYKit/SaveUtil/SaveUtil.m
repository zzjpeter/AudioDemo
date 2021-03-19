//
//  SaveUtil.m
//  RMMapperExample
//
//  Created by 朱志佳 on 17/1/8.
//  Copyright © 2017年 Roomorama. All rights reserved.
//

#import "SaveUtil.h"

@implementation SaveUtil

#pragma mark --数据读写NSUserDefaults 只支持7种基本数据类型
+ (void)writeData:(id)object key:(NSString *)key{
    
    [Defaults setObject:object forKey:key];
    [Defaults synchronize];
    
}
+ (id)readData:(NSString *)key{
    
    return [Defaults objectForKey:key];
}

#pragma mark --数据读写NSUserDefaults （自持自定义数据类型 其通过归档成NSData实现的）
//+ (void)writeData_3RD:(id)object key:(NSString *)key{
//
//    //统一使用的归档
//    [Defaults rm_setCustomObject:object forKey:key];
//}
//+ (id)readData_3RD:(NSString *)key{
//
//    //统一使用的归档
//   return [Defaults rm_customObjectForKey:key];
//}

#pragma mark --数据读写 归档实现 支持自定义数据类型
+ (void)writeData:(id)object key:(NSString *)key filePath:(NSString *)filePath{
    
    if (!([object respondsToSelector:@selector(encodeWithCoder:)] &&
          [object respondsToSelector:@selector(initWithCoder:)])) {
        NSLog(@"该数据类型没有遵循’NSCoding‘协议 没有实现encodeWithCoder:方法 或 initWithCoder:方法");
        return;
    }
    
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:object];
                
    BOOL success = [data writeToFile:[self filePath:key filePath:filePath] atomically:YES];
    if (!success) {
        NSLog(@"归档写入失败");
    }
}
+ (id)readData:(NSString *)key filePath:(NSString *)filePath{
        
    NSData *data = [[NSData alloc]initWithContentsOfFile:[self filePath:key filePath:filePath]];

    return [NSKeyedUnarchiver unarchiveObjectWithData:data];
}

#pragma mark 文件路径
+ (NSString *)filePath:(NSString *)key filePath:(NSString *)filePath
{
    if (!filePath) {
        filePath = [self documentPath];
    }
    return [filePath stringByAppendingPathComponent:key];
}
+ (NSString *)documentPath
{
    return NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject;
}

@end
