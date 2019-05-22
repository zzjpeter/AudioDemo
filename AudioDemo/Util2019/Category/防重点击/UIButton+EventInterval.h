//
//  UIButton+touch.h
//  LiqForDoctors
//
//  Created by StriEver on 16/3/10.
//  Copyright © 2016年 iMac. All rights reserved.
//

#import <UIKit/UIKit.h>
#define defaultInterval .1  //默认时间间隔 可以设置为0.5 有间隔效果哦

@interface UIButton (EventInterval)
/**设置点击时间间隔*/
@property (nonatomic, assign) NSTimeInterval timeInterval;
@end
