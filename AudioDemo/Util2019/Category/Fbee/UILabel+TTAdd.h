//
//  UILabel+TTAdd.h
//  FbeeAPP
//
//  Created by dev-m on 2018/2/28.
//  Copyright © 2018年 mohao. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TTLabelExtend.h"

@interface UILabel(TTAdd)

+(UILabel *)makeLabel:(void (^)(TTLabelExtend *make))ttExtend;

- (NSAttributedString *)setText:(NSString*)text lineSpacing:(CGFloat)lineSpacing;

- (void)setAdaptiveHeight;

- (void)setAdaptiveHeightByParagraph:(float)height;

@end
