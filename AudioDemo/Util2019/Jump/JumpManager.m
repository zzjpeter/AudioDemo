//
//  JumpManager.m
//  TooToo
//
//  Created by zhuzj on 15/12/25.
//  Copyright © 2015年 zhuzj. All rights reserved.
//

#import "JumpManager.h"

@implementation VMControllerHelper

#pragma mark -获取当前VC
/////////////////////////////////////////////////
//获取当前Controller
+ (UIViewController *)currentViewController {
    UIViewController *resultVC;
    resultVC = [self _topViewController:[[UIApplication sharedApplication].keyWindow rootViewController]];
    while (resultVC.presentedViewController) {
        resultVC = [self _topViewController:resultVC.presentedViewController];
    }
    return resultVC;
}

+ (UINavigationController *)currentNavigationController
{
    UIViewController * vc = [self currentViewController];
    if (vc.navigationController) {
        
        return vc.navigationController;
    }
    
    return nil;
}

+ (UIViewController *)_topViewController:(UIViewController *)vc {
    if ([vc isKindOfClass:[UINavigationController class]]) {
        return [self _topViewController:[(UINavigationController *)vc topViewController]];
    } else if ([vc isKindOfClass:[UITabBarController class]]) {
        return [self _topViewController:[(UITabBarController *)vc selectedViewController]];
    } else {
        return vc;
    }
    return nil;
}
/////////////////////////////////////////////////

@end

@interface JumpManager ()

@end

@interface JumpManager ()
@end

@implementation JumpManager

+(instancetype)sharedManager
{
    static dispatch_once_t queue;
    static JumpManager * manager = nil;
    dispatch_once(&queue, ^{
        manager = [[JumpManager alloc]init];
    });
    
    return manager;
}

-(instancetype)init
{
    if (self = [super init]) {
        
    }
    return self;
}

#pragma mark -跳转协议

//0代表私有协议；1代表跳转内部浏览器；2代表跳转外部浏览器
- (void)jumpToWithUrl:(id)url jumpType:(NSInteger)jumpType{
    
    switch (jumpType) {
        case 0:
        {
            [self jumpToAppWithUrl:url];
        }
            break;
        case 1:
        {
            [self jumpToWebViewWithUrl:url];
        }
            break;
        case 2:
        {
            [self jumpToSafariWithUrl:url];
        }
            break;
        default:
            NSLog(@"该跳转类型不存在");
            break;
    }
}

//0代表私有协议；app内
-(void)jumpToAppWithUrl:(id)url
{

}
//1代表跳转内部浏览器 webView
- (void)jumpToWebViewWithUrl:(id)url{

}
//H5分享 类型专用 处理
- (void)jumpToWebViewWithUrl:(id)url shareInfo:(id)obj canShare:(BOOL)canShare{

}

//2代表跳转外部浏览器 safari
- (void)jumpToSafariWithUrl:(id)url{
    //[[UIApplication sharedApplication] openURL:url];
}

#pragma mark -通用push 和 present
-(void)doPushViewController:(UIViewController *)viewController
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [[VMControllerHelper currentNavigationController] pushViewController:viewController animated:YES];
    });
}

-(void)doPresentViewController:(UIViewController *)viewController
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [[VMControllerHelper currentViewController] presentViewController:viewController animated:YES completion:^{
            
        }];
    });
}

@end
