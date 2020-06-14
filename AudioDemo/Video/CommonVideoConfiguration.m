//
//  CommonVideoConfiguration.m
//  RealTimeAVideo
//
//  Created by iLogiEMAC on 16/8/3.
//  Copyright © 2016年 zp. All rights reserved.
//

#import "CommonVideoConfiguration.h"
@import AVFoundation;

@interface CommonVideoConfiguration ()
@property (nonatomic,assign)CommonVideoSessionPreset supportPreset;
@end

@implementation CommonVideoConfiguration

+ (instancetype)defaultConfiguration
{
    CommonVideoConfiguration * configuration =  [CommonVideoConfiguration defaultConfigurationForQuality:kCommonVideoQuality_Default];
    return configuration;
}

+ (instancetype)defaultConfigurationForQuality:(CommonVideoQuality)quality
{
    CommonVideoConfiguration * configuration =  [CommonVideoConfiguration defaultConfigurationForQuality:quality landscape:NO];
    return configuration;
}

+ (instancetype)defaultConfigurationForQuality:(CommonVideoQuality)quality landscape:(BOOL)landscape
{
    CommonVideoConfiguration * configuration =  [CommonVideoConfiguration new];
    
    //分辨率、码流(码率)、帧率
    NSUInteger sessionPreset = 0,
    videoBitRate = 0 ,videoMaxBitRate = 0, videoMinBitRate = 0,
    videoFrameRate = 0,videoMaxFrameRate = 0, videoMinFrameRate = 0;
    
    CGSize videoSize = CGSizeZero;
    switch (quality) {
        case kCommonVideoQuality_Common_Low:
        {
            sessionPreset = kCommonVideoSessionPreset640x480;
            videoBitRate =  500 * 1000;
            videoMaxBitRate = 800 * 1000;
            videoMinBitRate = 500 * 1000;
            videoFrameRate = 15;
            videoMaxFrameRate = 30;
            videoMinFrameRate = 15;
            videoSize = CGSizeMake(480, 640);
        }
            break;
        case kCommonVideoQuality_Common_Medium:
        {
            sessionPreset = kCommonVideoSessionPreset640x480;
            videoBitRate =  800 * 1000;
            videoMaxBitRate = 800 * 1000;
            videoMinBitRate = 800 * 1000;
            videoFrameRate = 24;
            videoMaxFrameRate = 30;
            videoMinFrameRate = 24;
            videoSize = CGSizeMake(480, 640);
        }
            break;
        case kCommonVideoQuality_Common_High:
        {
            sessionPreset = kCommonVideoSessionPreset640x480;
            videoBitRate =  800 * 1000;
            videoMaxBitRate = 800 * 1000;
            videoMinBitRate = 800 * 1000;
            videoFrameRate = 30;
            videoMaxFrameRate = 30;
            videoMinFrameRate = 30;
            videoSize = CGSizeMake(480, 640);
        }
            break;
        case kCommonVideoQuality_Standard_Low:
        {
            sessionPreset = kCommonVideoSessionPreset960x540;
            videoBitRate =  800 * 1000;
            videoMaxBitRate = 800 * 1000;
            videoMinBitRate = 800 * 1000;
            videoFrameRate = 15;
            videoMaxFrameRate = 30;
            videoMinFrameRate = 15;
            videoSize = CGSizeMake(540, 960);
            
        }
            break;
        case kCommonVideoQuality_Standard_Medium:
        {
            sessionPreset = kCommonVideoSessionPreset960x540;
            videoBitRate =  800 * 1000;
            videoMaxBitRate = 800 * 1000;
            videoMinBitRate = 800 * 1000;
            videoFrameRate = 24;
            videoMaxFrameRate = 30;
            videoMinFrameRate = 24;
            videoSize = CGSizeMake(540, 960);
        }
            break;
        case kCommonVideoQuality_Standard_Hight:
        {
            sessionPreset = kCommonVideoSessionPreset960x540;
            videoBitRate =  800 * 1000;
            videoMaxBitRate = 800 * 1000;
            videoMinBitRate = 800 * 1000;
            videoFrameRate = 30;
            videoMaxFrameRate = 30;
            videoMinFrameRate = 30;
            videoSize = CGSizeMake(540, 960);
        }
            break;
        case kCommonVideoQuality_HD_Low:
        {
            sessionPreset = kCommonVideoSessionPreset1280x720;
            videoBitRate =  1000 * 1000;
            videoMaxBitRate = 1000 * 1000;
            videoMinBitRate = 1000 * 1000;
            videoFrameRate = 15;
            videoMaxFrameRate = 30;
            videoMinFrameRate = 15;
            videoSize = CGSizeMake(720, 1280);
        }
            break;
        case kCommonVideoQuality_HD_Medium:
        {
            sessionPreset = kCommonVideoSessionPreset1280x720;
            videoBitRate =  1200 * 1000;
            videoMaxBitRate = 1200 * 1000;
            videoMinBitRate = 1200 * 1000;
            videoFrameRate = 24;
            videoMaxFrameRate = 30;
            videoMinFrameRate = 24;
            videoSize = CGSizeMake(720, 1280);
        }
            break;
        case kCommonVideoQuality_HD_Hight:
        {
            sessionPreset = kCommonVideoSessionPreset1280x720;
            videoBitRate =  1200 * 1000;
            videoMaxBitRate = 1200 * 1000;
            videoMinBitRate = 1200 * 1000;
            videoFrameRate = 30;
            videoMaxFrameRate = 30;
            videoMinFrameRate = 30;
            videoSize = CGSizeMake(720, 1280);
        }
            break;
        case kCommonVideoQuality_FHD_Low:
        {
            sessionPreset = kCommonVideoSessionPreset1920x1080;
            videoBitRate =  1500 * 1000;
            videoMaxBitRate = 1500 * 1000;
            videoMinBitRate = 1500 * 1000;
            videoFrameRate = 15;
            videoMaxFrameRate = 30;
            videoMinFrameRate = 15;
            videoSize = CGSizeMake(1080, 1920);
        }
            break;
        case kCommonVideoQuality_FHD_Medium:
        {
            sessionPreset = kCommonVideoSessionPreset1920x1080;
            videoBitRate =  1500 * 1000;
            videoMaxBitRate = 1500 * 1000;
            videoMinBitRate = 1500 * 1000;
            videoFrameRate = 24;
            videoMaxFrameRate = 30;
            videoMinFrameRate = 24;
            videoSize = CGSizeMake(1080, 1920);
        }
            break;
        case kCommonVideoQuality_FHD_Hight:
        {
            sessionPreset = kCommonVideoSessionPreset1920x1080;
            videoBitRate =  1500 * 1000;
            videoMaxBitRate = 1500 * 1000;
            videoMinBitRate = 1500 * 1000;
            videoFrameRate = 30;
            videoMaxFrameRate = 30;
            videoMinFrameRate = 30;
            videoSize = CGSizeMake(1080, 1920);
        }
            break;
    }

    configuration.sessionPreset = [configuration supportSessionPreset:sessionPreset];
    configuration.videoBitRate =  videoBitRate;
    configuration.videoMaxBitRate = videoMaxBitRate;
    configuration.videoMinBitRate = videoMinBitRate;
    configuration.videoFrameRate = videoFrameRate;
    configuration.videoMaxFrameRate = videoMaxFrameRate;
    configuration.videoMinFrameRate = videoMinFrameRate;
    configuration.videoMaxKeyFrameIntervalDuration = 2;
    configuration.videoMaxKeyframeInterval = videoFrameRate * configuration.videoMaxKeyFrameIntervalDuration;
    configuration.allowFrameReordering = YES;
    configuration.profileLevel = (__bridge NSString *)kVTProfileLevel_H264_Main_AutoLevel;
    configuration.realTime = YES;
    configuration.devicePosition = AVCaptureDevicePositionBack;
    configuration.videoSize = videoSize;
    configuration.landscape = landscape;
    return configuration;
}

