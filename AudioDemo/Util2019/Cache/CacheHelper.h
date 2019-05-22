//
//  CacheHelper.h
//  TooToo
//  本地缓存
//  Created by MoHao on 14-3-4.
//  Copyright (c) 2014年 MoHao. All rights reserved.
//

#import <Foundation/Foundation.h>

#define rootFolder @"SCImageChache"
#define DOCUMENTS_FOLDER [NSHomeDirectory() stringByAppendingPathComponent:@"Library/Caches"]

//讲义图片
#define CachePath    [DOCUMENTS_FOLDER stringByAppendingPathComponent:@"/SCImageUnderlyingCache"]

typedef NS_ENUM(NSUInteger, SourceType) {
    SourceTypeIMAGE_JPG = 1,
    SourceTypeIMAGE_PNG,
    SourceTypeVOICE_MP3,
    SourceTypeVOICE_CAF,
    SourceTypeVIDEO_MP4,
};

@class ArchivesMessageObj;

@interface CacheHelper : NSObject

#pragma mark - 检查

//检查文件与文件夹是否存在
+(Boolean)checkfile:(NSString *)_path;
//判断图片缓存的有效期，如果过期，就删除
+(void)judgeImageCacheValidDate;
//判断广告缓存的有效期，如果过期，就删除
+(void)judgeAdvertCacheValidDate;



#pragma mark -获取文件路径
//具体文件路径 根据文件夹和文件名获取完整 文件路径名
+ (NSString *)getFilePath:(NSString *)folderPath fileName:(NSString *)fileName;
//具体文件路径
+ (NSString *)cachePathForKey:(NSString *)key folder:(NSString*)_folderName;
//获取文件目录
+(NSString*)getfolderpath:(NSString *)_foldername;


#pragma mark - 创建

//创建本地文件夹 通过文件名
+(Boolean)createfolder:(NSString *)folderName;
//创建本地文件夹 通过文件路径
+(BOOL)createFolder:(NSString*)folderPath;

#pragma mark - 保存

//缓存Data
+(Boolean)saveCacheData:(NSData*)_data path:(NSString*)_path;
//缓存字典
+(Boolean)saveCacheDictionary:(NSDictionary *)_dict path:(NSString *)_path;
//缓存数组
+(Boolean)saveCacheArray:(NSArray *)array path:(NSString *)_path;


#pragma mark - 获取

//根据路径获取相应的data
+(NSData *)getDataByFilePath:(NSString *)filePath;
//根据路径获取相应的Dictionary
+(NSDictionary *)getDictionaryByFilePath:(NSString *)filePath;
//根据路径获取相应的array
+(NSArray *)getArrayByFilePath:(NSString *)filePath;
//获取本地字典数据
+(NSDictionary*)getDictionaryByFileName:(NSString*)_filename;


#pragma mark - 删除

//清除本地图片缓存
+(void)deleteOverDueAppFolder:(void(^)(void))complete;
//删除某个文件夹
+(BOOL)deleteFolderAtFolderPath:(NSString*)folder;
//删除某个路径文件夹下的文件
+(BOOL)deleteFileAtFilePath:(NSString*)filePath;
//删除档案
+(BOOL)deleteArchive;
+ (long long)fileSizeAtPath:(NSString*) filePath;
//计算整个目录大小
+ (float)folderSizeAtPath:(NSString *)folderPath;

#pragma mark - -z再封装
#pragma mark -存本地数据
+ (void)saveCacheData:(id)data folderPath:(NSString *)folderPath fileName:(NSString *)fileName;
//当前线程存储 默认一般主线程中处理
+ (BOOL)saveCacheDataOnCurThread:(id)data folderPath:(NSString *)folderPath fileName:(NSString *)fileName;
#pragma mark -取本地数据
+ (id)getCacheDataByFolderPath:(NSString *)folderPath fileName:(NSString *)fileName;

#pragma mark C方式 获取app常用文件路径 Document、Cache、Temp

/**
 * @brief 获取Document下文件路径
 */
NSString * pathdwf(NSString *, ...);

/**
 * @brief 获取Cache下文件路径
 */
NSString * pathcwf(NSString *, ...);

/**
 * @brief 获取Temp下文件路径
 */
NSString * pathtwf(NSString *, ...);

/**
 * @brief GUID
 */
NSString * uuid(void);

/**
 * @brief 以当前时间获得一个文件名
 */
NSString * dfn(NSString *);

void runDispatchGetMainQueue(void (^block)(void));
void runDispatchGetGlobalQueue(void (^block)(void));

#pragma mark 文件通用存储位置
//所有基础文件的保存路径
+(NSString*)pathForCommonFile:(NSString *)fileName withType:(NSInteger)fileType;

@end
