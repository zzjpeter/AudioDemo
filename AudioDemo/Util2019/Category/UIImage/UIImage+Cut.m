//
//  UIImage+Cut.m
//  FeiHangChuangKe
//
//  Created by 王飞 on 16/8/25.
//  Copyright © 2016年 FeiHangKeJi.com. All rights reserved.
//

#import "UIImage+Cut.h"

@implementation UIImage (Cut)


//图片切割 指定指定尺寸与位置切割
-(UIImage*)cutImage:(UIImage*)image frame:(CGRect)fra
{
    UIImageView* tempImageView = [[UIImageView alloc]initWithImage:image];
    
    UIGraphicsBeginImageContext(tempImageView.frame.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    [tempImageView.layer renderInContext:context];
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    CGImageRef ref = CGImageCreateWithImageInRect(img.CGImage, fra);
    UIImage *i = [UIImage imageWithCGImage:ref];
    CGImageRelease(ref);
    return i;
    
}

// 图片 剧中切割，选定宽高比，高度比例（当高度大于宽度时，高比，小于时，宽比）
-(UIImage*)cutImage:(UIImage*)image withAutoAspectRatio:(CGFloat)kuanGaoBi withAspectHight:(CGFloat)gaoDuBi
{
    
      UIImageView* tempImageView = [[UIImageView alloc]initWithImage:image];
    UIGraphicsBeginImageContext(tempImageView.frame.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    [tempImageView.layer renderInContext:context];
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    CGRect frame = tempImageView.frame;
    
    CGRect lastFrame;
    
    if (image.size.width>image.size.height) {
        
         lastFrame = CGRectMake((frame.size.width-kuanGaoBi*gaoDuBi*frame.size.height)/2, (frame.size.width - gaoDuBi*frame.size.height)/2, kuanGaoBi*gaoDuBi*frame.size.height, gaoDuBi*frame.size.height);
        
        
    }
    else
    {
       lastFrame = CGRectMake((frame.size.width-gaoDuBi*frame.size.height)/2, (frame.size.width - gaoDuBi*frame.size.height*kuanGaoBi)/2, gaoDuBi*frame.size.height, gaoDuBi*frame.size.height*kuanGaoBi);
      

    }
    
    CGImageRef ref = CGImageCreateWithImageInRect(img.CGImage, lastFrame);
    UIImage *i = [UIImage imageWithCGImage:ref];
    CGImageRelease(ref);
    return i;

}

// 图片 剧中切割，选定宽高比，高度比例（当高度大于宽度时，高比，小于时，宽比）
-(UIImage*)cutImage:(UIImage*)image withAspectRatio:(CGFloat)kuanGaoBi withAspectHight:(CGFloat)gaoDuBi
{
    UIImageView* tempImageView = [[UIImageView alloc]initWithImage:image];
    UIGraphicsBeginImageContext(tempImageView.frame.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    [tempImageView.layer renderInContext:context];
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    CGRect frame = tempImageView.frame;
    
    CGRect lastFrame;
    
 
        lastFrame = CGRectMake((frame.size.width-kuanGaoBi*gaoDuBi*frame.size.height)/2, (frame.size.width - gaoDuBi*frame.size.height)/2, kuanGaoBi*gaoDuBi*frame.size.height, gaoDuBi*frame.size.height);
  
    
    CGImageRef ref = CGImageCreateWithImageInRect(img.CGImage, lastFrame);
    UIImage *i = [UIImage imageWithCGImage:ref];
    CGImageRelease(ref);
    return i;

}







@end
