//
//  ZCommonUtils.m
//  DLNavigationTabBar
//
//  Created by xunshian on 17/1/23.
//  Copyright © 2017年 FT_David. All rights reserved.
//

#import "ZCommonUtils.h"

#import <sys/sysctl.h>

#import <AssetsLibrary/AssetsLibrary.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import <AVFoundation/AVFoundation.h>

#import <MediaPlayer/MediaPlayer.h>
#import <AVFoundation/AVFoundation.h>


@implementation ZCommonUtils
#pragma mark -********************
#pragma mark -CommonUtils
#pragma mark -********************
+ (BOOL)isNullOrNilWithObject:(id)object;
{
    if (object == nil || [object isEqual:[NSNull null]]) {
        return YES;
    } else if ([object isKindOfClass:[NSString class]]) {
        if ([object isEqualToString:@""]) {
            return YES;
        } else {
            return NO;
        }
    } else if ([object isKindOfClass:[NSNumber class]]) {
        if ([object isEqualToNumber:@0]) {
            return YES;
        } else {
            return NO;
        }
    }
    
    return NO;
}

+(CGSize)contentSize:(UILabel *)label text:(NSString *)text font:(UIFont *)font maxSize:(CGSize)maxSize lineSpacing:(CGFloat)lineSpacing
{
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc]init];
    paragraphStyle.lineBreakMode = label.lineBreakMode;
    paragraphStyle.alignment = label.textAlignment;
    UIFont *afont = font ? font : label.font;
    NSString *aStr = text ? text : label.text;
    NSDictionary *attributes = @{NSFontAttributeName:afont, NSParagraphStyleAttributeName:paragraphStyle};
    CGSize contentSize = [aStr boundingRectWithSize:maxSize options:NSStringDrawingUsesFontLeading|NSStringDrawingUsesLineFragmentOrigin attributes:attributes context:nil].size;
    return contentSize;
}


#pragma mark -********************
#pragma mark -UIZZJ.h
#pragma mark -********************
//1.设置控件的位置和大小 2.设置控件的用户交互 3.设置相应控件的常用属性－－其他的采用默认的
+(UILabel*)createLabelWithFrame:(CGRect)frame font:(int)font text:(NSString*)text
{
    UILabel*label=[[UILabel alloc]initWithFrame:frame];
    //限制行数
    label.numberOfLines=0;
    //对齐方式
    label.textAlignment=NSTextAlignmentLeft;
    label.backgroundColor=[UIColor clearColor];
    label.font=[UIFont systemFontOfSize:font];
    //单词折行
    label.lineBreakMode=NSLineBreakByWordWrapping;
    //默认字体颜色是白色
    label.textColor=[UIColor blackColor];
    //自适应（行数~字体大小按照设置大小进行设置）
    label.adjustsFontSizeToFitWidth=YES;
    label.text=text;
    return label;
}
+(UILabel *)createLabel:(CGRect)cgRect font:(UIFont *)font textColor:(UIColor*)textColor text:(NSString *)text backGroundColor:(UIColor *)bgColor textAlignment:(NSInteger)alignmentType
{
    UILabel *label = [[UILabel alloc]initWithFrame:cgRect];
    //nil默认－－－颜色需特殊处理
    if (bgColor)
    {
        label.backgroundColor = bgColor;
    }
    label.userInteractionEnabled = YES;
    label.textAlignment = alignmentType;
    label.font = font;
    label.textColor = textColor;
    label.text = text;
    return label;
}

+(UIImageView *)createImageView:(CGRect)cgRect imageName:(NSString *)imageName
{
    UIImageView *imgV = [[UIImageView alloc]initWithFrame:cgRect];
    imgV.userInteractionEnabled = YES;
    imgV.image = [UIImage imageNamed:imageName];
    return imgV;
}

