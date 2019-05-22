//
//  CacheHelper.m
//  TooToo
//  本地缓存
//  Created by MoHao on 14-3-4.
//  Copyright (c) 2014年 MoHao. All rights reserved.
//

#import "CacheHelper.h"
#import <CommonCrypto/CommonDigest.h>

#define FILE_SLASH @"/"
#define CategoryIconFolder     @"CategoryIcons"


@implementation CacheHelper

#pragma mark - 检查


//检查文件与文件夹是否存在
+(Boolean)checkfile:(NSString *)_path
{
    return [[NSFileManager defaultManager] fileExistsAtPath:_path];
}


+(void)judgeImageCacheValidDate
{
    NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
    
    NSDate * lastDate = [userDefaults objectForKey:@"Config_LastCleanImageTime"];
    
    if (lastDate == nil) {
        
        [userDefaults setObject:[NSDate date] forKey:@"Config_LastCleanImageTime"];
        [userDefaults synchronize];
        
        return;
    }
    
    if ([[NSDate date] timeIntervalSinceReferenceDate]-[lastDate timeIntervalSinceReferenceDate] >= 24*60*60/*一天*/)
    {
        //删除缓存
        [CacheHelper deleteOverDueAppFolder:nil];
        
        [userDefaults setObject:[NSDate date] forKey:@"Config_LastCleanImageTime"];
        [userDefaults synchronize];
    }
    
}

+(void)judgeAdvertCacheValidDate
{
    NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
    
    NSDate * lastDate = [userDefaults objectForKey:@"Config_AdvertCleanImageTime"];
    
    if (lastDate == nil) {
        
        [userDefaults setObject:[NSDate date] forKey:@"Config_AdvertCleanImageTime"];
        [userDefaults synchronize];
        
        return;
    }
    
    if ([[NSDate date] timeIntervalSinceReferenceDate]-[lastDate timeIntervalSinceReferenceDate] >= 24*60*60*3/*3天*/)
    {
        //删除缓存
        //        [CacheHelper deleteAdvertCache];
        
        [userDefaults setObject:[NSDate date] forKey:@"Config_AdvertCleanImageTime"];
        [userDefaults synchronize];
    }
    
}

#pragma mark - 创建

//创建本地文件夹 通过文件名
+(Boolean)createfolder:(NSString *)folderName
{
    NSError *error;
    NSFileManager *manager = [NSFileManager defaultManager];
    NSArray*cacPath = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *diskCachePath = [[cacPath objectAtIndex:0] stringByAppendingPathComponent:folderName];
    return [manager createDirectoryAtPath:diskCachePath withIntermediateDirectories:YES attributes:nil error:&error];
}
//创建本地文件夹 通过文件路径
+(BOOL)createFolder:(NSString*)folderPath{
    NSFileManager* fm=[NSFileManager defaultManager];
    NSError *dataError = nil;
    if ([fm fileExistsAtPath:folderPath]) {
        return YES;
    }
    BOOL created=[fm createDirectoryAtPath:folderPath withIntermediateDirectories:YES attributes:nil error:&dataError];
    if(!created) {
        NSLog(@"Error: %@",dataError);dataError=nil;};
    return created;
}

#pragma mark - 保存

//缓存图片
+(Boolean)saveCacheData:(NSData *)_data path:(NSString *)_path
{
    if (!_data) {
        return NO;
    }
    
//    NSLog(@"%@",_path);
    if ([_data writeToFile:_path atomically:YES]) {
        return YES;
    }
    return NO;
}

+(Boolean)saveCacheDictionary:(NSDictionary *)_dict path:(NSString *)_path
{
    if (!_dict || ![_dict isKindOfClass:[NSDictionary class]]) {
        return NO;
    }
    
    _dict = [self deleteNullWithDic:_dict];
    
//    NSLog(@"%@",_path);
    if ([_dict writeToFile:_path atomically:YES]) {
        return YES;
    }
    return NO;
}