#pragma mark supportSessionPreset 递归处理直到返回满足的分辨率设置
- (CommonVideoSessionPreset)supportSessionPreset:(CommonVideoSessionPreset)sessionPreset
{
    NSString * avSessionPreset = [self avsessionPreset:sessionPreset];
    AVCaptureSession * session = [[AVCaptureSession alloc]init];
    
    switch (sessionPreset) {
        case kCommonVideoSessionPreset640x480:{
            break;
        }
        case kCommonVideoSessionPreset960x540:{
            if (![session canSetSessionPreset:avSessionPreset]) {
                sessionPreset = [self supportSessionPreset:kCommonVideoSessionPreset640x480];
            }
            break;
        }
        case kCommonVideoSessionPreset1280x720:{
            if (![session canSetSessionPreset:avSessionPreset]) {
                sessionPreset = [self supportSessionPreset:kCommonVideoSessionPreset960x540];
            }
            break;
        }
        case kCommonVideoSessionPreset1920x1080:{
            if (![session canSetSessionPreset:avSessionPreset]) {
                sessionPreset = [self supportSessionPreset:kCommonVideoSessionPreset1280x720];
            }
            break;
        }
        default:
            sessionPreset = kCommonVideoSessionPreset640x480;
    }
    
    return sessionPreset;
}