+(UIButton*)createBtnWithFrame:(CGRect)frame target:(id)target action:(SEL)action title:(NSString*)title imageName:(NSString*)imageName bgImageName:(NSString *)bgImageName
{
    UIButton*button=[UIButton buttonWithType:UIButtonTypeCustom];
    button.frame=frame;
    [button setTitle:title forState:UIControlStateNormal];
//    [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
//    button.titleLabel.font = [UIFont systemFontOfSize:14];
    //图片与文字如果需要同时存在，就需要图片足够小 详见人人项目按钮设置
    [button setImage:[UIImage imageNamed:imageName] forState:UIControlStateNormal];
    //设置背景图片，可以使文字与图片共存
    [button setBackgroundImage:[UIImage imageNamed:bgImageName] forState:UIControlStateNormal];
    [button addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
    
    return button;
}

+(UIButton *)createBtn:(CGRect)cgRect target:(id)target sel:(SEL)sel title:(NSString *)title titleColor:(UIColor *)titleColor font:(UIFont *)font image:(NSString *)imageName backGroundImage:(NSString *)backImage
{
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = cgRect;
    [btn setTitle:title forState:UIControlStateNormal];
    [btn setTitleColor:titleColor forState:UIControlStateNormal];
    [btn setImage:[UIImage imageNamed:imageName] forState:UIControlStateNormal];
    [btn setBackgroundImage:[UIImage imageNamed:backImage] forState:UIControlStateNormal];
    btn.titleLabel.font = font;
    [btn addTarget:target action:sel forControlEvents:UIControlEventTouchUpInside];
    return btn;
}

+(UIButton *)createBtn:(CGRect)cgRect target:(id)target sel:(SEL)sel title:(NSString *)title titleColor:(UIColor *)titleColor font:(UIFont *)font image:(NSString *)imageName backGroundImage:(NSString *)backImage  ContentHorizontalAlignment:(UIControlContentHorizontalAlignment)contentHorizontalAlignment ContentEdgeInsets:(UIEdgeInsets)uIEdgeInsets TitleEdgeInsets:(UIEdgeInsets)titleEdgeInsets ImagecontentMode:(UIViewContentMode)imagecontentMode{
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = cgRect;
    [btn setTitle:title forState:UIControlStateNormal];
    [btn setTitleColor:titleColor forState:UIControlStateNormal];
    [btn setImage:[UIImage imageNamed:imageName] forState:UIControlStateNormal];
    [btn setBackgroundImage:[UIImage imageNamed:backImage] forState:UIControlStateNormal];
    btn.titleLabel.font = font;
    [btn addTarget:target action:sel forControlEvents:UIControlEventTouchUpInside];
    
    //设置内容的显示
    btn.contentHorizontalAlignment = contentHorizontalAlignment;
    //btn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    //设置内容的偏移量
    //btn.contentEdgeInsets = UIEdgeInsetsMake(5, 0, 0, 0);
    btn.contentEdgeInsets = uIEdgeInsets;
    //设置标题的偏移量
    //btn.titleEdgeInsets = UIEdgeInsetsMake(0, 5, 0, 0);
    btn.titleEdgeInsets = titleEdgeInsets;
    //设置bgBtn的图片视图的内容模式
    //btn.imageView.contentMode = UIViewContentModeCenter;
    btn.imageView.contentMode = imagecontentMode;
    
    return btn;
}

//自定义 Button
- (UIButton *)createBtnWithCustomType:(UIButtonType)buttonType target:(id)target selector:(SEL)selcector title:(NSString *)title titleColor:(UIColor *)titleColor titleFont:(UIFont *)font image:(NSString *)imageName highLightedImage:(NSString *)highLightImageName  bgImage:(NSString *)bGimageName hightLightedBGImage:(NSString *)highLightedBGImageName{
    //1、添加背景的btn
    UIButton *bgBtn = [UIButton buttonWithType:buttonType];
    [bgBtn setTitle:title forState:UIControlStateNormal];
    //设置字体颜色
    [bgBtn setTitleColor:titleColor forState:UIControlStateNormal];
    //设置字体大小
    bgBtn.titleLabel.font = font;
    //添加事件监听
    [bgBtn addTarget:target action:selcector forControlEvents:UIControlEventTouchUpInside];
    //设置图片
    [bgBtn setImage:[UIImage imageNamed:imageName] forState:UIControlStateNormal];
    [bgBtn setImage:[UIImage imageNamed:highLightImageName] forState:UIControlStateHighlighted];
    
    //对bgBtn添加背景
    UIImage *image = [[UIImage imageNamed:bGimageName] resizableImageWithCapInsets:UIEdgeInsetsMake(44, 0, 44, 1) resizingMode:UIImageResizingModeStretch];
    UIImage *highLightedImage = [[UIImage imageNamed:highLightedBGImageName] resizableImageWithCapInsets:UIEdgeInsetsMake(44, 0, 44, 1) resizingMode:UIImageResizingModeStretch];
    //上面只是设置图片拉伸方式而已。无影响 -z
    //        UIImage *image = [UIImage imageNamed:@"buddy_header_bg"];
    //        UIImage *highLightedImage = [UIImage imageNamed:@"buddy_header_bg_highlighted"];
    [bgBtn setBackgroundImage:image forState:UIControlStateNormal];
    [bgBtn setBackgroundImage:highLightedImage forState:UIControlStateHighlighted];
//    //设置内容的显示
//    bgBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;//设置文字位置，现设为居左，默认的是居中
//    //设置内容的偏移量 上 左 下 右
//    bgBtn.contentEdgeInsets = UIEdgeInsetsMake(0, 10, 0, 0);//使文字距离做边框保持10个像素的距离。
//    //设置标题的偏移量
//    bgBtn.titleEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 0);
//    //设置bgBtn的图片视图的内容模式
//    bgBtn.imageView.contentMode = UIViewContentModeCenter;
//    bgBtn.imageView.clipsToBounds = NO;
    return bgBtn;
}

#pragma mark -创建scView
+(UIScrollView *)createScView:(CGRect)cgRect delegate:(id<UIScrollViewDelegate>)delegate sizeWidth:(CGFloat)width sizeHeight:(CGFloat)height offsetX:(CGFloat)X offsetY:(CGFloat)Y horizontalIndicator:(BOOL)horizon verticalIndicator:(BOOL)vertical bounces:(BOOL)bounces pageEnable:(BOOL)pageEnable
{
    //可以封装一下
    UIScrollView *scView = [[UIScrollView alloc]initWithFrame:cgRect];
    scView.contentSize = CGSizeMake(width, height);
    scView.contentOffset = CGPointMake(X,Y);
    //水平滑动条
    scView.showsHorizontalScrollIndicator = horizon;
    //垂直滑动条
    scView.showsVerticalScrollIndicator = vertical;
    //弹性
    scView.bounces = bounces;
    //翻一页
    scView.pagingEnabled = pageEnable;
    scView.delegate =  delegate;
    return scView;
}

+(UIScrollView*)createScrollViewWithFrame:(CGRect)frame andContentSize:(CGSize)size delegate:(id<UIScrollViewDelegate>)delegate
{
    UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:frame];
    
    scrollView.pagingEnabled = YES;
    scrollView.contentSize = size;
    scrollView.showsHorizontalScrollIndicator = NO;
    scrollView.showsVerticalScrollIndicator = NO;
    scrollView.scrollsToTop = NO;
    scrollView.delegate = delegate;
    return scrollView ;
}