+(Boolean)saveCacheArray:(NSArray *)array path:(NSString *)_path
{
    if (!array) {
        return NO;
    }
//    NSLog(@"%@",_path);
    if ([array writeToFile:_path atomically:YES]) {
        return YES;
    }
    return NO;
}



#pragma mark - 获取
#pragma mark -获取文件路径
//根据文件夹和文件名获取完整 文件路径名
+ (NSString *)getFilePath:(NSString *)folderPath fileName:(NSString *)fileName{
    
    if (![CacheHelper checkfile:folderPath]) {
        [CacheHelper createFolder:folderPath];
    }
    
    //folderPath:所有文件存储目录
    NSString *filePath = [folderPath stringByAppendingPathComponent:fileName];
    //NSLog(@"filePath:%@",filePath);
    return filePath;
}

//具体文件路径
+ (NSString *)cachePathForKey:(NSString *)key folder:(NSString*)_folderName
{
    const char *str = [key UTF8String];
    unsigned char r[CC_MD5_DIGEST_LENGTH];
    CC_MD5(str, (CC_LONG)strlen(str), r);
    NSString *filename = [NSString stringWithFormat:@"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
                          r[0], r[1], r[2], r[3], r[4], r[5], r[6], r[7], r[8], r[9], r[10], r[11], r[12], r[13], r[14], r[15]];
    NSArray*cacPath = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *diskCachePath = [[cacPath objectAtIndex:0] stringByAppendingPathComponent:_folderName];
    
    //检查目的文件夹 若不存在则创建
    if (![CacheHelper checkfile:diskCachePath]) {
        [CacheHelper createfolder:_folderName];
    }
    
    //diskcachepath:所有文件存储目录
    return [diskCachePath stringByAppendingPathComponent:filename];
}

//获取文件目录
+(NSString*)getfolderpath:(NSString *)_foldername
{
    NSArray*cacPath = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *diskCachePath = [[cacPath objectAtIndex:0] stringByAppendingPathComponent:_foldername];
    
    return diskCachePath;
}

+(NSData *)getDataByFilePath:(NSString *)filePath
{
    return [NSData dataWithContentsOfFile:filePath];
}

+(NSDictionary *)getDictionaryByFilePath:(NSString *)filePath
{
    return [NSDictionary dictionaryWithContentsOfFile:filePath];
}

+(NSArray *)getArrayByFilePath:(NSString *)filePath
{
    return [NSArray arrayWithContentsOfFile:filePath];
}

+(NSDictionary *)getDictionaryByFileName:(NSString *)_filename
{
    NSArray*cacPath = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *diskCachePath = [[cacPath objectAtIndex:0] stringByAppendingPathComponent:_filename];
    return [NSDictionary dictionaryWithContentsOfFile:diskCachePath];
}

+(NSString*)CombineFilePathByNSString:(NSString*) p1 string2:(NSString*) p2{
    
    if ( ([p1 hasSuffix:FILE_SLASH]) || ([p2 hasPrefix:FILE_SLASH]) ) {
        return [p1 stringByAppendingString:p2];
    }else {
        return [NSString stringWithFormat:@"%@/%@",p1,p2];
    }
}

+(NSString*) CombinFilePath:(NSString*) head para:(va_list) paramsList{
    NSString * result=head;
    NSString * eachObject;
    while ((eachObject = va_arg(paramsList, NSString*))){
        result= [CacheHelper CombineFilePathByNSString:result string2:eachObject];
    }
    return result;
}


#pragma mark - 删除

+(BOOL)deleteFolderAtFolderPath:(NSString*)folder{
	
	NSError *dataError = nil;
	NSFileManager *fm = [NSFileManager defaultManager];
	BOOL delete=[fm removeItemAtPath:folder error:&dataError];
	if(!delete)
		NSLog(@"delete Error: %@",dataError);
	return delete;
}

