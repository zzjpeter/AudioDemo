//
//  UIImage+TTAdd.h
//  FbeeAPP
//
//  Created by dev-m on 2018/3/21.
//  Copyright © 2018年 mohao. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

@interface UIImage(TTAdd)

+(UIImage *)getImageByView:(UIView *)view;
+(UIImage *)encodeQRImageWithContent:(NSString *)content size:(CGSize)size;
@end
