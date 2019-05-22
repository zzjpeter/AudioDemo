//
//  TTButtonExtend.m
//  NSStringTest
//
//  Created by dev on 2017/11/21.
//  Copyright © 2017年 dev. All rights reserved.
//

#import "TTButtonExtend.h"

@implementation TTButtonExtend

-(TTButtonExtend *(^)(UIColor *,UIControlState))addTitleColor
{
    return ^TTButtonExtend *(UIColor *color,UIControlState state)
    {
        [self setTitleColor:color forState:state];
        
        return self;
    };
}

-(TTButtonExtend *(^)(UIColor *))addBackGoundColor
{
    return ^TTButtonExtend *(UIColor *color)
    {
        [self setBackgroundColor:color];
        
        return self;
    };
}

-(TTButtonExtend *(^)(UIImage *, UIControlState))addImage
{
    return ^TTButtonExtend *(UIImage *image,UIControlState state)
    {
        [self setImage:image forState:state];
        
        return self;
    };
}

-(TTButtonExtend *(^)(UIImage *,UIControlState))addBackGoundImage
{
    return ^TTButtonExtend *(UIImage *image,UIControlState state)
    {
        [self setBackgroundImage:image forState:state];
        
        return self;
    };
}

-(TTButtonExtend *(^)(UIFont *))addFont
{
    return ^TTButtonExtend *(UIFont *font)
    {
        self.titleLabel.font = font;
        
        return self;
    };
}

-(TTButtonExtend *(^)(NSString *))addTitle
{
    return ^TTButtonExtend *( NSString * title)
    {
        [self setTitle:title forState:UIControlStateNormal];
        
        return self;
    };
}

-(TTButtonExtend *(^)(CGRect))setFrame
{
    return ^TTButtonExtend *(CGRect rect)
    {
        self.frame = rect;
        
        return self;
    };
}

-(TTButtonExtend *(^)(id,SEL))addTarget
{
    return ^TTButtonExtend *(id target, SEL action)
    {
        [self addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
        
        return self;
    };
}

@end