+(BOOL)deleteFileAtFilePath:(NSString*)filePath{
    NSError *dataError = nil;
    NSFileManager *fm = [NSFileManager defaultManager];
    BOOL delete=[fm removeItemAtPath:filePath error:&dataError];
    if(!delete)
        NSLog(@"delete Error: %@",dataError);
    return delete;
}

//删除档案At
+(BOOL)deleteArchive
{
    return [self deleteFolderAtFolderPath:[DOCUMENTS_FOLDER stringByAppendingPathComponent:@"/Archive"]];
}

+(NSString*) getFileFullPathByRelativePathAT:(NSString *)filePath, ...{
    
	NSString * result = NULL;
	va_list argumentList;
	
	if (filePath){
		result= [CacheHelper CombineFilePathByNSString:DOCUMENTS_FOLDER string2: filePath];
		va_start(argumentList, filePath);
		result= [self CombinFilePath:result para:argumentList];
		va_end(argumentList);
	}
	return result;
}

//获得所有子文件夹
+(NSArray*)getSubDirectories:(NSString*)path{
	
	NSFileManager* fm = [NSFileManager defaultManager];
	NSError* dataError = nil;
	NSArray* subs = [fm subpathsOfDirectoryAtPath:path error:&dataError];
	NSMutableArray* muArray=[[NSMutableArray alloc] init];
	for(int i=0;i<subs.count;i++)
	{
		NSString* str= [subs objectAtIndex:i];
		NSRange range = [str rangeOfString : @"/"];
		NSRange rangeFile = [str rangeOfString : @"."];
		if (range.location == NSNotFound&&rangeFile.location == NSNotFound){
			str=[path stringByAppendingPathComponent:str];
			[muArray addObject:str];
		}
	}
	if(!subs)
		NSLog(@"Error: %@",dataError);
	return muArray;
}
//删除过期文件
+(void)deleteOverDueAppFolder:(void(^)(void))complete{
	
    
    //此处可以GCD
	[NSThread detachNewThreadSelector:@selector(deleteAppFolder) toTarget:[CacheHelper class] withObject:nil];
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        // 处理耗时操作的代码块...
        
        [self deleteAppFolder];
        
        //通知主线程刷新
        dispatch_async(dispatch_get_main_queue(), ^{
            //回调或者说是通知主线程刷新，
            
            if (complete) {
                complete();
            }
        });
        
    });
    
}

+(void)deleteAppFolder{
	NSString* smallIcons=[CacheHelper getFileFullPathByRelativePathAT:rootFolder,nil];
	NSArray *dataFiles = [CacheHelper getSubDirectories:smallIcons];
	for (int i=0; i<[dataFiles count]; i++)
	{
		NSString* appFolder=[dataFiles objectAtIndex:i];
		[CacheHelper deleteFolderAtFolderPath:appFolder];
	}
    
    
    //清除webView的缓存
    [[NSURLCache sharedURLCache] removeAllCachedResponses];
}


+(long long)fileSizeAtPath:(NSString *)filePath
{
    NSFileManager* manager = [NSFileManager defaultManager];
    
    if ([manager fileExistsAtPath:filePath]){
        
        return [[manager attributesOfItemAtPath:filePath error:nil] fileSize];
    }
    return 0;
}

//计算文件大小
+ (float)folderSizeAtPath:(NSString *)folderPath
{
    NSLog(@"文件大小路径%@",[DOCUMENTS_FOLDER stringByAppendingPathComponent:@"/TooTooImageChache"]);
    
    NSFileManager* manager = [NSFileManager defaultManager];
    
    if (![manager fileExistsAtPath:folderPath]) return 0;
    
    NSEnumerator *childFilesEnumerator = [[manager subpathsAtPath:folderPath] objectEnumerator];
    
    NSString* fileName;
    
    long long folderSize = 0;
    
    while ((fileName = [childFilesEnumerator nextObject]) != nil){
        
        NSString* fileAbsolutePath = [folderPath stringByAppendingPathComponent:fileName];
        
        folderSize += [CacheHelper fileSizeAtPath:fileAbsolutePath];
        
    }
    
    return folderSize/(1024.0*1024.0);
}

