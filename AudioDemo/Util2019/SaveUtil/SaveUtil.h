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

//归档的数据类型 集合类型和自定义类型
typedef NS_ENUM(NSInteger, DataType)  {
    
    DataTypeArray,//归档的数据类型 数组
    DataTypeDictionary,//归档的数据类型 字典
    DataTypeCustom,//归档的数据类型 自定义类型
    DataTypeDefault = DataTypeCustom //归档的数据类型 默认为自定义
};



#pragma mark --数据写入nsuerdefaults传递数据
+ (void)writeToUserDefaultsWithObject:(id)object andKey:(NSString *)key;
+ (id)readFromUserDefaultsWithKey:(NSString *)key;


#pragma mark --自定义数据类型 使用归档 传递数据
#pragma mark --归档数据转成data写入文件中
+ (void)writeDataToFile:(id )baseTypeData andKey:(NSString *)key andType:(DataType)dataType;
#pragma mark --从文件中读取data数据，并解档
+ (id)readDataFromFileWithKey:(NSString *)key andType:(DataType)dataType;



#pragma mark --第三方的 统一自定义数据类型 和基本数据类型 好用
+ (void)writeDataToFile_3RD:(id )object andKey:(NSString *)key;
#pragma mark --从文件中读取data数据，并解档
+ (id)readDataFromFileWithKey_3RD:(NSString *)key ;


@end