#pragma mark -创建tableView 默认是grouped的  可以通过typeNameDefaultGrouped 设置plain 值为字符串@"plain"
+(UITableView *)createTableView:(CGRect)cgRect dataSourceTarget:(id)target1 delegateTarget:(id)target2 horizontalIndicator:(BOOL)horizon verticalIndicator:(BOOL)vertical type:(NSString*)typeNameDefaultGrouped separatorStyle:(UITableViewCellSeparatorStyle)style
{
    UITableView *tableView;
    if([typeNameDefaultGrouped isEqualToString:@"plain"])
    {
        tableView = [[UITableView alloc]initWithFrame:cgRect style:UITableViewStylePlain];
    }else
    {
        tableView = [[UITableView alloc]initWithFrame:cgRect style:UITableViewStyleGrouped];
    }
    tableView.delegate = target1;
    tableView.dataSource = target2;
    tableView.showsHorizontalScrollIndicator =horizon;
    tableView.showsVerticalScrollIndicator = vertical;
    tableView.separatorStyle = style;
    return tableView;
}

+ (UITableView *)createTableViewWithFrame:(CGRect)frame tableViewStyle:(UITableViewStyle)tableViewStyle dataSource:(id<UITableViewDataSource>) dataSource deleaget:(id<UITableViewDelegate>) delegate bgColor:(UIColor *)bgColor tableHeaderView:(UIView *)tableHeaderView tableFooterView:(UIView *)tableFooterView  separatorStyle:(UITableViewCellSeparatorStyle )separatorStyle separatorColor:(UIColor *)separatorColor userInteractionEnabled:(BOOL) userInteractionEnabled scrollEnabled:(BOOL)scrollEnabled horizontalIndicator:(BOOL)horizon verticalIndicator:(BOOL)vertical{
    
    // tableView有两种样式
    //     UITableViewStylePlain  普通的表格样式 组头是有粘性的 表现为cell滚动在当前组时组头会一直显示在最上方
    //    UITableViewStyleGrouped  分组模式 组头是没有粘性的 表现为组头会一直随cell滚动
    UITableView *tableView = [[UITableView alloc] initWithFrame:frame style:tableViewStyle];
    //tableView 设置代理
    tableView.dataSource = dataSource;
    tableView.delegate = delegate;
    tableView.userInteractionEnabled = userInteractionEnabled;//控制tableView的是否打开用户交互 默认是YES
    tableView.scrollEnabled = scrollEnabled;//控制tableView是否可以滑动 默认是YES
    tableView.showsHorizontalScrollIndicator =horizon;
    tableView.showsVerticalScrollIndicator = vertical;
    //1.tableView本身相关的
    
    tableView.backgroundColor = bgColor;
    //设置整个tablView的头部/尾部视图
    tableView.tableHeaderView = tableHeaderView;
    tableView.tableFooterView = tableFooterView;
    //设置分割线样式
    tableView.separatorStyle = separatorStyle;// UITableViewCellSeparatorStyleNone,  没有分隔线
    // UITableViewCellSeparatorStyleSingleLine, 正常分隔线
    //设置我们分割线颜色(clearColor相当于取消系统分割线)
    tableView.separatorColor = separatorColor;//[UIColor clearColor]
    
    //2.tableView的section相关
    
    //组头组尾的高
    //    tableView.sectionHeaderHeight = kSectionHeaderHeight;
    //    tableView.sectionFooterHeight = kSectionFooterHeight;
    //    /* 估算的统一的每一组头部高度，设置估算高度可以优化性能 */
    //    tableView.estimatedSectionHeaderHeight = kSectionHeaderHeight;
    //    /* 估算的统一的每一组的尾部高度 */
    //    tableView.estimatedSectionFooterHeight = kSectionFooterHeight;
    
    
    //2.tableView的cell相关的
    
    //    // 告诉tableView的真实高度是自动计算的，根据你的约束来计算
    //    tableView.rowHeight = UITableViewAutomaticDimension;
    //    //修改tableView的行高
    //    //tableView.rowHeight = 100;
    //    // 告诉tableView所有cell的估计行高
    //    tableView.estimatedRowHeight = kCellHeight;
    //    // 返回估算告诉,作用:在tablView显示时候,先根据估算高度得到整个tablView高,而不必知道每个cell的高度,从而达到高度方法的懒加载调用
    
    //3.tableView的索引相关 sectionIndex
    
    //    // 设置索引条内部文字颜色
    //    tableView.sectionIndexColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:1];
    //    // 设置索引条背景颜色
    //    tableView.sectionIndexBackgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:1];
    
    //5.tableView的编辑模式 editing
    
    //    tableView.editing = YES;/* 是否是编辑模式，默认是NO */
    //    tableView.allowsSelection = YES;/* tableView处在非编辑模式的时候是否允许选中行，默认是YES */
    //    tableView.allowsSelectionDuringEditing = NO;/* tableView处在编辑模式的时候是否允许选中行，默认是NO */
    //    tableView.allowsMultipleSelection = NO;/* tableView处在非编辑模式的时候是否允许选中多行数据，默认是NO */
    //    tableView.allowsSelectionDuringEditing = NO;/* tableView处在编辑模式的时候是否允许选中多行数据，默认是NO */
    
    return tableView;
}


