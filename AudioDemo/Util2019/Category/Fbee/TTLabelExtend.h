//
//  TTLabelExtend.h
//  FbeeAPP
//
//  Created by dev-m on 2018/2/28.
//  Copyright © 2018年 mohao. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

@interface TTLabelExtend :UILabel

-(TTLabelExtend *(^)(UIColor *))addTextColor;
-(TTLabelExtend *(^)(UIColor *))addBackGoundColor;
-(TTLabelExtend *(^)(UIFont *))addFont;
-(TTLabelExtend *(^)(NSString *))addText;
-(TTLabelExtend *(^)(NSTextAlignment))addTextAlignment;
-(TTLabelExtend *(^)(CGRect))setFrame;

@end
