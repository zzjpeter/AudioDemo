//
//  AppDelegate+SafeArea.h
//  WXReader
//
//  Created by 朱志佳 on 2020/5/20.
//  Copyright © 2020 Andrew. All rights reserved.
//

#import "AppDelegate.h"

NS_ASSUME_NONNULL_BEGIN

extern CGFloat LPiPhoneXMarginTop;
extern CGFloat LPiPhoneXMarginBottom;
extern BOOL iPhoneX;

@interface AppDelegate (SafeArea)

//必须先调用一次才能正常使用
- (void)commonInit;

@end

NS_ASSUME_NONNULL_END
