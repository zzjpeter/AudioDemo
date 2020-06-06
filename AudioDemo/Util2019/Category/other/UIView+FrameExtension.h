//
//  UIView+FrameExtension.h
//  SimpleItemView
//
//  Created by zhuzhijia on 2017/10/20.
//  Copyright © 2017年 zhuzhijia. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (FrameExtension)


// Move via offset  移动view 通过设置偏移量offset
- (void) moveBy: (CGPoint) delta;
// Scaling   放缩view 通过设置scale比例
- (void) scaleBy: (CGFloat) scaleFactor;
// Ensure that both dimensions fit within the given size by scaling down
//使view 放缩适应指定的frame
- (void) fitInSize: (CGSize) aSize;

/*
 总结一下，anchorPoint 是相对于自身的位置，而 position 是相对于父图层的，改变 anchorPoint 只是更改了图层自身旋转地位置，但始终还是要通过改变 frame 使 anchorPoint 和 position 重合，这样它老子才不会骂它😄， 不知道这样的方式大家能不能看懂啊：）
 */
/** 设置锚点 */
- (CGPoint)py_setAnchorPoint:(CGPoint)anchorPoint forView:(UIView *)view;

/** 根据手势触摸点修改相应的锚点，就是沿着触摸点对self做相应的手势操作 */
- (CGPoint)py_setAnchorPointBaseOnGestureRecognizer:(UIGestureRecognizer *)gr;


/******其它功能****/
//获取nsuserDefault中的内容
-(NSString*)getStringFromUserDefaultForKey:(NSString*)key;

-(NSArray*)getArrayFromUserDefaultForKey:(NSString*)key;

-(NSDictionary*)getDicFromUserDefaultForKey:(NSString*)key;

@end