+(UIView*)createViewWithFrame:(CGRect)frame
{
    UIView*view=[[UIView alloc]initWithFrame:frame];
    
    return view ;
    
}
+(UITextField*)createTextFieldWithFrame:(CGRect)frame placeholder:(NSString*)placeholder passWord:(BOOL)YESorNO leftImageView:(UIImageView*)imageView rightImageView:(UIImageView*)rightImageView Font:(float)font
{
    UITextField*textField=[[UITextField alloc]initWithFrame:frame];
    //灰色提示框
    textField.placeholder=placeholder;
    //文字对齐方式
    textField.textAlignment=NSTextAlignmentLeft;
    textField.secureTextEntry=YESorNO;
    //边框
    //textField.borderStyle=UITextBorderStyleLine;
    //键盘类型
    textField.keyboardType=UIKeyboardTypeEmailAddress;
    //关闭首字母大写
    textField.autocapitalizationType=NO;
    //清除按钮
    textField.clearButtonMode=YES;
    //左图片
    textField.leftView=imageView;
    textField.leftViewMode=UITextFieldViewModeAlways;
    //右图片
    textField.rightView=rightImageView;
    //编辑状态下一直存在
    textField.rightViewMode=UITextFieldViewModeWhileEditing;
    //自定义键盘
    //textField.inputView
    //字体
    textField.font=[UIFont systemFontOfSize:font];
    //字体颜色
    textField.textColor=[UIColor blackColor];
    return textField ;
    
}
#pragma  mark 适配器方法
+(UITextField*)createTextFieldWithFrame:(CGRect)frame placeholder:(NSString*)placeholder passWord:(BOOL)YESorNO leftImageView:(UIImageView*)imageView rightImageView:(UIImageView*)rightImageView Font:(float)font backgRoundImageName:(NSString*)imageName
{
    UITextField*text= [self createTextFieldWithFrame:frame placeholder:placeholder passWord:YESorNO leftImageView:imageView rightImageView:rightImageView Font:font];
    text.background=[UIImage imageNamed:imageName];
    return  text;
}

+(UIPageControl*)createPageControlWithFrame:(CGRect)frame numberOfPages:(int)numberOfPages currentPage:(int)currentPage
{
    UIPageControl *pageControl = [[UIPageControl alloc] initWithFrame:frame];
    pageControl.numberOfPages = numberOfPages;
    pageControl.currentPage = currentPage;
    return pageControl;
}
+(UISlider*)createSliderWithFrame:(CGRect)rect andThumbImageName:(NSString*)thumbImageName
{
    UISlider *slider = [[UISlider alloc]initWithFrame:rect];
    slider.minimumValue = 0;
    slider.maximumValue = 1;
    [slider setThumbImage:[UIImage imageNamed:thumbImageName] forState:UIControlStateNormal];
    slider.maximumTrackTintColor = [UIColor grayColor];
    slider.minimumTrackTintColor = [UIColor yellowColor];
    slider.continuous = YES;
    slider.enabled = YES;
    return slider ;
}
#pragma mark -********************
#pragma mark -ZCControl.h
#pragma mark -********************

