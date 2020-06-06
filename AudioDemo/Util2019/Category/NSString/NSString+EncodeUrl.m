//
//  NSString+EncodeUrl.m
//  FbeeAPP
//
//  Created by zhuzj on 2018/5/17.
//  Copyright © 2018年 mohao. All rights reserved.
//

#import "NSString+EncodeUrl.h"

@implementation NSString (EncodeUrl)

#pragma mark -handUrl 支持url为string和url 返回NSURL
+ (NSURL *)urlHandleUrl:(id)url{
    
    if ([url isKindOfClass:[NSString class]])
    {
        return[NSString handleUrlStrFbee:url];
    }
    
    if ([url isKindOfClass:[NSURL class]])
    {
        return [NSString handleUrlFbee:url];
    }
    
    return nil;
}
//支持url为string和url 返回NSString
+ (NSString *)urlStrHandleUrl:(id)url{
    
    if ([url isKindOfClass:[NSString class]])
    {
        return[NSString handleUrlStrFbeeStr:url];
    }
    
    if ([url isKindOfClass:[NSURL class]])
    {
        return [NSString handleUrlFbeeStr:url];
    }
    
    return nil;
}

#pragma mark -对nsurl进行urldecode再使用
//通用处理：一般最好先decode，然后再encode。（情形1.url已经encode了，先decode然后再encode。2.url未encode，先decode没有影响，然后在encode）。必须保证需要交给浏览器或者发起网络请求所需要的url，都必须是经过encode的url，这样保证url中不存在中文或者特殊字符，导致无法正常访问。
+ (NSURL *)handleUrlFbee:(NSURL *)url{
    NSString *urlStr = url.absoluteString;
    return [self handleUrlStrFbee:urlStr];
}

+ (NSURL *)handleUrlStrFbee:(NSString *)urlStr{
    urlStr = [urlStr stringByURLDecode];
    urlStr = [NSString encodeUrl:urlStr];
    return [NSURL URLWithString:urlStr];
}

+ (NSString *)handleUrlStrFbeeStr:(NSString *)urlStr{
    urlStr = [urlStr stringByURLDecode];
    urlStr = [NSString encodeUrl:urlStr];
    return urlStr;
}

+ (NSString *)handleUrlFbeeStr:(NSURL *)url{
    NSString *urlStr = url.absoluteString;
    return [self handleUrlStrFbeeStr:urlStr];
}

+ (NSString *)encodeUrl:(NSString *)urlStr{
    NSString *originalUrl = urlStr;
    NSCharacterSet *encodeUrlSet = [NSCharacterSet URLQueryAllowedCharacterSet];
    NSString *encodeUrl = [originalUrl stringByAddingPercentEncodingWithAllowedCharacters:encodeUrlSet];
    //FbeeLog(@"%@", encodeUrl);
    
    return encodeUrl;
}

//- (NSString *)base64EncodedString {
//    return [[self dataUsingEncoding:NSUTF8StringEncoding] base64EncodedStringWithOptions:0];
//}

//+ (NSString *)stringWithBase64EncodedString:(NSString *)base64EncodedString {
//    NSData *data = [[NSData alloc] initWithBase64EncodedString:base64EncodedString options:NSDataBase64DecodingIgnoreUnknownCharacters];
//    return [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
//}

