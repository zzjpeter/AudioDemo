//
//  TTButtonExtend.h
//  NSStringTest
//
//  Created by dev on 2017/11/21.
//  Copyright © 2017年 dev. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface TTButtonExtend : UIButton

-(TTButtonExtend *(^)(UIColor *,UIControlState))addTitleColor;
-(TTButtonExtend *(^)(UIColor *))addBackGoundColor;
-(TTButtonExtend *(^)(UIImage *,UIControlState))addImage;
-(TTButtonExtend *(^)(UIImage *,UIControlState))addBackGoundImage;
-(TTButtonExtend *(^)(UIFont *))addFont;
-(TTButtonExtend *(^)(NSString *))addTitle;
-(TTButtonExtend *(^)(CGRect))setFrame;
-(TTButtonExtend *(^)(id,SEL))addTarget;


@end
