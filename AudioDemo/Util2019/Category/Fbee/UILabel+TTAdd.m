//
//  UILabel+TTAdd.m
//  FbeeAPP
//
//  Created by dev-m on 2018/2/28.
//  Copyright © 2018年 mohao. All rights reserved.
//

#import "UILabel+TTAdd.h"
#import "YYKit.h"
@implementation UILabel(TTAdd)

+(UILabel *)makeLabel:(void (^)(TTLabelExtend *))ttExtend
{
    TTLabelExtend *lb = [[TTLabelExtend alloc] init];
    
    ttExtend(lb);
    
    return lb;
}

//设置行间距
- (NSAttributedString *)setText:(NSString*)text lineSpacing:(CGFloat)lineSpacing {
    if (lineSpacing < 0.01 || !text) {
        self.text = text;
        return nil;
    }
    
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:text];
    [attributedString addAttribute:NSFontAttributeName value:self.font range:NSMakeRange(0, [text length])];
    
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    [paragraphStyle setLineSpacing:lineSpacing];
    [paragraphStyle setLineBreakMode:self.lineBreakMode];
    [paragraphStyle setAlignment:self.textAlignment];
    [attributedString addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, [text length])];
    
    self.attributedText = attributedString;
    
    return attributedString;
}

//自适应文字高度
-(void)setAdaptiveHeight
{
    //自适应文字高度
    NSMutableAttributedString * att=[[NSMutableAttributedString alloc]initWithString:self.text attributes:@{NSFontAttributeName:self.font}];
    CGRect rect=[att boundingRectWithSize:CGSizeMake(self.frame.size.width, CGFLOAT_MAX) options:(NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading) context:nil];
    [self setFrame:CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.size.width, rect.size.height)];
    
}


//自适应文字高度
-(void)setAdaptiveHeightByParagraph:(float)height
{
    
    NSMutableDictionary *attr = [NSMutableDictionary new];
    attr[NSFontAttributeName] = self.font;
    NSMutableParagraphStyle *paragraphStyle = [NSMutableParagraphStyle new];
    //    paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;;
    [paragraphStyle setLineSpacing:height];
    [paragraphStyle setAlignment:self.textAlignment];
    attr[NSParagraphStyleAttributeName] = paragraphStyle;
    CGRect rect = [self.text boundingRectWithSize:CGSizeMake(self.width, CGFLOAT_MAX)
                                          options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading
                                       attributes:attr context:nil];
    
    self.height = rect.size.height;
    
}

@end