//- (NSString *)stringByURLEncode {
//    if ([self respondsToSelector:@selector(stringByAddingPercentEncodingWithAllowedCharacters:)]) {
//        /**
//         AFNetworking/AFURLRequestSerialization.m
//
//         Returns a percent-escaped string following RFC 3986 for a query string key or value.
//         RFC 3986 states that the following characters are "reserved" characters.
//         - General Delimiters: ":", "#", "[", "]", "@", "?", "/"
//         - Sub-Delimiters: "!", "$", "&", "'", "(", ")", "*", "+", ",", ";", "="
//         In RFC 3986 - Section 3.4, it states that the "?" and "/" characters should not be escaped to allow
//         query strings to include a URL. Therefore, all "reserved" characters with the exception of "?" and "/"
//         should be percent-escaped in the query string.
//         - parameter string: The string to be percent-escaped.
//         - returns: The percent-escaped string.
//         */
//        static NSString * const kAFCharactersGeneralDelimitersToEncode = @":#[]@"; // does not include "?" or "/" due to RFC 3986 - Section 3.4
//        static NSString * const kAFCharactersSubDelimitersToEncode = @"!$&'()*+,;=";
//
//        NSMutableCharacterSet * allowedCharacterSet = [[NSCharacterSet URLQueryAllowedCharacterSet] mutableCopy];
//        [allowedCharacterSet removeCharactersInString:[kAFCharactersGeneralDelimitersToEncode stringByAppendingString:kAFCharactersSubDelimitersToEncode]];
//        static NSUInteger const batchSize = 50;
//
//        NSUInteger index = 0;
//        NSMutableString *escaped = @"".mutableCopy;
//
//        while (index < self.length) {
//            NSUInteger length = MIN(self.length - index, batchSize);
//            NSRange range = NSMakeRange(index, length);
//            // To avoid breaking up character sequences such as 👴🏻👮🏽
//            range = [self rangeOfComposedCharacterSequencesForRange:range];
//            NSString *substring = [self substringWithRange:range];
//            NSString *encoded = [substring stringByAddingPercentEncodingWithAllowedCharacters:allowedCharacterSet];
//            [escaped appendString:encoded];
//
//            index += range.length;
//        }
//        return escaped;
//    } else {
//#pragma clang diagnostic push
//#pragma clang diagnostic ignored "-Wdeprecated-declarations"
//        CFStringEncoding cfEncoding = CFStringConvertNSStringEncodingToEncoding(NSUTF8StringEncoding);
//        NSString *encoded = (__bridge_transfer NSString *)
//        CFURLCreateStringByAddingPercentEscapes(
//                                                kCFAllocatorDefault,
//                                                (__bridge CFStringRef)self,
//                                                NULL,
//                                                CFSTR("!#$&'()*+,/:;=?@[]"),
//                                                cfEncoding);
//        return encoded;
//#pragma clang diagnostic pop
//    }
//}

/*
 Returns a character set containing the characters allowed in an URL's query component.
 URLFragmentAllowedCharacterSet == @"#%<>[\]^`{|}"的反向集合
 [NSCharacterSet URLFragmentAllowedCharacterSet] 等价于 [NSCharacterSet characterSetWithCharactersInString:@"#%<>[\\]^`{|}"].invertedSet
 */
- (NSString *)stringByURLEncodeWithAllowedCharacterSet
{
    NSCharacterSet *encodeUrlSet = [NSCharacterSet characterSetWithCharactersInString:@"%<>[\\]^`{|}"].invertedSet;
    NSString *encodeUrl = [self stringByAddingPercentEncodingWithAllowedCharacters:encodeUrlSet];
    //NSLog(@"%@", encodeUrl);
    return encodeUrl;
}

//- (NSString *)stringByURLDecode {
//    if ([self respondsToSelector:@selector(stringByRemovingPercentEncoding)]) {
//        return [self stringByRemovingPercentEncoding];
//    } else {
//#pragma clang diagnostic push
//#pragma clang diagnostic ignored "-Wdeprecated-declarations"
//        CFStringEncoding en = CFStringConvertNSStringEncodingToEncoding(NSUTF8StringEncoding);
//        NSString *decoded = [self stringByReplacingOccurrencesOfString:@"+"
//                                                            withString:@" "];
//        decoded = (__bridge_transfer NSString *)
//        CFURLCreateStringByReplacingPercentEscapesUsingEncoding(
//                                                                NULL,
//                                                                (__bridge CFStringRef)decoded,
//                                                                CFSTR(""),
//                                                                en);
//        return decoded;
//#pragma clang diagnostic pop
//    }
//}

//- (NSString *)stringByEscapingHTML {
//    NSUInteger len = self.length;
//    if (!len) return self;
//
//    unichar *buf = malloc(sizeof(unichar) * len);
//    if (!buf) return nil;
//    [self getCharacters:buf range:NSMakeRange(0, len)];
//
//    NSMutableString *result = [NSMutableString string];
//    for (int i = 0; i < len; i++) {
//        unichar c = buf[i];
//        NSString *esc = nil;
//        switch (c) {
//            case 34: esc = @"&quot;"; break;
//            case 38: esc = @"&amp;"; break;
//            case 39: esc = @"&apos;"; break;
//            case 60: esc = @"&lt;"; break;
//            case 62: esc = @"&gt;"; break;
//            default: break;
//        }
//        if (esc) {
//            [result appendString:esc];
//        } else {
//            CFStringAppendCharacters((CFMutableStringRef)result, &c, 1);
//        }
//    }
//    free(buf);
//    return result;
//}


@end