#pragma mark - -z再封装 统一nsdata，nsarray，nsdictionary的存储
#pragma mark -存本地数据
//没有数据返回nil，有数据返回相应的数据【也即数组返回数组，字典返回字典，其他数据类型统一返回nsdata】。（ 由[NSData dataWithContentsOfFile:filePath]; 导致的）
+ (id)getCacheDataByFolderPath:(NSString *)folderPath fileName:(NSString *)fileName{
    
    id data = nil;
    NSString *filePath = [CacheHelper getFilePath:folderPath fileName:fileName];

    //依次判断数据的类型并返回(注意：没有数据返回nil，有数据返回相应的数据【也即数组返回数组，字典返回字典，其他数据类型统一返回nsdata】。)
    data = [CacheHelper getArrayByFilePath:filePath];
    if (data) {
        return data;
    }
    data = [CacheHelper getDictionaryByFilePath:filePath];
    if (data) {
        return data;
    }
    data = [CacheHelper getDataByFilePath:filePath];
    if (data) {
        return data;
    }
    return data;
}
#pragma mark -取本地数据
+ (void)saveCacheData:(id)data folderPath:(NSString *)folderPath fileName:(NSString *)fileName{
    
    NSString *filePath = [CacheHelper getFilePath:folderPath fileName:fileName];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        BOOL isSuccess = NO;
        if ([data isKindOfClass:[NSData class]]) {
            isSuccess = [CacheHelper saveCacheData:data path:filePath];
        }
        if ([data isKindOfClass:[NSArray class]]) {
            isSuccess = [CacheHelper saveCacheArray:data path:filePath];
        }
        if ([data isKindOfClass:[NSDictionary class]]) {
            isSuccess = [CacheHelper saveCacheDictionary:data path:filePath];
        }
        if (!isSuccess) {
            NSLog(@"write failed:%@",fileName);
        }
    });

}

+ (BOOL)saveCacheDataOnCurThread:(id)data folderPath:(NSString *)folderPath fileName:(NSString *)fileName{
    
    NSString *filePath = [CacheHelper getFilePath:folderPath fileName:fileName];
        BOOL isSuccess = NO;
        if ([data isKindOfClass:[NSData class]]) {
            isSuccess = [CacheHelper saveCacheData:data path:filePath];
        }
        if ([data isKindOfClass:[NSArray class]]) {
            isSuccess = [CacheHelper saveCacheArray:data path:filePath];
        }
        if ([data isKindOfClass:[NSDictionary class]]) {
            isSuccess = [CacheHelper saveCacheDictionary:data path:filePath];
        }
        if (!isSuccess) {
            NSLog(@"write failed:%@",fileName);
        }
    return isSuccess;
}

#pragma mark -tool
+ (NSDictionary *)deleteNullWithDic:(NSDictionary *)dict{
    
    NSMutableDictionary *mutableDic = [[NSMutableDictionary alloc] init];
    for (NSString *keyStr in dict.allKeys) {
        
        if ([[dict objectForKey:keyStr] isEqual:[NSNull null]]) {
            
            [mutableDic setObject:@"" forKey:keyStr];
        }
        else{
            
            [mutableDic setObject:[dict objectForKey:keyStr] forKey:keyStr];
        }
    }
    return mutableDic;
}

#pragma mark C方式 获取app常用文件路径 Document、Cache、Temp
NSString * pathdwf(NSString *format, ...)
{
    va_list args;
    va_start(args, format);
    NSString *str = [[NSString alloc] initWithFormat:format arguments:args];
    va_end(args);
    
    NSString *documentPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    
    return [documentPath stringByAppendingPathComponent:str];
}

