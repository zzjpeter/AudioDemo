//
//  UIImage+Cut.h
//  FeiHangChuangKe
//
//  Created by 王飞 on 16/8/25.
//  Copyright © 2016年 FeiHangKeJi.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (Cut)

//图片切割 指定指定尺寸与位置切割
-(UIImage*)cutImage:(UIImage*)image frame:(CGRect)fra;

// 图片 剧中切割，选定宽高比，高度比例
-(UIImage*)cutImage:(UIImage*)image withAspectRatio:(CGFloat)kuanGaoBi withAspectHight:(CGFloat)gaoDuBi;

// 图片 剧中切割，选定宽高比，高度比例（当高度大于宽度时，高比，小于时，宽比）
-(UIImage*)cutImage:(UIImage*)image withAutoAspectRatio:(CGFloat)kuanGaoBi withAspectHight:(CGFloat)gaoDuBi;




@end
