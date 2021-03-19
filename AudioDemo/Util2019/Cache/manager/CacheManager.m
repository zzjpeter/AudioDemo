//
//  CacheManager.m
//  FbeeAPP
//
//  Created by dev-m on 2018/3/13.
//  Copyright © 2018年 mohao. All rights reserved.
//

#import "CacheManager.h"

@interface CacheManager()

@end

@implementation CacheManager

+(instancetype)sharedManager
{
    static dispatch_once_t queue;
    static CacheManager * manager = nil;
    
    dispatch_once(&queue, ^{
        manager = [[CacheManager alloc]init];
    });
    
    return manager;
}

-(instancetype)init
{
    self = [super init];
    
    if (self) {

    }
    
    return self;
}

#pragma mark -存取数据
- (void)saveData:(NSData *)data fileName:(NSString *)fileName{
    
    if (data == nil) {
        return;
    }
    
    [self saveData:data folderPath:CachePath fileName:fileName];
    
}

- (BOOL)saveCacheDataOnCurThread:(NSData *)data fileName:(NSString *)fileName{
    
    if (data == nil) {
        return NO;
    }
    
    return [self saveCacheDataOnCurThread:data folderPath:CachePath fileName:fileName];
    
}

- (id )getDataWithFileName:(NSString *)fileName{
    
    id data = nil;
    data = [self getDataFolderPath:CachePath fileName:fileName];
    return data;
}


#pragma mark -封装的存取的基本工具方法
//第一组针对数组
- (void)saveList:(NSArray *)data folderPath:(NSString *)folderPath fileName:(NSString *)fileName{
    //数据存储一般不关注存储结果（成功或失败），所以一般放在分线程中执行
    [CacheHelper saveCacheData:data folderPath:folderPath fileName:fileName];
}
- (NSArray *)getListFolderPath:(NSString *)folderPath fileName:(NSString *)fileName{
    //数据获取，一般获取数据需要是用来刷新UI。（这时需要分情况来处理。1.如果数据很小，可以放在主线程中执行，立即刷新UI 2.如果数据很大，放在主线程中执行会导致程序卡顿，所以建议在分现场中执行，获取到数据后在主线程中执行刷新）
    NSArray *dataArray = [CacheHelper getCacheDataByFolderPath:folderPath fileName:fileName];
    return dataArray;
}
////第二组针对NSData，NSArray，NSDictionary都可以
- (void)saveData:(id )data folderPath:(NSString *)folderPath fileName:(NSString *)fileName{
    //数据存储一般不关注存储结果（成功或失败），可以放在分线程中执行
    [CacheHelper saveCacheData:data folderPath:folderPath fileName:fileName];
}
- (void)saveData:(id )data filePath:(NSString *)filePath{
    [CacheHelper saveCacheData:data filePath:filePath];
}

- (BOOL)saveCacheDataOnCurThread:(id )data folderPath:(NSString *)folderPath fileName:(NSString *)fileName{
    return [CacheHelper saveCacheDataOnCurThread:data folderPath:folderPath fileName:fileName];
}
- (BOOL)saveCacheDataOnCurThread:(id )data filePath:(NSString *)filePath {
    return [CacheHelper saveCacheDataOnCurThread:data filePath:filePath];
}

- (id )getDataFolderPath:(NSString *)folderPath fileName:(NSString *)fileName{
    //数据获取，一般获取数据需要是用来刷新UI。（这时需要分情况来处理。1.如果数据很小，可以放在主线程中执行，立即刷新UI 2.如果数据很大，放在主线程中执行会导致程序卡顿，所以建议在分现场中执行，获取到数据后在主线程中执行刷新）
    id data = [CacheHelper getCacheDataByFolderPath:folderPath fileName:fileName];
    return data;
}
- (id )getDataFilePath:(NSString *)filePath{
    //数据获取，一般获取数据需要是用来刷新UI。（这时需要分情况来处理。1.如果数据很小，可以放在主线程中执行，立即刷新UI 2.如果数据很大，放在主线程中执行会导致程序卡顿，所以建议在分现场中执行，获取到数据后在主线程中执行刷新）
    id data = [CacheHelper getCacheDataByFilePath:filePath];
    return data;
}

@end
