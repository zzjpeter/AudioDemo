//
//  UIButton+TTAdd.h
//  NSStringTest
//
//  Created by dev on 2017/11/21.
//  Copyright © 2017年 dev. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TTButtonExtend.h"

@interface UIButton(TTAdd)

+(UIButton *)makeButton:(void (^)(TTButtonExtend *make))ttExtend;

-(void)setCircularWithArc:(CGFloat )arc borderColor:(UIColor *)borderColor;

@end
