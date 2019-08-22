//
//  JumpManager.h
//  TooToo
//
//  Created by zhuzj on 15/12/25.
//  Copyright © 2015年 zhuzj. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface VMControllerHelper : NSObject
//获取当前Controller
+ (UIViewController *)currentViewController;
+ (UINavigationController *)currentNavigationController;

@end

@interface JumpManager : NSObject

+(instancetype)sharedManager;
@end