+(NSString *)stringFromDateWithHourAndMinute:(NSDate *)date
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    //zzz表示时区，zzz可以删除，这样返回的日期字符将不包含时区信息。
    [dateFormatter setDateFormat:@"HH:mm"];
    NSString *destDateString = [dateFormatter stringFromDate:date];
    
    return destDateString;
}

#pragma mark -********************
#pragma mark -CheckCamera.h
#pragma mark -********************
#pragma mark-检查相机，摄像头，闪光灯，以及支持的媒体数据类型。image movie 以及相册相关
-(void)checkCamera{
    if ([self iSAvailCamera]) {
        NSLog(@"摄像机可用");
    }else{
        NSLog(@"摄像机不可用");
    }
    
    if ([self iSAvailCameraFront]) {
        NSLog(@"摄像机前置摄像头可用");
    }else{
        NSLog(@"摄像机前置摄像头不可用");
    }
    if ([self iSAvailCameraRear]) {
        NSLog(@"摄像机后置摄像头可用");
    }else{
        NSLog(@"摄像机后置摄像头不可用");
    }
    if ([self iSAvailCameraFlashFront]) {
        NSLog(@"摄像机前置摄像头闪光灯可用");
    }else{
        NSLog(@"摄像机前置摄像头闪光灯不可用");
    }
    if ([self iSAvailCameraFlashRear]) {
        NSLog(@"摄像机后置摄像头闪光灯可用");
    }else{
        NSLog(@"摄像机后置摄像头闪光灯不可用");
    }
    
    
    //检查当前Camera支持的媒体类型：image video movie //kUTType不提示，但导入头文件后可用。
    if ([self doesCameraSupportTakingPhotos]) {
        NSLog(@"camera 支持拍照");
    }else{
        NSLog(@"camera 不支持拍照");
    }
    if ([self doesCameraSupportShootingVideos]) {
        NSLog(@"camera 支持录像");
    }else{
        NSLog(@"camera 不支持录像");
    }
    
    //检查相册是否可用
    if ([self isPhotoLibraryAvailable]) {
        NSLog(@"相册可用");
    } else {
        NSLog(@"相册不可用");
    }
    
    //是否可以在相册中选择照片
    if ([self canUserPickPhotosFromPhotoLibrary]) {
        NSLog(@"可以在相册中选择照片");
    } else {
        NSLog(@"不可以在相册中选择照片");
        
    }
    
    //是否可以在相册中选择视频
    if ([self canUserPickVideosFromPhotoLibrary]) {
        NSLog(@"可以在相册中选择视频");
    } else {
        NSLog(@"不可以在相册中选择视频");
    }
    
    
}

//检查摄像机是否可用
-(BOOL)iSAvailCamera{
    return [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera];
}
//检查前后摄像头是否可用
-(BOOL)iSAvailCameraFront{
    return [UIImagePickerController isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceFront];
}
-(BOOL)iSAvailCameraRear{
    return [UIImagePickerController isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceRear];
}
//检查前后闪光灯是否可用
-(BOOL)iSAvailCameraFlashFront{
    return [UIImagePickerController isFlashAvailableForCameraDevice:UIImagePickerControllerCameraDeviceFront];
}
-(BOOL)iSAvailCameraFlashRear{
    return [UIImagePickerController isFlashAvailableForCameraDevice:UIImagePickerControllerCameraDeviceRear];
}

//支持的媒体类型
-(BOOL)cameraSupportsMedia:(NSString *)paraMediaType sourceType:(UIImagePickerControllerSourceType)paramSourceTyep{
    __block BOOL result = NO;
    if ([paraMediaType length] == 0) {
        NSLog(@"Media type is empty");
        return NO;
    }
    NSArray *availableMediaTypes = [UIImagePickerController availableMediaTypesForSourceType:paramSourceTyep];
    //public.image,public.movie
    [availableMediaTypes enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSString *mediaType = (NSString *)obj;
        if ([mediaType isEqualToString:paraMediaType]) {
            result = YES;
            *stop = YES;
        }
    }];
    return result;
}
//检查摄像头是否支持拍照
-(BOOL) doesCameraSupportTakingPhotos{
    /*在此处注意我们要将MobileCoreServices 框架添加到项目中，
     然后将其导入：#import <MobileCoreServices/MobileCoreServices.h> 。不然后出现错误使用未声明的标识符 'kUTTypeImage'
     */
    return [self cameraSupportsMedia:(__bridge NSString *)kUTTypeImage sourceType:UIImagePickerControllerSourceTypeCamera];
}

//检查摄像头是否支持录像
-(BOOL) doesCameraSupportShootingVideos{
    /*在此处注意我们要将MobileCoreServices 框架添加到项目中，
     然后将其导入：#import <MobileCoreServices/MobileCoreServices.h> 。不然后出现错误使用未声明的标识符 'kUTTypeMovie'
     */
    return [self cameraSupportsMedia:(__bridge NSString *)kUTTypeMovie sourceType:UIImagePickerControllerSourceTypeCamera];
}

