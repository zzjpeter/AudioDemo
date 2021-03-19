//
//  UIImage+LPExtension.h
//  LesPark
//
//  Created by zhudf on 15/12/5.
//
//

#import <UIKit/UIKit.h>
#import "UIImage+BoxBlur.h"
#import "UIImage+ColorImage.h"

typedef NS_ENUM(NSInteger, LPPlaceholderType) {
    LPPlaceholderTypeAvatar,
    LPPlaceholderTypeRoundedAvatar,
    LPPlaceholderTypePicture,
};


@interface UIImage (LPExtension)

+ (NSString *)zdf_randomImageName;
+ (NSString *)zdf_randomImageNameWithNoPrefix;
//+ (NSString *)zdf_imageURIWithName:(NSString *)imageName;

//生成视频截图
+ (UIImage *)videoShotImageForVideo:(NSURL *)videoURL;


//- (UIImage *)addText:(NSString *)text inRect:(CGRect)rect withStyle:(NSDictionary *)style;
- (UIImage *)addImage:(UIImage *)image inRect:(CGRect)rect;

/// 将view转换成image
+ (UIImage *)convertViewToImage:(UIView *)view;


/// 添加LesPark水印
- (UIImage *)addLesParkWaterMarkWithLgID:(NSString *)lgID;

+ (UIImage *)lp_placeholderImage:(LPPlaceholderType)type;

//修正图片的方向
+ (UIImage *)lp_fixOrientation:(UIImage *)aImage;
@end
