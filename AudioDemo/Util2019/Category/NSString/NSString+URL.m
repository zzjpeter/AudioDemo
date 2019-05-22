//
//  NSString+URL.m
//  FbeeAPP
//
//  Created by zhuzj on 2018/4/3.
//  Copyright © 2018年 mohao. All rights reserved.
//

#import "NSString+URL.h"
#import "NSString+EncodeUrl.h"
#import "NSString+Empty.h"
@implementation NSString (URL)

//把web url get 请求转化成字典
+(NSDictionary *)getDictByRequstStrNSUrl:(NSString *)urlStr
{
    if (urlStr == nil && [urlStr isEqualToString:@""]) {
        return @{};
    }
    
    NSURL *url = [NSURL URLWithString:urlStr];
    
//    NSLog(@"Scheme: %@", [url scheme]);
//    NSLog(@"Host: %@", [url host]);
//    NSLog(@"Port: %@", [url port]);
//    NSLog(@"Path: %@", [url path]);
//    NSLog(@"Relative path: %@", [url relativePath]);
//    NSLog(@"Path components as array: %@", [url pathComponents]);
//    NSLog(@"Parameter string: %@", [url parameterString]);
//    NSLog(@"Query: %@", [url query]);
//    NSLog(@"Fragment: %@", [url fragment]);
//    NSLog(@"User: %@", [url user]);
//    NSLog(@"Password: %@", [url password]);
    
    
    NSMutableDictionary *urlDict = [NSMutableDictionary new];
    //解析文件路径 用url.path
    if (url.path) {
        
        NSString *path = url.path;
        NSArray *pathDirs = [path componentsSeparatedByString:@"/"];
        
        //剔除"空串"
        NSMutableArray *tempPathDirs = [NSMutableArray arrayWithArray:pathDirs];
        [tempPathDirs enumerateObjectsUsingBlock:^(NSString *dir, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([NSString isEmptyString:dir]) {
                [tempPathDirs removeObject:dir];
            }
        }];
        pathDirs = [tempPathDirs copy];
        
        if (pathDirs.count > 0) {
            [urlDict setObject:pathDirs forKey:@"pathDir"];
        }else{
            [urlDict setObject:[NSArray new] forKey:@"pathDir"];
        }
        
    }
    
    //解析参数
    if (url.query) {
        
        NSString *query = url.query;
        
        if (!query)
        {
            [urlDict setObject:[NSDictionary new] forKey:@"parameters"];
        }else
        {
            
            NSArray *parameters = [query componentsSeparatedByString:@"&"];
            
            NSDictionary *parameterDict = [NSDictionary new];
            if (parameters.count > 0) {
                
                NSMutableDictionary *tempParameterDict = [NSMutableDictionary new];
                for (NSString *parametersStr in parameters) {
                    
                    NSRange range = [parametersStr rangeOfString:@"="];
                    if (range.location != NSNotFound) {
                        NSString *keyName = [parametersStr substringToIndex:range.location];
                        NSString *keyValue = [parametersStr substringFromIndex:range.location+1];
                        [tempParameterDict setObject:keyValue forKey:keyName];
                    }
                }
                
                parameterDict = [tempParameterDict copy];
            }
            
            [urlDict setObject:parameterDict forKey:@"parameters"];
        }
        
    }
    
//    NSLog(@"urlDict:%@",urlDict);
    
    if (urlDict.count > 0) {
        return urlDict;
    }
    
    return @{};
}

+(NSDictionary *)getDictByRequstStrNSUrl1:(NSString *)urlStr
{
    if (urlStr == nil && [urlStr isEqualToString:@""]) {
        return @{};
    }
    
    NSURL *url = [NSURL URLWithString:urlStr];
    
//    NSLog(@"Scheme: %@", [url scheme]);
//    NSLog(@"Host: %@", [url host]);
//    NSLog(@"Port: %@", [url port]);
//    NSLog(@"Path: %@", [url path]);
//    NSLog(@"Relative path: %@", [url relativePath]);
//    NSLog(@"Path components as array: %@", [url pathComponents]);
//    NSLog(@"Parameter string: %@", [url parameterString]);
//    NSLog(@"Query: %@", [url query]);
//    NSLog(@"Fragment: %@", [url fragment]);
//    NSLog(@"User: %@", [url user]);
//    NSLog(@"Password: %@", [url password]);
    
    
    NSMutableDictionary *urlDict = [NSMutableDictionary new];
    //解析文件路径 用url.pathComponents
    if (url.pathComponents) {
        
        if (url.pathComponents.count > 0) {
            
            NSArray *pathDirs = url.pathComponents;
            
            //剔除"/"
            NSMutableArray *tempPathDirs = [NSMutableArray arrayWithArray:pathDirs];
            [tempPathDirs enumerateObjectsUsingBlock:^(NSString *dir, NSUInteger idx, BOOL * _Nonnull stop) {
                if ([dir isEqualToString:@"/"]) {
                    [tempPathDirs removeObject:dir];
                }
            }];
            pathDirs = [tempPathDirs copy];
            
            [urlDict setObject:pathDirs forKey:@"pathDir"];
        }else{
            [urlDict setObject:[NSArray new] forKey:@"pathDir"];
        }
    }
    
    //解析参数
    if (url.query) {
        
        NSString *query = url.query;
        
        if (!query)
        {
            [urlDict setObject:[NSDictionary new] forKey:@"parameters"];
        }else
        {
            
            NSArray *parameters = [query componentsSeparatedByString:@"&"];
            
            NSDictionary *parameterDict = [NSDictionary new];
            if (parameters.count > 0) {
                
                NSMutableDictionary *tempParameterDict = [NSMutableDictionary new];
                for (NSString *parametersStr in parameters) {
                    
                    NSRange range = [parametersStr rangeOfString:@"="];
                    if (range.location != NSNotFound) {
                        NSString *keyName = [parametersStr substringToIndex:range.location];
                        NSString *keyValue = [parametersStr substringFromIndex:range.location+1];
                        [tempParameterDict setObject:keyValue forKey:keyName];
                    }
                }
                
                parameterDict = [tempParameterDict copy];
            }
            
            [urlDict setObject:parameterDict forKey:@"parameters"];
        }

    }
    
    if (urlDict.count > 0) {
        return urlDict;
    }
    
    return @{};
}


