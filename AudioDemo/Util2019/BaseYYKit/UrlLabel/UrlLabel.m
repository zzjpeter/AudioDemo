//
//  UrlLabel.m
//  Practice
//
//  Created by ning liu on 2018/3/5.
//  Copyright © 2018年 ning liu. All rights reserved.
//

#import "UrlLabel.h"

//16进制转RGB
#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]
//16进制转RGB加透明度
#define UIColorFromRGBA(rgbValue,a) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:a]

#define CustomLineSpacing 9.0f
#define CustomRanageColor UIColorFromRGB(0x576B95)

@implementation UrlLabel

#pragma mark -基本使用（设置对齐方式为，左右对齐）
//默认使用--设置对齐方式为，左右对齐
-(void)setText:(NSString *)string textColor:(UIColor *)textColor font:(UIFont *)font urlColor:(UIColor *)urlColor urlTapBlock:(void(^)(NSURL *url))urlBlock
{
    [self setText:string textColor:textColor font:font urlColor:urlColor textAligment:NSTextAlignmentJustified urlTapBlock:urlBlock];
}
#pragma mark -基本使用（自定义对齐方式）
//自定义对齐方式
-(void)setText:(NSString *)string textColor:(UIColor *)textColor font:(UIFont *)font urlColor:(UIColor *)urlColor textAligment:(NSTextAlignment)textAligment urlTapBlock:(void(^)(NSURL *url))urlBlock
{
    [self setText:string textColor:textColor font:font urlColor:urlColor textAligment:textAligment customRanges:nil urlTapBlock:urlBlock];
}

#pragma mark -高级使用 （自定义customRanges）
-(void)setText:(NSString *)string textColor:(UIColor *)textColor font:(UIFont *)font urlColor:(UIColor *)urlColor textAligment:(NSTextAlignment)textAligment customRanges:(nullable NSArray *)customRanges urlTapBlock:(void(^)(NSURL *url))urlBlock
{
    [self setText:string textColor:textColor font:font urlColor:urlColor textAligment:textAligment customRanges:customRanges customColor:CustomRanageColor  urlTapBlock:urlBlock];
}

#pragma mark -高级使用（自定义对齐方式 自定义customRanges 以及颜色）
// 自定义对齐方式 自定义customRanges 以及颜色
-(void)setText:(NSString *)string textColor:(UIColor *)textColor font:(UIFont *)font urlColor:(UIColor *)urlColor textAligment:(NSTextAlignment)textAligment customRanges:(nullable NSArray *)customRanges customColor:(nullable UIColor *)customColor urlTapBlock:(void(^)(NSURL *url))urlBlock
{
    [self setText:string textColor:textColor font:font urlColor:urlColor textAligment:textAligment customRanges:customRanges customColor:customColor lineSpacing:CustomLineSpacing urlTapBlock:urlBlock];
}

// 自定义对齐方式 自定义customRanges 以及颜色 lineSpacing
-(void)setText:(NSString *)string textColor:(UIColor *)textColor font:(UIFont *)font urlColor:(UIColor *)urlColor textAligment:(NSTextAlignment)textAligment customRanges:(nullable NSArray *)customRanges customColor:(nullable UIColor *)customColor lineSpacing:(CGFloat)lineSpacing urlTapBlock:(void(^)(NSURL *url))urlBlock
{
    [self setText:string textColor:textColor font:font urlColor:urlColor textAligment:textAligment customRanges:customRanges customColor:customColor customFont:nil lineSpacing:lineSpacing urlTapBlock:urlBlock];
}

