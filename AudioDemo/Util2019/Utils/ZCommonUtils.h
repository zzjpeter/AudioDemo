//
//  ZCommonUtils.h
//  DLNavigationTabBar
//
//  Created by xunshian on 17/1/23.
//  Copyright © 2017年 FT_David. All rights reserved.
//


#pragma mark -**************************
#pragma mark -该工具类 还不太完善 如设置 时应先判断是否为nil 为nil的话就取默认值 但是也不一定，因为可能有特殊需要 就是要为nil
#pragma mark -**************************
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

//网络状态回调
typedef void(^returnState)(NSInteger);

@interface ZCommonUtils : NSObject

#pragma mark -********************
#pragma mark -CommonUtils
#pragma mark -********************
/**
 *  判断对象是否为空
 *  PS：nil、NSNil、@""、@0 以上4种返回YES
 *
 *  @return YES 为空  NO 为实例对象
 */
+ (BOOL)isNullOrNilWithObject:(id)object;
#pragma mark -计算字符串的高度
+(CGSize)contentSize:(UILabel *)label text:(NSString *)text font:(UIFont *)font maxSize:(CGSize)maxSize lineSpacing:(CGFloat)lineSpacing;
#pragma mark -********************
#pragma mark -UIZZJ.h
#pragma mark -********************
//用类方法封装
#pragma mark --创建label
+(UILabel*)createLabelWithFrame:(CGRect)frame font:(int)font text:(NSString*)text;

+(UILabel *)createLabel:(CGRect)cgRect font:(UIFont *)font textColor:(UIColor*)textColor text:(NSString *)text backGroundColor:(UIColor *)bgColor textAlignment:(NSInteger)alignmentType;
#pragma mark --创建imageView
+(UIImageView *)createImageView:(CGRect)cgRect imageName:(NSString *)imageName;

#pragma mark --创建button
+(UIButton*)createBtnWithFrame:(CGRect)frame target:(id)target action:(SEL)action title:(NSString*)title imageName:(NSString*)imageName bgImageName:(NSString *)bgImageName;

//setbackgroundImage,setImage 2个imageView label 透明controll
+(UIButton *)createBtn:(CGRect)cgRect target:(id)target sel:(SEL)sel title:(NSString *)title titleColor:(UIColor *)titleColor font:(UIFont *)font image:(NSString *)imageName backGroundImage:(NSString *)backImage ;

//setbackgroundImage,setImage 2个imageView label 透明controll //设置内容的显示 内容的偏移量 标题的偏移量 bgBtn的图片视图的内容模式
+(UIButton *)createBtn:(CGRect)cgRect target:(id)target sel:(SEL)sel title:(NSString *)title titleColor:(UIColor *)titleColor font:(UIFont *)font image:(NSString *)imageName backGroundImage:(NSString *)backImage  ContentHorizontalAlignment:(UIControlContentHorizontalAlignment)contentHorizontalAlignment ContentEdgeInsets:(UIEdgeInsets)uIEdgeInsets TitleEdgeInsets:(UIEdgeInsets)titleEdgeInsets ImagecontentMode:(UIViewContentMode)imagecontentMode;
//自定义 Button
- (UIButton *)createBtnWithCustomType:(UIButtonType)buttonType target:(id)target selector:(SEL)selcector title:(NSString *)title titleColor:(UIColor *)titleColor titleFont:(UIFont *)font image:(NSString *)imageName highLightedImage:(NSString *)highLightImageName  bgImage:(NSString *)bGimageName hightLightedBGImage:(NSString *)highLightedBGImageName;
//用类方法封装
#pragma mark -创建scView
+(UIScrollView *)createScView:(CGRect)cgRect delegate:(id<UIScrollViewDelegate>)delegate sizeWidth:(CGFloat)width sizeHeight:(CGFloat)height offsetX:(CGFloat)X offsetY:(CGFloat)Y horizontalIndicator:(BOOL)horizon verticalIndicator:(BOOL)vertical bounces:(BOOL)bounces pageEnable:(BOOL)pageEnable;
#pragma mark -创建tableView 默认是grouped的  可以通过typeNameDefaultGrouped 设置plain 值为字符串@"plain"
+(UITableView *)createTableView:(CGRect)cgRect dataSourceTarget:(id)target1 delegateTarget:(id)target2 horizontalIndicator:(BOOL)horizon verticalIndicator:(BOOL)vertical type:(NSString*)typeNameDefaultGrouped separatorStyle:(UITableViewCellSeparatorStyle)style;
+ (UITableView *)createTableViewWithFrame:(CGRect)frame tableViewStyle:(UITableViewStyle)tableViewStyle dataSource:(id<UITableViewDataSource>) dataSource deleaget:(id<UITableViewDelegate>) delegate bgColor:(UIColor *)bgColor tableHeaderView:(UIView *)tableHeaderView tableFooterView:(UIView *)tableFooterView  separatorStyle:(UITableViewCellSeparatorStyle )separatorStyle separatorColor:(UIColor *)separatorColor userInteractionEnabled:(BOOL) userInteractionEnabled scrollEnabled:(BOOL)scrollEnabled horizontalIndicator:(BOOL)horizon verticalIndicator:(BOOL)vertica;
#pragma mark --创建View
+(UIView*)createViewWithFrame:(CGRect)frame;
#pragma mark --创建UITextField
+(UITextField*)createTextFieldWithFrame:(CGRect)frame placeholder:(NSString*)placeholder passWord:(BOOL)YESorNO leftImageView:(UIImageView*)imageView rightImageView:(UIImageView*)rightImageView Font:(float)font;
//适配器的方法  扩展性方法
//现有方法，已经在工程里面存在，如果修改工程内所有方法，工作量巨大，就需要使用适配器的方法
+(UITextField*)createTextFieldWithFrame:(CGRect)frame placeholder:(NSString*)placeholder passWord:(BOOL)YESorNO leftImageView:(UIImageView*)imageView rightImageView:(UIImageView*)rightImageView Font:(float)font backgRoundImageName:(NSString*)imageName;
#pragma mark --创建UIScrollView
+(UIScrollView*)createScrollViewWithFrame:(CGRect)frame andContentSize:(CGSize)size delegate:(id<UIScrollViewDelegate>)delegate;
#pragma mark --创建UIPageControl
+(UIPageControl*)createPageControlWithFrame:(CGRect)frame numberOfPages:(int)numberOfPages currentPage:(int)currentPage;
#pragma mark --创建UISlider
+(UISlider*)createSliderWithFrame:(CGRect)rect andThumbImageName:(NSString*)thumbImageName;

