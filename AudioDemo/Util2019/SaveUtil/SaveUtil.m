//
//  SaveUtil.m
//  RMMapperExample
//
//  Created by 朱志佳 on 17/1/8.
//  Copyright © 2017年 Roomorama. All rights reserved.
//

#import "SaveUtil.h"

@implementation SaveUtil

#pragma mark --7种基本数据类型写入nsuerdefaults传递数据
//1 代表合法的oc中的7种基本数据类型  0代表不合法的数据类型(也即自定义数据类型 转成data再存)
+ (void)writeToUserDefaultsWithObject:(id)object andKey:(NSString *)key{
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    [defaults setObject:object forKey:key];
    
    [defaults synchronize];
}
+ (id)readFromUserDefaultsWithKey:(NSString *)key{
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    return [defaults objectForKey:key];
}


#pragma mark --自定义数据类型 使用归档 传递数据
#pragma mark --归档数据转成data写入文件中
+ (void)writeDataToFile:(id )baseTypeData andKey:(NSString *)key andType:(DataType)dataType{
    
    
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:baseTypeData];
    
    switch (dataType) {
        case DataTypeArray:
            //第一个代表数据类型
            [data writeToFile:[NSString stringWithFormat:@"%ld%@",(long)dataType,key] atomically:YES];
            
            break;
        case DataTypeDictionary:
            //第一个代表数据类型
            [data writeToFile:[NSString stringWithFormat:@"%ld%@",(long)dataType,key] atomically:YES];
            
            break;
        case DataTypeCustom:
            //第一个代表数据类型
            [data writeToFile:[NSString stringWithFormat:@"%ld%@",(long)dataType,key] atomically:YES];
            break;
            
        default:
            NSLog(@"数据类型不是数组，字典 和自定义类型  类型不存在");
            break;
    }
    
}

#pragma mark --从文件中读取data数据，并解档
+ (id)readDataFromFileWithKey:(NSString *)key andType:(DataType)dataType{
    
    NSData *data = [[NSData alloc]initWithContentsOfFile:[NSString stringWithFormat:@"%ld%@",(long)dataType,key]];
    
    if (data == nil) {
        return data;
    }
    
    switch (dataType) {
        case DataTypeArray:
        {
            NSArray *dataArr =  [NSKeyedUnarchiver unarchiveObjectWithData:data];
            
            if (dataArr) {
                return dataArr;
            }else{
                NSLog(@"解档数据类型数组不存在");
            }
            
        }
            
            break;
        case DataTypeDictionary:
        {
            NSDictionary *dataDic =  [NSKeyedUnarchiver unarchiveObjectWithData:data];
            
            if (dataDic) {
                return dataDic;
            }else{
                NSLog(@"解档数据类型字典不存在");
            }
            
        }
            
            break;
        case DataTypeCustom:
        {
            id customTypeData =  [NSKeyedUnarchiver unarchiveObjectWithData:data];
            
            if (customTypeData) {
                return customTypeData;
            }else{
                NSLog(@"解档自定义数据类型不存在");
            }
            
        }
            break;
            
        default:
            NSLog(@"数据类型不是数组，字典 和自定义类型  类型不存在");
            break;
    }
    
    return nil;
}


#pragma mark --第三方的 统一自定义数据类型 和基本数据类型 好用
//使用时 读 写必须配对使用 牢记啊
+ (void)writeDataToFile_3RD:(id )object andKey:(NSString *)key{
    
    //统一使用的归档
    [Defaults rm_setCustomObject:object forKey:key];
    
}
#pragma mark --从文件中读取data数据，并解档
+ (id)readDataFromFileWithKey_3RD:(NSString *)key{
    
    //统一使用的归档
   return [Defaults rm_customObjectForKey:key];
}


@end