#pragma mark- 相册相关
//相册是否可用
-(BOOL)isPhotoLibraryAvailable{
    return [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary];
}
//是否可以在相册中选择照片
-(BOOL)canUserPickPhotosFromPhotoLibrary{
    return [self cameraSupportsMedia:(__bridge NSString*)kUTTypeImage sourceType:UIImagePickerControllerSourceTypePhotoLibrary];
}
//是否可以在相册中选择视频
-(BOOL)canUserPickVideosFromPhotoLibrary{
    return [self cameraSupportsMedia:(__bridge NSString *)kUTTypeMovie sourceType:UIImagePickerControllerSourceTypePhotoLibrary];
}

#pragma mark -********************
#pragma mark -ClearCacheTool.h
#pragma mark -********************
#pragma mark - 获取path路径下文件夹大小
+ (NSString *)getCacheSizeWithFilePath:(NSString *)path{
    
    /* subpathsAtPath: returns an NSArray of all contents and subpaths recursively from the provided path. This may be very expensive to compute for deep filesystem hierarchies, and should probably be avoided.
     */
    
    // 获取“path”文件夹下的所有文件 －－递归处理的
    NSArray *subPathArr = [[NSFileManager defaultManager] subpathsAtPath:path];
    
    NSString *filePath  = nil;
    NSInteger totleSize = 0;
    
    for (NSString *subPath in subPathArr){
        
        // 1. 拼接每一个文件的全路径
        filePath =[path stringByAppendingPathComponent:subPath];
        
        // 2. 是否是文件夹，默认不是
        BOOL isDirectory = NO;
        
        // 3. 判断文件是否存在
        BOOL isExist = [[NSFileManager defaultManager] fileExistsAtPath:filePath isDirectory:&isDirectory];
        
        
        // 4. 以上判断目的是忽略不需要计算的文件
        if (!isExist || isDirectory || [filePath containsString:@".DS"]){
            // 过滤: 1. 文件夹不存在  2. 过滤文件夹  3. 隐藏文件
            continue;
        }
        
        // 5. 指定路径，获取这个路径的属性
        NSDictionary *dict = [[NSFileManager defaultManager] attributesOfItemAtPath:filePath error:nil];
        /**
         attributesOfItemAtPath: 文件夹路径
         该方法只能获取文件的属性, 无法获取文件夹属性, 所以也是需要遍历文件夹的每一个文件的原因
         */
        
        // 6. 获取每一个文件的大小
        NSInteger size = [dict[@"NSFileSize"] integerValue];
        
        // 7. 计算总大小
        totleSize += size;
    }
    
    //8. 将文件夹大小转换为 M/KB/B
    NSString *totleStr = nil;
    
    if (totleSize > 1000 * 1000){
        totleStr = [NSString stringWithFormat:@"%.2fM",totleSize / 1000.00f /1000.00f];
        
    }else if (totleSize > 1000){
        totleStr = [NSString stringWithFormat:@"%.2fKB",totleSize / 1000.00f ];
        
    }else{
        totleStr = [NSString stringWithFormat:@"%.2fB",totleSize / 1.00f];
    }
    
    return totleStr;
}


#pragma mark - 清除path文件夹下缓存大小
+ (BOOL)clearCacheWithFilePath:(NSString *)path{
    
    /* contentsOfDirectoryAtPath:error: returns an NSArray of NSStrings representing the filenames of the items in the directory. If this method returns 'nil', an NSError will be returned by reference in the 'error' parameter. If the directory contains no items, this method will return the empty array.
     
     This method replaces directoryContentsAtPath:
     */
    //拿到path路径的下一级目录的子文件夹--没有使用递归
    NSArray *subPathArr = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:path error:nil];
    
    NSString *message  = nil;
    NSString *filePath = nil;
    
    NSError *error = nil;
    
    for (NSString *subPath in subPathArr)
    {
        filePath = [path stringByAppendingPathComponent:subPath];
        
        //删除子文件夹－－该方法可以删除该路径下的文件和文件夹（也即文件项）
        [[NSFileManager defaultManager] removeItemAtPath:filePath error:&error];
        if (error) {
            message = @"删除子文件夹失败";
            NSLog(@"message=%@",message);
            return NO;
        }
    }
    return YES;
}


#pragma mark - 获取具体文件的大小
+ (NSString *)getSizeWithData:(NSData *)data{
    
    NSInteger totleSize = 0;
    totleSize = data.length;
    
    //8. 将文件夹大小转换为 M/KB/B
    NSString *totleStr = nil;
    
    if (totleSize > 1000 * 1000){
        totleStr = [NSString stringWithFormat:@"%.2fM",totleSize / 1000.00f /1000.00f];
        
    }else if (totleSize > 1000){
        totleStr = [NSString stringWithFormat:@"%.2fKB",totleSize / 1000.00f ];
        
    }else{
        totleStr = [NSString stringWithFormat:@"%.2fB",totleSize / 1.00f];
    }
    
    NSLog(@"size = %@",totleStr);
    
    return totleStr;
}

