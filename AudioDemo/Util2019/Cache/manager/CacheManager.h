//
//  CacheManager.h
//  FbeeAPP
//
//  Created by dev-m on 2018/3/13.
//  Copyright © 2018年 mohao. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CacheHelper.h"

@interface CacheManager : NSObject

+(instancetype)sharedManager;

#pragma mark -存取数据 默认文件夹路径 通过fileName(完整文件名，带后缀)
//分线程存储
- (void)saveData:(NSData *)data fileName:(NSString *)fileName;
//当前线程存储 默认一般主线程中处理
- (BOOL)saveCacheDataOnCurThread:(NSData *)data fileName:(NSString *)fileName;
//主线程读取
- (id )getDataWithFileName:(NSString *)fileName;

#pragma mark -存取数据 自定义文件夹路径 通过fileName(完整文件名，带后缀)
- (void)saveData:(id )data folderPath:(NSString *)folderPath fileName:(NSString *)fileName;
- (void)saveData:(id )data filePath:(NSString *)filePath;
- (BOOL)saveCacheDataOnCurThread:(id )data folderPath:(NSString *)folderPath fileName:(NSString *)fileName;
- (BOOL)saveCacheDataOnCurThread:(id )data filePath:(NSString *)filePath;
- (id )getDataFolderPath:(NSString *)folderPath fileName:(NSString *)fileName;
- (id )getDataFilePath:(NSString *)filePath;

@end
