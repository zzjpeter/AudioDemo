//
//  UrlLabel.h
//  Practice
//
//  Created by ning liu on 2018/3/5.
//  Copyright © 2018年 ning liu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YYKit.h"

NS_ASSUME_NONNULL_BEGIN


typedef NS_ENUM(NSInteger,CopyLabelStatus) {
    COPY_LABEL, //只有复制功能label
    COPY_PASTE_LABEL,  //有复制和粘贴功能label
    UNCLICK_LABEL,  //不可点击
};


typedef void(^TapAction)(NSAttributedString * _Nonnull text, NSRange range, NSAttributedString *customText);
typedef void(^LongPressActions)(NSAttributedString * _Nonnull text, NSRange range, NSAttributedString *customText);

@interface UrlLabel : YYLabel


//创建Label时可根据不同的类型来实现不同的功能
@property (nonatomic, assign) CopyLabelStatus labelType;

#pragma mark -基本使用
//左右对齐
-(void)setText:(NSString *)text textColor:(UIColor *)textColor font:(UIFont *)font urlColor:(UIColor *)urlColor urlTapBlock:(void(^)(NSURL *url))urlBlock;

//自定义对齐方式
-(void)setText:(NSString *)text textColor:(UIColor *)textColor font:(UIFont *)font urlColor:(UIColor *)urlColor textAligment:(NSTextAlignment)textAligment urlTapBlock:(void(^)(NSURL *url))urlBlock;

#pragma mark -高级使用
//自定义对齐方式 自定义customRanges
-(void)setText:(NSString *)string textColor:(UIColor *)textColor font:(UIFont *)font urlColor:(UIColor *)urlColor textAligment:(NSTextAlignment)textAligment customRanges:(nullable NSArray *)customRanges urlTapBlock:(void(^)(NSURL *url))urlBlock;

//自定义对齐方式 自定义customRanges 以及颜色
-(void)setText:(NSString *)string textColor:(UIColor *)textColor font:(UIFont *)font urlColor:(UIColor *)urlColor textAligment:(NSTextAlignment)textAligment customRanges:(nullable NSArray *)customRanges customColor:(nullable UIColor *)customColor urlTapBlock:(void(^)(NSURL *url))urlBlock;

//自定义对齐方式 自定义customRanges 以及颜色 lineSpacing
-(void)setText:(NSString *)string textColor:(UIColor *)textColor font:(UIFont *)font urlColor:(UIColor *)urlColor textAligment:(NSTextAlignment)textAligment customRanges:(nullable NSArray *)customRanges customColor:(nullable UIColor *)customColor lineSpacing:(CGFloat)lineSpacing urlTapBlock:(void(^)(NSURL *url))urlBlock;

// 自定义对齐方式 自定义customRanges 以及颜色和字体大小 lineSpacing
-(void)setText:(NSString *)string textColor:(UIColor *)textColor font:(UIFont *)font urlColor:(UIColor *)urlColor textAligment:(NSTextAlignment)textAligment customRanges:(nullable NSArray *)customRanges customColor:(nullable UIColor *)customColor customFont:(nullable UIFont *)customFont lineSpacing:(CGFloat)lineSpacing urlTapBlock:(void(^)(NSURL *url))urlBlock;

// 自定义对齐方式 自定义customRanges 以及颜色和字体大小 lineSpacing 自定义部分的点击和长按事件 返回text
-(void)setText:(NSString *)string textColor:(UIColor *)textColor font:(UIFont *)font urlColor:(UIColor *)urlColor textAligment:(NSTextAlignment)textAligment customRanges:(nullable NSArray *)customRanges customTapAction:(nullable TapAction)tapAction customLongPressAction:(nullable LongPressActions)longPressAction customColor:(nullable UIColor *)customColor customFont:(nullable UIFont *)customFont lineSpacing:(CGFloat)lineSpacing urlTapBlock:(void(^)(NSURL *url))urlBlock;

//带html基本标签解析功能，场景 一般用在解析html标识的富文本中
-(void)setHtmlText:(NSString *)string textColor:(UIColor *)textColor font:(UIFont *)font textAligment:(NSTextAlignment)textAligment urlColor:(UIColor *)urlColor urlTapBlock:(void(^)(NSURL *url))urlBlock;
@end

NS_ASSUME_NONNULL_END
