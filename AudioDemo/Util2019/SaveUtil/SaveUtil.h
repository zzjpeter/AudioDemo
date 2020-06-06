//
//  SaveUtil.h
//  RMMapperExample
//
//  Created by 朱志佳 on 17/1/8.
//  Copyright © 2017年 Roomorama. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "RMMapper.h"//依赖于RMMapper
#import "NSUserDefaults+RMSaveCustomObject.h"
#define Defaults [NSUserDefaults standardUserDefaults]

@interface SaveUtil : NSObject


#pragma mark --数据读写NSUserDefaults 只支持7种基本数据类型
+ (void)writeData:(id)object key:(NSString *)key;
+ (id)readData:(NSString *)key;

#pragma mark --数据读写NSUserDefaults （自持自定义数据类型 其通过归档成NSData实现的）
+ (void)writeData_3RD:(id)object key:(NSString *)key;
+ (id)readData_3RD:(NSString *)key ;

#pragma mark --数据读写 归档实现 支持自定义数据类型
+ (void)writeData:(id)object key:(NSString *)key filePath:(NSString *)filePath;
+ (id)readData:(NSString *)key filePath:(NSString *)filePath;





@end
