//
//  UIImage+LPExtension.m
//  LesPark
//
//  Created by zhudf on 15/12/5.
//
//

#import "UIImage+LPExtension.h"
#import <AVFoundation/AVFoundation.h>

@implementation UIImage (LPExtension)

+ (NSString *)zdf_randomImageName
{
    static NSString *Alphabets = @"qwertyuiopasdfghjklzxcvbnmQWERTYUIOPASDFGHJKLZXCVBNM";
    NSMutableString *imageName = [[NSMutableString alloc] initWithString:@"86"];
    for (int i = 0; i < 18; i++) {
        u_int32_t index = arc4random_uniform(52); // 0 - 51
        [imageName appendString:[Alphabets substringWithRange:(NSRange){index, 1}]];
    }
    return [NSString stringWithFormat:@"aliclient%@",imageName];
}

+ (NSString *)zdf_randomImageNameWithNoPrefix
{
    static NSString *Alphabets = @"qwertyuiopasdfghjklzxcvbnmQWERTYUIOPASDFGHJKLZXCVBNM";
    NSMutableString *imageName = [NSMutableString new];
    for (int i = 0; i < 18; i++) {
        u_int32_t index = arc4random_uniform(52); // 0 - 51
        [imageName appendString:[Alphabets substringWithRange:(NSRange){index, 1}]];
    }
    return imageName;
}

//+ (NSString *)zdf_imageURIWithName:(NSString *)imageName
//{
//    return [NSString stringWithFormat:@"http://img1.lespark.cn/%@", imageName];
//}

+ (UIImage *)videoShotImageForVideo:(NSURL *)videoURL
{
    AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:videoURL
                                                options:@{
                                                          AVURLAssetPreferPreciseDurationAndTimingKey:[NSNumber numberWithBool:YES]}];
    NSParameterAssert(asset);
    AVAssetImageGenerator *assetImageGenerator = [[AVAssetImageGenerator alloc] initWithAsset:asset];
    assetImageGenerator.appliesPreferredTrackTransform = YES;
    assetImageGenerator.apertureMode = AVAssetImageGeneratorApertureModeEncodedPixels;
    
    CGImageRef thumbnailImageRef = NULL;
    NSError *thumbnailImageGenerationError = nil;
//    NSTimeInterval duration = CMTimeGetSeconds(asset.duration);
//    CMTime time = CMTimeMakeWithSeconds(0, asset.duration.timescale);
    thumbnailImageRef = [assetImageGenerator copyCGImageAtTime:kCMTimeZero actualTime:NULL error:&thumbnailImageGenerationError];
    
    if (!thumbnailImageRef) {
        NSLog(@"thumbnailImageGenerationError %@", thumbnailImageGenerationError);
    }
    
    UIImage *thumbnailImage = thumbnailImageRef ? [[UIImage alloc] initWithCGImage:thumbnailImageRef] : nil;
    
    CGImageRelease(thumbnailImageRef);
    
    return thumbnailImage;
}

/////////////////////////////////////////////////////////////////
- (UIImage *)addText:(NSString *)text inRect:(CGRect)rect withAttributes:(NSDictionary *)attr
{
    //获取上下文
    UIGraphicsBeginImageContext(self.size);
    //绘制图片
    [self drawInRect:CGRectMake(0, 0, self.size.width, self.size.height)];
    //绘制水印文字
    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle defaultParagraphStyle] mutableCopy];
    style.alignment = NSTextAlignmentCenter;
    //文字的属性
    if (!attr) {
        attr = @{
                 NSFontAttributeName:[UIFont systemFontOfSize:13],
                 NSParagraphStyleAttributeName:style,
                 NSForegroundColorAttributeName:[UIColor whiteColor]
                 };
    }
    
    //将文字绘制上去
    [text drawInRect:rect withAttributes:attr];
    //获取绘制到得图片
    UIImage *watermarkImage = UIGraphicsGetImageFromCurrentImageContext();
    //结束图片的绘制
    UIGraphicsEndImageContext();
    
    return watermarkImage ? watermarkImage : self;
}

- (UIImage *)addImage:(UIImage *)image inRect:(CGRect)rect
{
    UIGraphicsBeginImageContext(self.size);
    [self drawInRect:CGRectMake(0, 0, self.size.width, self.size.height)];
    [image drawInRect:rect];
    UIImage *resultingImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return resultingImage ? resultingImage : self;
}

