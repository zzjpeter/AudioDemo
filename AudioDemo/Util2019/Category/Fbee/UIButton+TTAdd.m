//
//  UIButton+TTAdd.m
//  NSStringTest
//
//  Created by dev on 2017/11/21.
//  Copyright © 2017年 dev. All rights reserved.
//

#import "UIButton+TTAdd.h"

@implementation UIButton(TTAdd)

+(UIButton *)makeButton:(void (^)(TTButtonExtend *))ttExtend
{
    TTButtonExtend *btn = [TTButtonExtend buttonWithType:UIButtonTypeCustom];
    
    ttExtend(btn);
    
    return btn;
}

-(void)setCircularWithArc:(CGFloat )arc borderColor:(UIColor *)borderColor;
{
    [self.layer setBorderColor:(__bridge CGColorRef _Nullable)(borderColor)];
    [self.layer setCornerRadius:arc];
    [self.layer setBorderWidth:0.5f];
}
@end
