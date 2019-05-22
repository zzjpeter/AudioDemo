//
//  NSString+URL.h
//  FbeeAPP
//
//  Created by zhuzj on 2018/4/3.
//  Copyright © 2018年 mohao. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (URL)

//使用注意：是基于url进行解析的 所以url必须是合法的 否则返回 空字典
/*
 demo:
    NSString *urlStr = @"fbee://jump.fbee.one/topic/test/?key=b8ca8275e301464a99b2e1a484a2aa0f&key1=0e6db54b065b4d669842b1e5260bee10&key2=https://www.fbee.site/signed?gid=6e1655d2e17f489eae57b565b9e275b7";
 result:
 urlDict:{
     parameters =     {
        key = b8ca8275e301464a99b2e1a484a2aa0f;
        key1 = 0e6db54b065b4d669842b1e5260bee10;
        key2 = "https://www.fbee.site/signed?gid=6e1655d2e17f489eae57b565b9e275b7";
     };
     pathDir =     (
        topic,
        test
     );
 }
 
 demo:
 NSString *urlStr = @"fbee://jump.fbee.one/topic/test/中国?key=b8ca8275e301464a99b2e1a484a2aa0f&key1=0e6db54b065b4d669842b1e5260bee10&key2=中国&key3=https://www.fbee.site/signed?gid=6e1655d2e17f489eae57b565b9e275b7";
 result:
 2018-09-19 15:25:59.562709+0800 ManageUtil2018[12777:301288] Scheme: (null)
 2018-09-19 15:25:59.563451+0800 ManageUtil2018[12777:301288] Host: (null)
 2018-09-19 15:25:59.563971+0800 ManageUtil2018[12777:301288] Port: (null)
 2018-09-19 15:25:59.564228+0800 ManageUtil2018[12777:301288] Path: (null)
 2018-09-19 15:25:59.564400+0800 ManageUtil2018[12777:301288] Relative path: (null)
 2018-09-19 15:25:59.564465+0800 ManageUtil2018[12777:301288] Path components as array: (null)
 2018-09-19 15:25:59.564532+0800 ManageUtil2018[12777:301288] Parameter string: (null)
 2018-09-19 15:25:59.564630+0800 ManageUtil2018[12777:301288] Query: (null)
 2018-09-19 15:25:59.564695+0800 ManageUtil2018[12777:301288] Fragment: (null)
 2018-09-19 15:25:59.564759+0800 ManageUtil2018[12777:301288] User: (null)
 2018-09-19 15:25:59.564849+0800 ManageUtil2018[12777:301288] Password: (null)
 2018-09-19 15:25:59.565392+0800 ManageUtil2018[12777:301288] dic = {
 }
 2018-09-19 15:25:59.565514+0800 ManageUtil2018[12777:301288] dic1 = {
 }
 2018-09-19 15:25:59.565694+0800 ManageUtil2018[12777:301288] dic2 = {
 parameters =     {
 key = b8ca8275e301464a99b2e1a484a2aa0f;
 key1 = 0e6db54b065b4d669842b1e5260bee10;
 key2 = "\U4e2d\U56fd";
 key3 = "https://www.fbee.site/signed?gid=6e1655d2e17f489eae57b565b9e275b7";
 };
 pathDir =     (
 topic,
 test,
 "\U4e2d\U56fd"
 );
 }
 */

//使用NSURL的方法时，如果该部分包含中文就会返回nil(有此缺点，所以不推荐使用)
+(NSDictionary *)getDictByRequstStrNSUrl:(NSString *)urlStr;//解析文件路径 用url.path
+(NSDictionary *)getDictByRequstStrNSUrl1:(NSString *)urlStr;//解析文件路径 用url.pathComponents


//2.基于字符串的解析
//思路：根据url的命名规则，通过“?”“&”“=”识别出参数，通过字符串截取方法，快速的把url中的parameters截取下来。(参数解析部分 取 一个 “=” 进行键值分离)
+(NSDictionary *)getDictByRequstStrString:(NSString *)urlStr;//解析文件路径 解析参数 都用字符串切割


@end