#pragma mark -高级使用（自定义对齐方式 自定义customRanges 以及颜色 lineSpacing）
// 自定义对齐方式 自定义customRanges 以及颜色和字体大小 lineSpacing
-(void)setText:(NSString *)string textColor:(UIColor *)textColor font:(UIFont *)font urlColor:(UIColor *)urlColor textAligment:(NSTextAlignment)textAligment customRanges:(nullable NSArray *)customRanges customColor:(nullable UIColor *)customColor customFont:(nullable UIFont *)customFont lineSpacing:(CGFloat)lineSpacing urlTapBlock:(void(^)(NSURL *url))urlBlock
{
    [self setText:string textColor:textColor font:font urlColor:urlColor textAligment:textAligment customRanges:customRanges customTapAction:nil customLongPressAction:nil customColor:customColor customFont:customFont lineSpacing:lineSpacing urlTapBlock:urlBlock];
}
#pragma mark -高级使用 （自定义对齐方式 自定义customRanges 以及颜色和字体大小 lineSpacing 自定义部分的点击和长按事件 返回text）
// 自定义对齐方式 自定义customRanges 以及颜色和字体大小 lineSpacing 自定义部分的点击和长按事件 返回text
-(void)setText:(NSString *)string textColor:(UIColor *)textColor font:(UIFont *)font urlColor:(UIColor *)urlColor textAligment:(NSTextAlignment)textAligment customRanges:(nullable NSArray *)customRanges customTapAction:(nullable TapAction)tapAction customLongPressAction:(nullable LongPressActions)longPressAction customColor:(nullable UIColor *)customColor customFont:(nullable UIFont *)customFont lineSpacing:(CGFloat)lineSpacing urlTapBlock:(void(^)(NSURL *url))urlBlock
{
    self.numberOfLines = 0;
    //self.lineBreakMode = NSLineBreakByCharWrapping;
    //防止nil崩溃
    if (string == nil) {
        return;
    }
    NSMutableAttributedString *text = [[NSMutableAttributedString alloc]initWithString:string];
    text.font = font;
    text.color =textColor;
    
    //调整行间距
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.alignment = textAligment;//设置对齐方式,自定义
    [paragraphStyle setLineSpacing:CustomLineSpacing];
    if (lineSpacing) {
        [paragraphStyle setLineSpacing:lineSpacing];
    }
    [text addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, [string length])];
    
    if(!customColor){
        customColor = CustomRanageColor;
    }
    if(!customFont){
        customFont = font;
    }
    //解析customRanges
    if (customRanges.count == 1) {
        NSRange range1 = NSRangeFromString(customRanges.firstObject);
        
        [text setFont:customFont range:range1];
        [text setTextHighlightRange:range1 color:customColor backgroundColor:[UIColor clearColor] userInfo:nil tapAction:^(UIView * _Nonnull containerView, NSAttributedString * _Nonnull text, NSRange range, CGRect rect) {
            !tapAction ? : tapAction(text, range, [text attributedSubstringFromRange:range]);
        } longPressAction:^(UIView * _Nonnull containerView, NSAttributedString * _Nonnull text, NSRange range, CGRect rect) {
            !longPressAction ? : longPressAction(text, range, [text attributedSubstringFromRange:range]);
        }];
    }else if (customRanges.count == 2) {
        NSRange range1 = NSRangeFromString(customRanges.firstObject);
        NSRange range2 = NSRangeFromString(customRanges[1]);
        
        [text setFont:customFont range:range1];
        [text setFont:customFont range:range2];
        [text setTextHighlightRange:range1 color:customColor backgroundColor:[UIColor clearColor] userInfo:nil tapAction:^(UIView * _Nonnull containerView, NSAttributedString * _Nonnull text, NSRange range, CGRect rect) {
            !tapAction ? : tapAction(text, range, [text attributedSubstringFromRange:range]);
        } longPressAction:^(UIView * _Nonnull containerView, NSAttributedString * _Nonnull text, NSRange range, CGRect rect) {
            !longPressAction ? : longPressAction(text, range, [text attributedSubstringFromRange:range]);
        }];
        [text setTextHighlightRange:range2 color:customColor backgroundColor:[UIColor clearColor] userInfo:nil tapAction:^(UIView * _Nonnull containerView, NSAttributedString * _Nonnull text, NSRange range, CGRect rect) {
            !tapAction ? : tapAction(text, range, [text attributedSubstringFromRange:range]);
        } longPressAction:^(UIView * _Nonnull containerView, NSAttributedString * _Nonnull text, NSRange range, CGRect rect) {
            !longPressAction ? : longPressAction(text, range, [text attributedSubstringFromRange:range]);
        }];
    }
    
    NSError *error;
    NSDataDetector *dataDetector=[NSDataDetector dataDetectorWithTypes:NSTextCheckingTypeLink error:&error];
    NSArray *arrayOfAllMatches=[dataDetector matchesInString:string options:NSMatchingReportProgress range:NSMakeRange(0, string.length)];
    //NSMatchingOptions匹配方式也有好多种，我选择NSMatchingReportProgress，一直匹配
    //我们得到一个数组，这个数组中NSTextCheckingResult元素中包含我们要找的URL的range，当然可能找到多个URL，找到相应的URL的位置，用YYlabel的高亮点击事件处理跳转网页
    for (NSTextCheckingResult *match in arrayOfAllMatches) { // NSLog(@"%@",NSStringFromRange(match.range));
        if (self.labelType != UNCLICK_LABEL) {
            [text setTextHighlightRange:match.range//设置点击的位置
                                  color:urlColor
                        backgroundColor:[UIColor whiteColor]
                              tapAction:^(UIView *containerView, NSAttributedString *text, NSRange range, CGRect rect){
                NSLog(@"这里是点击事件");
                !urlBlock ? : urlBlock([NSURL URLWithString:text.string]);
            }];
        }
        else
        {
            [text setColor:urlColor range:match.range];
        }
    }
    self.attributedText = text;
    
    [self attachTapHandler];
}

