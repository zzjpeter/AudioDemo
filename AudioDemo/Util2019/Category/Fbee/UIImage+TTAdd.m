//
//  UIImage+TTAdd.m
//  FbeeAPP
//
//  Created by dev-m on 2018/3/21.
//  Copyright © 2018年 mohao. All rights reserved.
//

#import "UIImage+TTAdd.h"

@implementation UIImage(TTAdd)

+(UIImage *)getImageByView:(UIView *)view
{
    UIImage *image = nil;
    
    CGSize size = CGSizeMake(view.frame.size.width, view.frame.size.height);
    
    UIGraphicsBeginImageContextWithOptions(size, NO, 3.0);
    CGContextRef ctx =UIGraphicsGetCurrentContext();
    [view.layer renderInContext:ctx];
    
    image = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return image;
}

//生成二维码 by 简书 http://www.jianshu.com/p/39dd77f359bd

+(UIImage *)encodeQRImageWithContent:(NSString *)content size:(CGSize)size {
    
    UIImage *codeImage = nil;
    
    NSData *stringData = [content dataUsingEncoding: NSUTF8StringEncoding];
    
    //生成
    CIFilter *qrFilter = [CIFilter filterWithName:@"CIQRCodeGenerator"];
    [qrFilter setValue:stringData forKey:@"inputMessage"];
    [qrFilter setValue:@"M" forKey:@"inputCorrectionLevel"];
    
    UIColor *onColor = [UIColor blackColor];
    UIColor *offColor = [UIColor whiteColor];
    
    //上色
    CIFilter *colorFilter = [CIFilter filterWithName:@"CIFalseColor"
                                       keysAndValues:
                             @"inputImage",qrFilter.outputImage,
                             @"inputColor0",[CIColor colorWithCGColor:onColor.CGColor],
                             @"inputColor1",[CIColor colorWithCGColor:offColor.CGColor],
                             nil];
    
    CIImage *qrImage = colorFilter.outputImage;
    CGImageRef cgImage = [[CIContext contextWithOptions:nil] createCGImage:qrImage fromRect:qrImage.extent];
    UIGraphicsBeginImageContext(size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetInterpolationQuality(context, kCGInterpolationNone);
    CGContextScaleCTM(context, 1.0, -1.0);
    CGContextDrawImage(context, CGContextGetClipBoundingBox(context), cgImage);
    codeImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    CGImageRelease(cgImage);
    
    return codeImage;
}

@end