#pragma mark -********************
#pragma mark -GetFilePath.h
#pragma mark -********************
//获取文件夹路径
+ (NSString *)documentPath
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentPath = [paths objectAtIndex:0];
    return documentPath;
}

#pragma mark -图片处理 -z
#pragma mark --获取图片的缩略图方法正确
//1.自动缩放到指定大小－－不保持宽高比
+(UIImage *)thumbnailWithImage:(UIImage *)image size:(CGSize)asize
{
    
    UIImage *newimage;
    if (nil == image) {
        newimage = nil;
    }
    else{
        UIGraphicsBeginImageContext(asize);
        [image drawInRect:CGRectMake(0, 0, asize.width, asize.height)];
        newimage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
    }
    return newimage;
}

#pragma mark 指定尺寸按比例缩放,AspectFit模式。
//.按宽高比，生成一个缩放图 该方法采用的是AspectFit模式
+(UIImage *)thumbnailWithImageWithoutScale:(UIImage *)image size:(CGSize)asize
{
    UIImage *newimage;
    if (nil == image) {
        newimage = nil;
    }
    else{
        
        CGSize oldsize = image.size;
        CGRect rect;
        //采取的方案是：保证一边的缩放正合适，另一边进行平移截取
        
        /**
         *  用目标宽高比 与 原始图片宽高比进行比较
         1.如果目标宽高比大－－ 首先取目标的高为绘制时的高，然后通过目标的高 乘以 原始图片宽高比获取绘制时的宽
         2.如果目标宽高比小－－ 首先取目标的宽为绘制时的宽，然后通过目标的宽 乘以 原始图片高宽比获取绘制时的高
         3.根据1，2结果（比目标尺寸小）进行正方向平移处理－－进行底色填充
         */
        if (asize.width/asize.height > oldsize.width/oldsize.height) {
            rect.size.width = asize.height*(oldsize.width/oldsize.height);
            rect.size.height = asize.height;
            rect.origin.x = (asize.width - rect.size.width)/2;
            rect.origin.y = 0;
        }
        else{
            rect.size.width = asize.width;
            rect.size.height = asize.width*(oldsize.height/oldsize.width);
            rect.origin.x = 0;
            rect.origin.y = (asize.height - rect.size.height)/2;
        }
        
        UIGraphicsBeginImageContext(asize);
        CGContextRef context = UIGraphicsGetCurrentContext();
        CGContextSetFillColorWithColor(context, [[UIColor clearColor] CGColor]);
        UIRectFill(CGRectMake(0, 0, asize.width, asize.height));//clear background
        [image drawInRect:rect];
        newimage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
    }
    return newimage;
    
}

