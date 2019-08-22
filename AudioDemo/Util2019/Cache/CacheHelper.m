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

#define Config_LastCleanImageTime @"Config_LastCleanImageTime"

@implementation CacheHelper

#pragma mark - 检查
//检查文件与文件夹是否存在
+(BOOL)checkFileExist:(NSString *)filePath
{
    return [[NSFileManager defaultManager] fileExistsAtPath:filePath];
}

+(void)judgeImageCacheValidDate
{
    NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
    NSDate * lastDate = [userDefaults objectForKey:Config_LastCleanImageTime];
    if (lastDate == nil) {
        [userDefaults setObject:[NSDate date] forKey:Config_LastCleanImageTime];
        [userDefaults synchronize];
        return;
    }
    if ([[NSDate date] timeIntervalSinceReferenceDate]-[lastDate timeIntervalSinceReferenceDate] >= 24*60*60/*一天*/)
    {
        //删除缓存
        [CacheHelper deleteOverDueAppFolder:nil];
        [userDefaults setObject:[NSDate date] forKey:Config_LastCleanImageTime];
        [userDefaults synchronize];
    }
}

#pragma mark - 创建文件夹
//创建本地文件夹 通过文件名 (默认路径Documents)
+(BOOL)createFolderWithFolderName:(NSString *)folderName
{
    NSError *error;
    NSFileManager *manager = [NSFileManager defaultManager];
    NSString *diskCachePath = pathdwf(folderName);
    return [manager createDirectoryAtPath:diskCachePath withIntermediateDirectories:YES attributes:nil error:&error];
}
//创建本地文件夹 通过文件夹路径
+(BOOL)createFolderWithFolderPath:(NSString*)folderPath{
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

#pragma mark -获取文件路径
//根据文件夹和文件名获取完整 文件路径名
+ (NSString *)getFilePathWithFolderPath:(NSString *)folderPath fileName:(NSString *)fileName{
    
    if (![CacheHelper checkFileExist:folderPath]) {
        [CacheHelper createFolderWithFolderPath:folderPath];
    }
    //folderPath:所有文件存储目录
    NSString *filePath = [folderPath stringByAppendingPathComponent:fileName];
    //NSLog(@"filePath:%@",filePath);
    return filePath;
}

//根据文件夹名和文件名获取完整 文件路径名（默认的Documents目录下）
+ (NSString *)cachePathForFolderName:(NSString*)folderName FileName:(NSString *)fileName
{
    NSString *diskCachePath = pathdwf(folderName);
    //检查目的文件夹 若不存在则创建
    if (![CacheHelper checkFileExist:diskCachePath]) {
        return [CacheHelper getFilePathWithFolderPath:diskCachePath fileName:fileName];
    }
    //diskcachepath:所有文件存储目录
    return [diskCachePath stringByAppendingPathComponent:fileName];
}

#pragma mark 文件处理 (获取新文件路径：1.有新的文件名，则优先使用，否则用旧路径中的文件名 2.有新文件夹路径，则优先使用，否则用默认的文件夹路径CachePath)
//文件路径
+ (NSString *)getNewFilePathWithOriginFilePath:(NSString *)originFilePath newFolderPath:(NSString *)newFolderPath newFileName:(NSString *)newFileName pathExtension:(NSString *)pathExtension
{
    if (!newFileName) {
        newFileName = [self getNewFileNameWithOriginFilePath:originFilePath newFileName:nil pathExtension:pathExtension];
    }
    if (!newFolderPath) {
        newFolderPath = CachePath;
    }
    NSString *newFilePath = [CacheHelper getFilePathWithFolderPath:newFolderPath fileName:newFileName];
    return newFilePath;
}
//文件名
+ (NSString *)getNewFileNameWithOriginFilePath:(NSString *)originFilePath newFileName:(NSString *)newFileName pathExtension:(NSString *)pathExtension
{
    if (!newFileName) {
        newFileName = [originFilePath lastPathComponent];
        newFileName = [newFileName stringByDeletingPathExtension];
    }
    if (![newFileName hasSuffix:pathExtension]) {
        newFileName = [newFileName stringByAppendingPathExtension:pathExtension];
    }
    return newFileName;
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

#pragma mark - 删除

+(BOOL)deleteFolderAtFolderPath:(NSString*)folderPath{
	
	NSError *dataError = nil;
	NSFileManager *fm = [NSFileManager defaultManager];
	BOOL delete=[fm removeItemAtPath:folderPath error:&dataError];
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

#pragma mark 删除文件（指定路径下的所有文件）
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
	NSString* rootFolderPath =[CacheHelper getFullFilePathByRelativePathAT:rootFolder,@"time/my",@"hello",nil];
	NSArray *dataFiles = [CacheHelper getSubDirectories:rootFolderPath];
	for (int i=0; i<[dataFiles count]; i++)
	{
		NSString* appFolder=[dataFiles objectAtIndex:i];
		[CacheHelper deleteFolderAtFolderPath:appFolder];
	}
    //清除webView的缓存
    [[NSURLCache sharedURLCache] removeAllCachedResponses];
}

/*
 现在总结一下va_list、va_start和va_end三个宏的用法。
 c语言提供了函数的不定长参数使用，比如 void func(int a, …)。三个省略号，表示了不定长参数。注意：c标准规定了，函数必须至少有一个明确定义的参数，因此，省略号前面必须有至少一个参数。
 va_list宏定义了一个指针类型，这个指针类型指向参数列表中的参数。
 void va_start(va_list ap, last_arg)，修改了用va_list申明的指针，比如ap，使这个指针指向了不定长参数列表省略号前的参数。
 type va_arg(va_list, type)，获取参数列表的下一个参数，并以type的类型返回。
 void va_end(va_list ap)， 参数列表访问完以后，参数列表指针与其他指针一样，必须收回，否则出现野指针。一般va_start 和va_end配套使用。
 ————————————————
 */
#pragma mark 文件路径 （支持单级或者多级文件路径拼接）
//多级文件路径拼接
+(NSString*)getFullFilePathByRelativePathAT:(NSString *)relativeFilePath, ...{
    NSString * result = NULL;
    va_list argumentList;
    if (relativeFilePath){
        result= [CacheHelper CombineFilePathWithFilePath:DOCUMENTS_FOLDER relativeFilePath:relativeFilePath];
        va_start(argumentList, relativeFilePath);
        result= [self CombinFilePath:result para:argumentList];
        va_end(argumentList);
    }
    return result;
}
+(NSString*) CombinFilePath:(NSString*)head para:(va_list)paramsList{
    NSString * result=head;
    NSString * eachObject;
    while ((eachObject = va_arg(paramsList, NSString*))){
        result= [CacheHelper CombineFilePathWithFilePath:result relativeFilePath:eachObject];
    }
    return result;
}
//单级文件路径拼接
+(NSString*)CombineFilePathWithFilePath:(NSString*)filePath relativeFilePath:(NSString*)relativeFilePath{
    
    if ( ([filePath hasSuffix:FILE_SLASH]) || ([relativeFilePath hasPrefix:FILE_SLASH]) ) {
        return [filePath stringByAppendingString:relativeFilePath];
    }else {
        return [NSString stringWithFormat:@"%@/%@",filePath,relativeFilePath];
    }
}
#pragma mark 获得指定路径下的所有子文件夹
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
    NSString *filePath = [CacheHelper getFilePathWithFolderPath:folderPath fileName:fileName];

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
    
    NSString *filePath = [CacheHelper getFilePathWithFolderPath:folderPath fileName:fileName];
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
    
    NSString *filePath = [CacheHelper getFilePathWithFolderPath:folderPath fileName:fileName];
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