NSString * pathcwf(NSString *format, ...)
{
    va_list args;
    va_start(args, format);
    NSString *str = [[NSString alloc] initWithFormat:format arguments:args];
    va_end(args);
    
    NSString *cachePath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    
    return [cachePath stringByAppendingPathComponent:str];
}

NSString * pathtwf(NSString *format, ...)
{
    va_list args;
    va_start(args, format);
    NSString *str = [[NSString alloc] initWithFormat:format arguments:args];
    va_end(args);
    
    NSString *tempPath = NSTemporaryDirectory();
    
    return [tempPath stringByAppendingPathComponent:str];
}

NSString * uuid()
{
    CFUUIDRef   uuid_ref        = CFUUIDCreate(NULL);
    CFStringRef uuid_string_ref = CFUUIDCreateString(NULL, uuid_ref);
    
    CFRelease(uuid_ref);
    
    NSString *uuid = [NSString stringWithString:(__bridge NSString*)uuid_string_ref];
    
    CFRelease(uuid_string_ref);
    
    return uuid;
}

NSString * dfn(NSString *ext)
{
    return [NSString stringWithFormat:@"%f.%@", [[NSDate date] timeIntervalSince1970], ext];
}

void runDispatchGetMainQueue(void (^block)(void))
{
    if ([NSThread isMainThread])
    {
        block();
    }
    else
    {
        dispatch_sync(dispatch_get_main_queue(), block);
    }
}

void runDispatchGetGlobalQueue(void (^block)(void))
{
    dispatch_queue_t dispatchQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(dispatchQueue, block);
}

#pragma mark 文件通用存储位置
//所有基础文件的保存路径
+(NSString*)pathForCommonFile:(NSString *)fileName withType:(NSInteger)fileType{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *commonDirectory = [documentsDirectory stringByAppendingPathComponent:@"commonFile"];
    
    BOOL isDir;
    NSError* error;
    NSFileManager *fileManager= [NSFileManager defaultManager];
    if(![fileManager fileExistsAtPath:commonDirectory isDirectory:&isDir]){
        if (![fileManager createDirectoryAtPath:commonDirectory withIntermediateDirectories:YES attributes:nil error:&error]) {
            NSLog(@"can not create common directory");
            return nil;
        }
    }
    
    NSString* tempPath;
    
    switch (fileType) {
        case SourceTypeIMAGE_JPG:{
            tempPath =  [NSString stringWithFormat:@"%@/commonfile_%@.jpg",commonDirectory,fileName];
            break;
        }
        case SourceTypeIMAGE_PNG:{
            tempPath =  [NSString stringWithFormat:@"%@/commonfile_%@.png",commonDirectory,fileName];
            break;
        }
        case SourceTypeVOICE_MP3:{
            if ([fileName hasSuffix:@"mp3"]) {
                tempPath = [NSString stringWithFormat:@"%@/commonfile_%@",commonDirectory,fileName];
            } else {
                tempPath = [NSString stringWithFormat:@"%@/commonfile_%@.mp3",commonDirectory,fileName];
            }
            break;
        }
        case SourceTypeVOICE_CAF:{
            tempPath =  [NSString stringWithFormat:@"%@/commonfile_%@.caf",commonDirectory,fileName];
            break;
        }
        case SourceTypeVIDEO_MP4:{
            if ([fileName hasSuffix:@"mp4"]) {
                tempPath = [NSString stringWithFormat:@"%@/commonfile_%@",commonDirectory,fileName];
            } else {
                tempPath = [NSString stringWithFormat:@"%@/commonfile_%@.mp4",commonDirectory,fileName];
            }
            break;
        }
        default:
            tempPath =  [NSString stringWithFormat:@"%@/commonfile_%@",commonDirectory,fileName];
    }
    return tempPath;
}

@end
