//
//  UIButton+touch.h
//  LiqForDoctors
//
//  Created by StriEver on 16/3/10.
//  Copyright © 2016年 iMac. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIButton (EventInterval)

/**设置点击时间间隔 可以自定义时间间隔一般用0.1 或者 0.5 */
@property (nonatomic, assign) NSTimeInterval timeInterval;

@end