#pragma mark -********************
#pragma mark -ZCControl.h
#pragma mark -********************
#pragma mark 创建时间转换字符串
+(NSString *)stringFromDateWithHourAndMinute:(NSDate *)date;

#pragma mark -********************
#pragma mark -CheckCamera.h
#pragma mark -********************
#pragma mark-检查相机，摄像头，闪光灯，以及支持的媒体数据类型。image movie 以及相册相关
-(void)checkCamera;


#pragma mark -********************
#pragma mark -ClearCacheTool.h
#pragma mark -********************
/*s*
 *  获取path路径下文件夹的大小
 *
 *  @param path 要获取的文件夹 路径
 *
 *  @return 返回path路径下文件夹的大小
 */
+ (NSString *)getCacheSizeWithFilePath:(NSString *)path;

/**
 *  清除path路径下文件夹的缓存
 *
 *  @param path  要清除缓存的文件夹 路径
 *
 *  @return 是否清除成功
 */
+ (BOOL)clearCacheWithFilePath:(NSString *)path;


//获取具体文件的大小
+ (NSString *)getSizeWithData:(NSData *)data;

#pragma mark -********************
#pragma mark -GetFilePath.h
#pragma mark -********************
//获取文件夹路径
+ (NSString *)documentPath;

#pragma mark --获取图片的缩略图方法正确
//1.自动缩放到指定大小－－不保持宽高比
+(UIImage *)thumbnailWithImage:(UIImage *)image size:(CGSize)asize;
#pragma mark -该方法采用的是AspectFit模式
#pragma mark -- 指定尺寸按比例缩放,AspectFit模式。
+ (UIImage *)thumbnailWithImageWithoutScale:(UIImage *)image size:(CGSize)asize;
#pragma mark -该方法采用的是AspectFill模式
#pragma mark -- 1.指定尺寸按比例缩放,AspectFill模式。
+ (UIImage *)imageCompressForSize:(UIImage *)sourceImage targetSize:(CGSize)size;
#pragma mark -- 2.指定宽度按比例缩放。
//指定宽度按比例缩放
+ (UIImage *)imageCompressForWidth:(UIImage *)sourceImage targetWidth:(CGFloat)defineWidth;

#pragma mark -********************
#pragma mark -ViewHierarchyLogging.h  一般做为view的类别 方法引入
#pragma mark -********************
+(void)logViewHierarchyWithView:(UIView *)aView;

#pragma mark -********************
#pragma mark -ConstmBt.h  自定义 按钮点击 响应范围 一般是重写控件的 该方法
#pragma mark -********************

#pragma mark ----- 获取当前控制器
//获取topLevelWindow (可能第三方UI定制window导致捕获到第三方定制的非全屏window)
+ (UIWindow *)topLevelWindow;
//获取topLevelWindow 比较严格 (无论是否第三方UI定制Window，严格要求全屏window)
+ (UIWindow *)topLevelAllScreenWindow;

@end
