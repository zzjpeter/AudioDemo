//
//  NSString+TTAdd.m
//  VMall
//
//  Created by ning liu on 2017/11/23.
//  Copyright © 2017年 mohao. All rights reserved.
//

#import "NSString+TTAdd.h"

@implementation NSString (TTAdd)

//+(BOOL)isEmptyString:(NSString *)str
//{
//    if (!str) {
//        return YES;
//    }
//    
//    if ([str isKindOfClass:[NSNull class]]) {
//        return YES;
//    }
//    
//    if (str.length == 0) {
//        return YES;
//    }
//    
//    if ([str isEqualToString:@""]) {
//        return YES;
//    }
//    
//    return NO;
//}

//获取多语言大写首字母
-(NSString *)firstCharactor
{
    if ([NSString isEmptyString:self]) {
        return self;
    }
    
    //转成了可变字符串
    NSMutableString *str = [NSMutableString stringWithString:self];
    //先转换为带声调的拼音(多语言)
    CFStringTransform((CFMutableStringRef)str,NULL, kCFStringTransformToLatin,NO);
    //再转换为不带声调的拼音（多语言）
    CFStringTransform((CFMutableStringRef)str,NULL, kCFStringTransformStripDiacritics,NO);
    //转化为大写
    NSString *letter = [str capitalizedString];
    //获取并返回首字母
    return [letter substringToIndex:1];
    
    return str;
}

//@宁
-(float)heightByWidth:(float)width font:(UIFont *)font lineSpacing:(float)lineHeight alignment:(NSTextAlignment)alignment lineBreakMode:(NSLineBreakMode)breakMode
{
    
    NSMutableDictionary *attr = [NSMutableDictionary new];
    attr[NSFontAttributeName] = font;
    NSMutableParagraphStyle *paragraphStyle = [NSMutableParagraphStyle new];
    paragraphStyle.lineBreakMode = breakMode;
    [paragraphStyle setLineSpacing:lineHeight];
    [paragraphStyle setAlignment:alignment];
    attr[NSParagraphStyleAttributeName] = paragraphStyle;
    CGRect rect = [self boundingRectWithSize:CGSizeMake(width, CGFLOAT_MAX)
                                     options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading
                                  attributes:attr context:nil];
    return rect.size.height;
}
-(float)widthByHeight:(float)height font:(UIFont *)font lineSpacing:(float)lineHeight alignment:(NSTextAlignment)alignment lineBreakMode:(NSLineBreakMode)breakMode
{
    
    NSMutableDictionary *attr = [NSMutableDictionary new];
    attr[NSFontAttributeName] = font;
    NSMutableParagraphStyle *paragraphStyle = [NSMutableParagraphStyle new];
    paragraphStyle.lineBreakMode = breakMode;
    [paragraphStyle setLineSpacing:lineHeight];
    [paragraphStyle setAlignment:alignment];
    attr[NSParagraphStyleAttributeName] = paragraphStyle;
    CGRect rect = [self boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, height)
                                     options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading
                                  attributes:attr context:nil];
    return rect.size.width;
}

-(float)heightByWidth:(float)width font:(UIFont *)font
{
    NSAttributedString *attributedText =[[NSAttributedString alloc]
                                         initWithString:self
                                         attributes:@{ NSFontAttributeName: font}] ;
    
    CGRect paragraphRect =
    [attributedText boundingRectWithSize:CGSizeMake(width, CGFLOAT_MAX)
                                 options:(NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading)
                                 context:nil];
    
    return ceilf(paragraphRect.size.height) ;
}

-(float)widthByHeight:(float)height font:(UIFont *)font
{
    NSAttributedString *attributedText =[[NSAttributedString alloc]
                                         initWithString:self
                                         attributes:@{ NSFontAttributeName: font}] ;
    
    CGRect paragraphRect =
    [attributedText boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, height)
                                 options:(NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading)
                                 context:nil];
    
    return ceilf(paragraphRect.size.width) ;
}

-(NSString *)dateFormatterFromFor:(NSString *)fromFor toFor:(NSString *)toFor{
    //日期格式转换
    NSDateFormatter *dataFormatter=[[NSDateFormatter alloc]init];
    [dataFormatter setDateFormat:fromFor];
    NSDate *data=[dataFormatter dateFromString:self];
    
    NSDateFormatter *toDataFormatter=[[NSDateFormatter alloc]init];
    [toDataFormatter setDateFormat:toFor];
    
    return  [toDataFormatter stringFromDate:data];
}



@end