//思路：根据url的命名规则，通过“?”“&”“=”识别出参数，通过字符串截取方法，快速的把url中的parameters截取下来。
+(NSDictionary *)getDictByRequstStrString:(NSString *)urlStr{
    
    if (urlStr == nil && [urlStr isEqualToString:@""]) {
        return @{};
    }
    
    urlStr = [urlStr stringByURLDecode];
    
    NSMutableDictionary *urlDict = [NSMutableDictionary new];
    
    NSRange range = [urlStr rangeOfString:@"?"];
    
    if (range.location != NSNotFound && range.length != 0) {
        
        //解析文件路径
        NSString *preStr = [urlStr substringToIndex:range.location + range.length - 1];
        
        if (preStr) {
            
            NSRange range1 = [preStr rangeOfString:@"//"];
            
            NSString *pathDir = [preStr substringFromIndex:range1.location + range1.length];
            
            
            NSArray *pathComponents = [pathDir componentsSeparatedByString:@"/"];
            
            //剔除"空串"
            NSMutableArray *tempPathComponents = [NSMutableArray arrayWithArray:pathComponents];
            [tempPathComponents enumerateObjectsUsingBlock:^(NSString *dir, NSUInteger idx, BOOL * _Nonnull stop) {
                if ([NSString isEmptyString:dir]) {
                    [tempPathComponents removeObject:dir];
                }
            }];
            
            //剔除 第一个 域名
            [tempPathComponents removeObjectAtIndex:0];
            
            [urlDict setObject:[tempPathComponents copy] forKey:@"pathDir"];
        }else{
            [urlDict setObject:[NSArray new] forKey:@"pathDir"];
        }
        
        
        
        //解析参数
        NSString *query = [urlStr substringFromIndex:range.location + range.length];
        if (query) {
            
            NSArray *parameters = [query componentsSeparatedByString:@"&"];
            
            NSDictionary *parameterDict = [NSDictionary new];
            if (parameters.count > 0) {
                
                NSMutableDictionary *tempParameterDict = [NSMutableDictionary new];
                for (NSString *parametersStr in parameters) {
                    
                    //根据=分割key value
                    NSRange range = [parametersStr rangeOfString:@"="];
                    if (range.location != NSNotFound) {
                        NSString *keyName = [parametersStr substringToIndex:range.location];
                        NSString *keyValue = [parametersStr substringFromIndex:range.location+1];
                        [tempParameterDict setObject:keyValue forKey:keyName];
                    }
                }
                
                parameterDict = [tempParameterDict copy];
            }
            
            [urlDict setObject:parameterDict forKey:@"parameters"];
        }else{
            [urlDict setObject:[NSDictionary new] forKey:@"parameters"];
        }
        
    }else{
        //是否存在url 存在解析文件路径
        if ([urlStr containsString:@"//"]) {
            //解析文件路径
            NSString *preStr = urlStr;
            
            if (preStr) {
                
                NSRange range1 = [preStr rangeOfString:@"//"];
                
                NSString *pathDir = [preStr substringFromIndex:range1.location + range1.length];
                
                
                NSArray *pathComponents = [pathDir componentsSeparatedByString:@"/"];
                
                //剔除"空串"
                NSMutableArray *tempPathComponents = [NSMutableArray arrayWithArray:pathComponents];
                [tempPathComponents enumerateObjectsUsingBlock:^(NSString *dir, NSUInteger idx, BOOL * _Nonnull stop) {
                    if ([NSString isEmptyString:dir]) {
                        [tempPathComponents removeObject:dir];
                    }
                }];
                
                //剔除 第一个 域名
                [tempPathComponents removeObjectAtIndex:0];
                
                [urlDict setObject:[tempPathComponents copy] forKey:@"pathDir"];
            }else{
                [urlDict setObject:[NSArray new] forKey:@"pathDir"];
            }
            
        }
    }
    
    //    NSLog(@"urlDict:%@",urlDict);
    if (urlDict.count > 0) {
        return urlDict;
    }
    
    return @{};
}

@end