#pragma mark -高级使用2 （带html基本标签解析功能，场景 一般用在解析html标识的富文本中）
-(void)setHtmlText:(NSString *)string textColor:(UIColor *)textColor font:(UIFont *)font textAligment:(NSTextAlignment)textAligment urlColor:(UIColor *)urlColor urlTapBlock:(void(^)(NSURL *url))urlBlock
{
    self.lineBreakMode = NSLineBreakByCharWrapping;
    //防止nil崩溃
    if (string == nil) {
        return;
    }
    
    NSMutableAttributedString *text = [self setHtmlStr:string];
    text.font = font;
    NSRange range = NSMakeRange(0, text.length);
    text.color =textColor;
    //    // 设置颜色
    //    [text addAttribute:NSForegroundColorAttributeName value:FBEE_COLOR_INFO range:range];
    
    //枚举通过颜色查找进行修改
    [text enumerateAttributesInRange:range
                             options:NSAttributedStringEnumerationLongestEffectiveRangeNotRequired
                          usingBlock:^(NSDictionary *dictionary, NSRange range, BOOL *stop){
        //FbeeLog(@"dictionary:%@",dictionary);
        UIColor *foregroundColor = [dictionary objectForKey:NSForegroundColorAttributeName];
        const CGFloat *components = CGColorGetComponents(foregroundColor.CGColor);
        //FbeeLog(@"Red: %f", components[0]);
        //FbeeLog(@"Green: %f", components[1]);
        //FbeeLog(@"Blue: %f", components[2]);
        if (components[0] == 0
            &&components[1] == 0
            &&components[1] == 0) {
            [text addAttribute:NSForegroundColorAttributeName value:textColor range:range];
        }
    }];
    
    //注意！！！
    string = text.string;//string值 发生了改变
    //调整行间距
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.alignment = textAligment;//设置对齐方式,自定义
    [paragraphStyle setLineSpacing:CustomLineSpacing];
    [text addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, [string length])];
    
    //url 处理
    NSError *error;
    NSDataDetector *dataDetector=[NSDataDetector dataDetectorWithTypes:NSTextCheckingTypeLink error:&error];
    NSArray *arrayOfAllMatches=[dataDetector matchesInString:string options:NSMatchingReportProgress range:NSMakeRange(0, string.length)];
    for (NSTextCheckingResult *match in arrayOfAllMatches) {
        if (self.labelType != UNCLICK_LABEL) {
            [text setTextHighlightRange:match.range//设置点击的位置
                                  color:urlColor
                        backgroundColor:[UIColor whiteColor]
                              tapAction:^(UIView *containerView, NSAttributedString *text, NSRange range, CGRect rect){
                NSLog(@"这里是点击事件");
                !urlBlock ? : urlBlock([NSURL URLWithString:text.string]);
            }];
        }
        else
        {
            [text setColor:urlColor range:match.range];
        }
    }
    
    self.attributedText = text;
    
    [self attachTapHandler];
}

#pragma mark -利用系统的方法解析html标签
- (NSMutableAttributedString *)setHtmlStr:(NSString *)html
{
    NSAttributedString *attrStr = [[NSAttributedString alloc] initWithData:[html dataUsingEncoding:NSUnicodeStringEncoding] options:@{NSDocumentTypeDocumentAttribute:NSHTMLTextDocumentType} documentAttributes:nil error:nil];
    
    NSMutableAttributedString *attr = [[NSMutableAttributedString alloc] initWithAttributedString:attrStr];
    
    return attr;
}

