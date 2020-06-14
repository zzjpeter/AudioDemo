//
//  CommonVideoConfiguration.h
//  RealTimeAVideo
//
//  Created by iLogiEMAC on 16/8/3.
//  Copyright © 2016年 zp. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AVHeader.h"

@import CoreGraphics;
//分辨率
typedef NS_ENUM(NSUInteger,CommonVideoSessionPreset) {
    kCommonVideoSessionPreset640x480,   //普通
    kCommonVideoSessionPreset960x540,   //标准
    kCommonVideoSessionPreset1280x720,  //高清
    kCommonVideoSessionPreset1920x1080  //全高清
};

//视频质量
typedef NS_ENUM(NSUInteger,CommonVideoQuality) {
    /**
     * 普通分辨率
     */
    // 码率:500Kbps  帧数:15
    kCommonVideoQuality_Common_Low = 0,
    // 码率:800Kbps  帧数:24
    kCommonVideoQuality_Common_Medium,
    // 码率:800Kbps  帧数:30
    kCommonVideoQuality_Common_High,
    
    
    /**
     *  标准分辨率
     */
     // 码率:800Kbps  帧数:15
    kCommonVideoQuality_Standard_Low,
      // 码率:800Kbps  帧数:24
    kCommonVideoQuality_Standard_Medium,
      // 码率:800Kbps  帧数:30
    kCommonVideoQuality_Standard_Hight,
    
    
    /**
     *  高清分辨率
     */
    // 码率:1000Kbps  帧数:15
    kCommonVideoQuality_HD_Low,
    // 码率:1200Kbps  帧数:24
    kCommonVideoQuality_HD_Medium,
    // 码率:1200Kbps  帧数:30
    kCommonVideoQuality_HD_Hight,
    
    
    //全高清分辨率
    // 码率:1500Kbps  帧数:15
    kCommonVideoQuality_FHD_Low,
    // 码率:1500Kbps  帧数:24
    kCommonVideoQuality_FHD_Medium,
    // 码率:1500Kbps  帧数:30
    kCommonVideoQuality_FHD_Hight,
    
    kCommonVideoQuality_Default = kCommonVideoQuality_Standard_Medium
};

@interface CommonVideoConfiguration : NSObject

// 默认视频配置
+ (instancetype)defaultConfiguration;
// 默认视频配置质量
+ (instancetype)defaultConfigurationForQuality:(CommonVideoQuality)quality;
// 默认视频配置质量和横竖屏
+ (instancetype)defaultConfigurationForQuality:(CommonVideoQuality)quality landscape:(BOOL)landscape;
/// 视频的分辨率，宽高务必设定为 2 的倍数，否则解码播放时可能出现绿边
@property (nonatomic, assign) CGSize videoSize;
// 码流 (bps)
@property (nonatomic,assign)NSUInteger videoBitRate;
// 最大码流 (bps)
@property (nonatomic,assign)NSUInteger videoMaxBitRate;
// 最小码流(bps)
@property (nonatomic,assign)NSUInteger videoMinBitRate;
// 帧率(帧速度、fps）
@property (nonatomic,assign)NSUInteger videoFrameRate;
// 最大帧率
@property (nonatomic,assign)NSUInteger videoMaxFrameRate;
// 最小帧率
@property (nonatomic,assign)NSUInteger videoMinFrameRate;
@property (nonatomic,assign)NSUInteger videoMaxKeyFrameIntervalDuration;//最大关键帧间隔时间（也即两个关键之帧之间最大的间隔时间）
@property (nonatomic,assign)NSUInteger videoMaxKeyframeInterval;//最大关键帧间隔帧数（也即两个关键之帧之间最大的间隔帧数）【可以通过帧率和时间换算帧数】
@property (nonatomic,assign)BOOL allowFrameReordering;//默认值YES
@property (nonatomic, copy) NSString *profileLevel;//对于编码流指定配置和标准 .比如kVTProfileLevel_H264_Main_AutoLevel
@property (nonatomic,assign)BOOL realTime;//视频编码压缩是否是实时压缩。可设置CFBoolean或NULL.默认为NULL
// 采样率 由AVFoundation中的代理控制
// 分辨率
@property (nonatomic,assign)CommonVideoSessionPreset sessionPreset;

@property (nonatomic,assign,readonly)NSString *avsessionPreset;

@property (nonatomic,assign)BOOL landscape;

@property (nonatomic, strong) UIView *preview;//预览view 支持自定义

@property (nonatomic, assign) AVCaptureDevicePosition devicePosition;//前后摄像头 支持自定义

//文件路径处理
@property (nonatomic,copy)NSString *file;//读取文件的路径
@property (nonatomic,copy)NSString *writeFile;//写入文件的路径
@property (nonatomic,copy)NSString *convertFile;//读取的音频文件数据 转换格式后 写入的路径 自定义的。

@end
