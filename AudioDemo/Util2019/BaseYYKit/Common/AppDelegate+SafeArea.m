//
//  AppDelegate+SafeArea.m
//  WXReader
//
//  Created by 朱志佳 on 2020/5/20.
//  Copyright © 2020 Andrew. All rights reserved.
//

#import "AppDelegate+SafeArea.h"
CGFloat LPiPhoneXMarginTop = .0;
CGFloat LPiPhoneXSafeAreaInsetsTop = .0;
CGFloat LPiPhoneXMarginBottom = .0;
BOOL iPhoneX = NO;

@implementation AppDelegate (SafeArea)

- (void)commonInit {
    
    [self safeArea];
}

- (void)safeArea{
    if (@available(iOS 11.0, *)) {
        LPiPhoneXSafeAreaInsetsTop = self.window.safeAreaInsets.top;
        LPiPhoneXMarginTop = self.window.safeAreaInsets.top ? self.window.safeAreaInsets.top - 20 : 0;
        LPiPhoneXMarginBottom = self.window.safeAreaInsets.bottom;
        if (LPiPhoneXMarginTop || LPiPhoneXMarginBottom) {
            iPhoneX = YES;
        }
    }else {
        LPiPhoneXSafeAreaInsetsTop = (is_iPhoneX ? 44.0 : 20.0);
    }
}

@end