#pragma mark 指定尺寸按比例缩放,AspectFill模式。
//iOS图片生成小缩略图－－该方法原理上是保持了宽高比处理的 获取指定大小的图片
+ (UIImage *)imageCompressForSize:(UIImage *)sourceImage targetSize:(CGSize)size{
    
    UIImage *newImage = nil;
    
    //原始数据
    CGSize imageSize = sourceImage.size;
    CGFloat width = imageSize.width;
    CGFloat height = imageSize.height;
    
    //目标数据
    CGFloat targetWidth = size.width;
    CGFloat targetHeight = size.height;
    
    CGFloat scaleFactor = 0.0;
    CGFloat scaledWidth = targetWidth;//此处只是做默认的初始化--对下面的if判断为真时的赋值
    CGFloat scaledHeight = targetHeight;//此处只是做默认的初始化
    
    CGPoint thumbnailPoint = CGPointMake(0.0, 0.0);
    //size即targetSize 与原始sourceImageSize不等
    if(CGSizeEqualToSize(imageSize, size) == NO)
    {
        //用目标宽高 除以 原始宽高 获得缩放比例因子
        CGFloat widthFactor = targetWidth / width;
        CGFloat heightFactor = targetHeight / height;
        
        //取缩放因子中的较大值
        scaleFactor = widthFactor > heightFactor ? widthFactor : heightFactor;
        
        //无论是取的宽的缩放因子，还是高的缩放因子，取谁代表谁的比例缩放到目标大小刚刚好(因为两者相除得到比例因子，然后乘以比例因子就可以获得目标值)。 至于另一个方向缩放比例就肯定不可能是目标值（在这里指的是大），得另外处理，见下面。
        scaledWidth = width * scaleFactor;
        scaledHeight = height * scaleFactor;
        //此处的另外处理－－（比目标尺寸大）就是进行了向负方向的平移（取中间的目标长度部分绘制）
        if(widthFactor > heightFactor){//无论是取的宽的缩放因子，还是高的缩放因子，取谁代表谁的比例缩放到目标大小刚刚好(而且这里是谁大就取谁)  那么必定导致另一个方向的拉伸变大，因为比例因子大了。
            thumbnailPoint.y = (targetHeight - scaledHeight) * 0.5;
        }else if(widthFactor < heightFactor){
            thumbnailPoint.x = (targetWidth - scaledWidth) * 0.5;
        }
    }
    
    //设置scale的值
    UIGraphicsBeginImageContextWithOptions(size, NO, 1.0);
    CGRect thumbnailRect = CGRectZero;
    thumbnailRect.origin = thumbnailPoint;
    thumbnailRect.size.width = scaledWidth;
    thumbnailRect.size.height = scaledHeight;
    [sourceImage drawInRect:thumbnailRect];
    newImage = UIGraphicsGetImageFromCurrentImageContext();
    
    if(newImage == nil){
        
        NSLog(@"scale image fail");
        
    }
    
    UIGraphicsEndImageContext();
    
    return newImage;
    
}
#pragma mark 指定宽度按比例缩放。
//指定宽度按比例缩放 该方法采用的是AspectFill模式
+ (UIImage *)imageCompressForWidth:(UIImage *)sourceImage targetWidth:(CGFloat)defineWidth{
    UIImage *newImage = nil;
    CGSize imageSize = sourceImage.size;
    CGFloat width = imageSize.width;
    CGFloat height = imageSize.height;
    CGFloat targetWidth = defineWidth;
    CGFloat targetHeight = height / (width / targetWidth);
    CGSize size = CGSizeMake(targetWidth, targetHeight);
    CGFloat scaleFactor = 0.0;
    CGFloat scaledWidth = targetWidth;
    CGFloat scaledHeight = targetHeight;
    CGPoint thumbnailPoint = CGPointMake(0.0, 0.0);
    
    if(CGSizeEqualToSize(imageSize, size) ==NO){
        CGFloat widthFactor = targetWidth / width;
        CGFloat heightFactor = targetHeight / height;
        
        if(widthFactor > heightFactor){
            scaleFactor = widthFactor;
        }else{
            scaleFactor = heightFactor;
        }
        scaledWidth = width * scaleFactor;
        scaledHeight = height * scaleFactor;
        
        if(widthFactor > heightFactor){
            thumbnailPoint.y = (targetHeight - scaledHeight) *0.5;
        }else if(widthFactor < heightFactor){
            thumbnailPoint.x = (targetWidth - scaledWidth) *0.5;
        }
    }
    UIGraphicsBeginImageContext(size);
    CGRect thumbnailRect = CGRectZero;
    thumbnailRect.origin = thumbnailPoint;
    thumbnailRect.size.width = scaledWidth;
    thumbnailRect.size.height = scaledHeight;
    [sourceImage drawInRect:thumbnailRect];
    newImage = UIGraphicsGetImageFromCurrentImageContext();
    
    if(newImage == nil){
        NSLog(@"scale image fail");
    }
    UIGraphicsEndImageContext();
    return newImage;
}

#pragma mark -********************
#pragma mark -ViewHierarchyLogging.h
#pragma mark -********************
+(void)logViewHierarchyWithView:(UIView *)aView{
    NSLog(@"%@",aView);
    for (UIView *subView in aView.subviews) {
        
        [self logViewHierarchyWithView:subView];
    }
}


#pragma mark -********************
#pragma mark -ConstmBt.h  自定义 按钮点击 响应范围
#pragma mark -********************
//-(BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event{
//    if ([super pointInside:point withEvent:event]) {
//        
//        CGFloat radius = self.bounds.size.width;
//        CGFloat dx = point.x - self.bounds.size.width/2.0;
//        CGFloat dy = point.y - radius;
//        CGFloat distance = sqrt(dx * dx + dy * dy);
//        
//        //        NSLog(@"%f",distance);
//        //        NSLog(@"%f",radius);
//        return distance < radius;
//    }
//    
//    return NO;
//}

#pragma mark 获取topLevelWindow
//获取topLevelWindow (可能第三方UI定制window导致捕获到第三方定制的非全屏window)
+ (UIWindow *)topLevelWindow
{
    UIWindow *topView = [UIApplication sharedApplication].keyWindow;
    for (UIWindow *win in [[UIApplication sharedApplication].windows  reverseObjectEnumerator])
    {
        if ([win isEqual: topView])
        {
            continue;
        }
        if (win.windowLevel > topView.windowLevel && win.hidden != YES)
        {
            topView =win;
        }
    }
    return topView;
}
//获取topLevelWindow (无论是否第三方UI定制Window，严格要求全屏window)
+ (UIWindow *)topLevelAllScreenWindow
{
    UIWindow *topView = [UIApplication sharedApplication].keyWindow;
    for (UIWindow *win in [[UIApplication sharedApplication].windows  reverseObjectEnumerator])
    {
        if ([win isEqual: topView])
        {
            continue;
        }
        if (win.windowLevel > topView.windowLevel
            && win.hidden != YES
            && CGRectEqualToRect(win.bounds, [UIScreen mainScreen].bounds))
        {
            topView =win;
        }
    }
    return topView;
}

@end