#pragma mark -为label添加copy功能
////为了能接收到事件（能成为第一响应者），我们需要覆盖一个方法：
-(BOOL)canBecomeFirstResponder{
    return YES;
}

// 可以响应的方法
//此方法中只相应了复制和粘贴两个方法，也就是弹出的面板中只有复制和粘贴两个按钮。
//其它方法都返回No代表禁止，面板内不会出现相应的按钮。
-(BOOL)canPerformAction:(SEL)action withSender:(id)sender{
    switch (self.labelType) {
        case COPY_PASTE_LABEL:
            //允许复制操作、粘贴操作
            if (action == @selector(paste:)) {
                return (action == @selector(paste:));
            }else if (action == @selector(copy:)){
                return (action == @selector(copy:));
            }
            break;
        case COPY_LABEL:
            //只允许复制操作
            return (action == @selector(copy:));
            break;
        default:
            break;
    }
    //其它操作不允许
    return NO;
}

//针对于响应方法的实现,点击copy按钮时调用此方法
-(void)copy:(id)sender{
    UIPasteboard *pboard = [UIPasteboard generalPasteboard];
    pboard.string = self.text;
    NSLog(@"pboard.string:%@",pboard.string);
}
//针对于响应方法的实现,点击paste按钮时调用此方法
-(void)paste:(id)sender{
    UIPasteboard *pboard = [UIPasteboard generalPasteboard];
    self.text = pboard.string;
    NSLog(@"pboard.string:%@",pboard.string);
}

//有了以上三个方法，我们就能处理copy和paste了，当然，在能接收到事件的情况下：
//UILabel默认是不接收事件的，我们需要自己添加touch事件
-(void)attachTapHandler{
    self.userInteractionEnabled = YES;  //用户交互的总开关
    UILongPressGestureRecognizer * longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
    [self addGestureRecognizer:longPress];
}

//接下来，我们需要处理这个tap，以便让菜单栏弹出来：
-(void)handleTap:(UIGestureRecognizer*) recognizer{
    //if判断是为了保证长按手势只执行一次
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        [self becomeFirstResponder];
        [[UIMenuController sharedMenuController] setTargetRect:self.frame inView:self.superview];
        [[UIMenuController sharedMenuController] setMenuVisible:YES animated: YES];
    }
}
//这样一来，一个可复制的UILabel就诞生了！它能处理接收点击、弹出菜单栏、处理copy，这是一个很普通的可复制控件。

//发邮箱
- (void)sendEmail:(NSString *)emailAddr {
    
    //emailAddr = @"13387564856@163.com";
    NSString *mailStr = [NSString stringWithFormat:@"mailto:%@",emailAddr];
    //跳转到系统邮件App发送邮件
    NSString *emailPath = [mailStr stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLFragmentAllowedCharacterSet]];
    
    if (@available(iOS 10, *)) {
        [UIApplication.sharedApplication openURL:[NSURL URLWithString:emailPath] options:@{} completionHandler:nil];
    } else {
        [UIApplication.sharedApplication openURL:[NSURL URLWithString:emailPath]];
    }
    
    //    //创建可变的地址字符串对象
    //    NSMutableString *mailUrl = [[NSMutableString alloc] init];
    //    //添加收件人,如有多个收件人，可以使用componentsJoinedByString方法连接，连接符为","
    //    NSString *recipients = @"sparkle_ds@163.com";
    //    [mailUrl appendFormat:@"mailto:%@?", recipients];
    //    //添加抄送人
    //    NSString *ccRecipients = @"1622849369@qq.com";
    //    [mailUrl appendFormat:@"&cc=%@", ccRecipients];
    //    //添加密送人
    //    NSString *bccRecipients = @"15690725786@163.com";
    //    [mailUrl appendFormat:@"&bcc=%@", bccRecipients];
    //    //添加邮件主题
    //    [mailUrl appendFormat:@"&subject=%@",@"设置邮件主题"];
    //    //添加邮件内容
    //    [mailUrl appendString:@"&body=<b>Hello</b> World!"];
    //    //跳转到系统邮件App发送邮件
    //    NSString *emailPath = [mailUrl stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLFragmentAllowedCharacterSet]];
    //    [[UIApplication sharedApplication]openURL:[NSURL URLWithString:emailPath] options:@{} completionHandler:nil];
    
}

@end