- (NSString *)avsessionPreset:(CommonVideoSessionPreset)sessionPreset{
    NSString * avSessionPreset = nil;
    switch (self.sessionPreset) {
        case kCommonVideoSessionPreset640x480:{
            avSessionPreset = AVCaptureSessionPreset640x480;
            break;
        }
        case kCommonVideoSessionPreset960x540:{
            avSessionPreset = AVCaptureSessionPresetiFrame960x540;
            break;
        }
        case kCommonVideoSessionPreset1280x720:{
            avSessionPreset = AVCaptureSessionPreset1280x720;
            break;
        }
        case kCommonVideoSessionPreset1920x1080:{
            avSessionPreset = AVCaptureSessionPreset1920x1080;
            break;
        }
        default:
            avSessionPreset = AVCaptureSessionPreset640x480;
    }
    return avSessionPreset;
}

- (NSString *)avsessionPreset {
    return [self avsessionPreset:self.sessionPreset];
}

#pragma mark tool
#pragma mark 文件路径处理
- (NSString *)file
{
    if (!_file) {
        NSString *file = [CacheHelper pathForCommonFile:[self.class fileName:CommonFileTypeRead] withType:0];
        _file = file;
    }
    return _file;
}

- (NSString *)writeFile {
    if (!_writeFile) {
        NSString *file = [CacheHelper pathForCommonFile:[self.class fileName:CommonFileTypeWrite] withType:0];
        _writeFile = file;
    }
    return _writeFile;
}

- (NSString *)convertFile
{
    if (!_convertFile) {
        NSString *file = [CacheHelper pathForCommonFile:[self.class fileName:CommonFileTypeConvert] withType:0];
        _convertFile = file;
    }
    return _convertFile;
}

+ (NSString *)fileName:(CommonFileType)type {
    NSMutableString *strM = [NSMutableString stringWithFormat:@"%@",NSStringFromClass(self.class)];
    switch (type) {
        case CommonFileTypeRead:
        {
            break;
        }
        case CommonFileTypeWrite:
        {
            [strM appendString:@"_write"];
            break;
        }
        case CommonFileTypeConvert:
        {
            [strM appendString:@"_convert"];
            break;
        }
        default:
            break;
    }
    [strM appendString:@".pcm"];
    return strM;
}

@end
