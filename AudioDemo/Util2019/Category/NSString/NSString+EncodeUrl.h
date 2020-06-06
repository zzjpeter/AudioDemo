//
//  NSString+EncodeUrl.h
//  FbeeAPP
//
//  Created by zhuzj on 2018/5/17.
//  Copyright © 2018年 mohao. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YYKit.h"

@interface NSString (EncodeUrl)

#pragma mark -urlHandleUrl 支持url为string和url 返回NSURL
+ (NSURL *)urlHandleUrl:(id)url;
//支持url为string和url 返回NSString
+ (NSString *)urlStrHandleUrl:(id)url;

#pragma mark -会对整个字符串进行编码，@"#%<>[\]^`{|}"，这些特殊字符编码了
+ (NSString *)encodeUrl:(NSString *)urlStr;

+ (NSURL *)handleUrlFbee:(NSURL *)url;
+ (NSURL *)handleUrlStrFbee:(NSString *)urlStr;
+ (NSString *)handleUrlStrFbeeStr:(NSString *)urlStr;
+ (NSString *)handleUrlFbeeStr:(NSURL *)url;

#pragma mark - Encode and decode
///=============================================================================
/// @name Encode and decode
///=============================================================================

/**
 Returns an NSString for base64 encoded.
 */
//- (NSString *)base64EncodedString;

/**
 Returns an NSString from base64 encoded string.
 @param base64EncodedString The encoded string.
 */
//+ (NSString *)stringWithBase64EncodedString:(NSString *)base64EncodedString;

#pragma mark -会对整个字符串进行编码，@":#[]@"，@"!$&'()*+,;="，特殊字符有这些都编码了
/**
 URL encode a string in utf-8.
 @return the encoded string.
 */
//- (NSString *)stringByURLEncode;

#pragma mark -会对指定字符串进行编码@"%<>[\]^`{|}" 去除 @"#"
- (NSString *)stringByURLEncodeWithAllowedCharacterSet;

/**
 URL decode a string in utf-8.
 @return the decoded string.
 */
//- (NSString *)stringByURLDecode;

/**
 Escape common HTML to Entity.
 Example: "a < b" will be escape to "a&lt;b".
 */
//- (NSString *)stringByEscapingHTML;

@end