+ (UIImage *)convertViewToImage:(UIView *)view
{
    /// 下面方法，第一个参数表示区域大小。第二个参数表示是否是非透明的。如果需要显示半透明效果，需要传NO，否则传YES。第三个参数就是屏幕密度了
    UIGraphicsBeginImageContextWithOptions(view.bounds.size, NO, [UIScreen mainScreen].scale);
    [view.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

- (UIImage *)addLesParkWaterMarkWithLgID:(NSString *)lgID
{
    CGFloat marginRight = 11;
    CGFloat space = 6;
    CGFloat labelWidth = 0;
    
    BOOL hasLgID = !IsEmptyOrNull(lgID);
    CGRect lgIDRect = CGRectZero;
    NSDictionary *lgIDAttr = nil;
    
    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle defaultParagraphStyle] mutableCopy];
    style.alignment = NSTextAlignmentCenter;
    
    CGFloat bottom = self.size.height - 11;
    if (hasLgID) {
        lgID = [@"ID:" stringByAppendingString:lgID];
        UIFont *lgidFont = [UIFont systemFontOfSize:12*self.size.width/375];
        CGSize lgidSize = [lgID sizeWithAttributes:@{NSFontAttributeName:lgidFont}];
        lgidSize.width = ceil(lgidSize.width);
        lgidSize.height = ceil(lgidSize.height);
        labelWidth = lgidSize.width;
        
        bottom = self.size.height - labelWidth/4;
        marginRight = labelWidth/4;
        
        bottom -= lgidSize.height + space;
        lgIDRect = CGRectMake(self.size.width-lgidSize.width-marginRight, bottom+space, lgidSize.width, lgidSize.height);
        
        NSShadow *shadow = [[NSShadow alloc] init];
        shadow.shadowColor = UIColorFromRGBA(0x333333, .5);
        shadow.shadowBlurRadius = .5;
        shadow.shadowOffset = CGSizeMake(.5, .5);
        lgIDAttr = @{
                     NSFontAttributeName:lgidFont,
                     NSParagraphStyleAttributeName:style,
                     NSForegroundColorAttributeName:[UIColor whiteColor],
                     NSShadowAttributeName:shadow,
                     };
    }
    else {
        bottom = self.size.height - self.size.width/5.0/4;
        marginRight = self.size.width/5.0/4;
    }
    
    UIImage *watermark = [UIImage imageNamed:@"LesPark_watermark"];
    
    UIGraphicsBeginImageContext(self.size);
    
    [self drawInRect:CGRectMake(0, 0, self.size.width, self.size.height)];
    
    if (hasLgID) {
        [lgID drawInRect:lgIDRect withAttributes:lgIDAttr];
    }
    CGFloat imageWidth = labelWidth > 0?labelWidth:self.size.width/5.0;
    CGFloat imageHeight = watermark.size.height*imageWidth/watermark.size.width;
    
    [watermark drawInRect:CGRectMake(self.size.width-marginRight-imageWidth,
                                     bottom-imageHeight,
                                     imageWidth, imageHeight)];
//    CGRectMake(self.size.width-marginRight-watermark.size.width,
//               bottom-watermark.size.height,
//               watermark.size.width, watermark.size.height)
    
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return newImage ? newImage : self;
}

+ (UIImage *)lp_placeholderImage:(LPPlaceholderType)type
{
    switch (type) {
        case LPPlaceholderTypeAvatar:
            return [UIImage imageNamed:@"avatar_holder"];
        case LPPlaceholderTypeRoundedAvatar:
            return [UIImage imageNamed:@"avatar_holder_rounded"];
        case LPPlaceholderTypePicture:
            return [UIImage imageNamed:@"live_cover_holder"];
        default:
            break;
    }
    return [UIImage imageNamed:@"live_cover_holder"];
}

+ (UIImage *)lp_fixOrientation:(UIImage *)aImage {
    
    // No-op if the orientation is already correct
    if (aImage.imageOrientation == UIImageOrientationUp)
        return aImage;
    
    // We need to calculate the proper transformation to make the image upright.
    // We do it in 2 steps: Rotate if Left/Right/Down, and then flip if Mirrored.
    CGAffineTransform transform = CGAffineTransformIdentity;
    
    switch (aImage.imageOrientation) {
        case UIImageOrientationDown:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, aImage.size.width, aImage.size.height);
            transform = CGAffineTransformRotate(transform, M_PI);
            break;
            
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
            transform = CGAffineTransformTranslate(transform, aImage.size.width, 0);
            transform = CGAffineTransformRotate(transform, M_PI_2);
            break;
            
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, 0, aImage.size.height);
            transform = CGAffineTransformRotate(transform, -M_PI_2);
            break;
        default:
            break;
    }
    
    switch (aImage.imageOrientation) {
        case UIImageOrientationUpMirrored:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, aImage.size.width, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
            
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, aImage.size.height, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
        default:
            break;
    }
    
    // Now we draw the underlying CGImage into a new context, applying the transform
    // calculated above.
    CGContextRef ctx = CGBitmapContextCreate(NULL, aImage.size.width, aImage.size.height,
                                             CGImageGetBitsPerComponent(aImage.CGImage), 0,
                                             CGImageGetColorSpace(aImage.CGImage),
                                             CGImageGetBitmapInfo(aImage.CGImage));
    CGContextConcatCTM(ctx, transform);
    switch (aImage.imageOrientation) {
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            // Grr...
            CGContextDrawImage(ctx, CGRectMake(0,0,aImage.size.height,aImage.size.width), aImage.CGImage);
            break;
            
        default:
            CGContextDrawImage(ctx, CGRectMake(0,0,aImage.size.width,aImage.size.height), aImage.CGImage);
            break;
    }
    
    // And now we just create a new UIImage from the drawing context
    CGImageRef cgimg = CGBitmapContextCreateImage(ctx);
    UIImage *img = [UIImage imageWithCGImage:cgimg];
    CGContextRelease(ctx);
    CGImageRelease(cgimg);
    return img;
}

@end
