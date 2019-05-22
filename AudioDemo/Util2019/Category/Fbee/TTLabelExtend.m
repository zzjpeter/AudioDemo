//
//  TTLabelExtend.m
//  FbeeAPP
//
//  Created by dev-m on 2018/2/28.
//  Copyright © 2018年 mohao. All rights reserved.
//

#import "TTLabelExtend.h"

@implementation TTLabelExtend

-(TTLabelExtend *(^)(UIColor *))addTextColor
{
    return ^TTLabelExtend *(UIColor *color)
    {
        [self setTextColor:color];
        
        return self;
    };
}

-(TTLabelExtend *(^)(UIColor *))addBackGoundColor
{
    return ^TTLabelExtend *(UIColor *color)
    {
        [self setBackgroundColor:color];
        
        return self;
    };
}

-(TTLabelExtend *(^)(UIFont *))addFont
{
    return ^TTLabelExtend *(UIFont *font)
    {
        [self setFont:font];
        
        return self;
    };
}

-(TTLabelExtend *(^)(NSString *))addText
{
    return ^TTLabelExtend *(NSString *text)
    {
        [self setText:text];
        
        return self;
    };
}

-(TTLabelExtend *(^)( NSTextAlignment))addTextAlignment;
{
    return ^TTLabelExtend *(NSTextAlignment textAlignmen)
    {
        [self setTextAlignment:textAlignmen];
        
        return self;
    };
}

-(TTLabelExtend *(^)(CGRect))setFrame
{
    return ^TTLabelExtend *(CGRect rect)
    {
        self.frame = rect;
        
        return self;
    };
}

@end
