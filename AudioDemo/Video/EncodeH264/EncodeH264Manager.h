//
//  EncodeH264Manager.h
//  AudioDemo
//
//  Created by 朱志佳 on 2019/5/22.
//  Copyright © 2019 朱志佳. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <VideoToolbox/VideoToolbox.h>
#import "CommonVideoConfiguration.h"
#import "ZHeader.h"

NS_ASSUME_NONNULL_BEGIN

/*
 1.将CVPixelBuffer使用VTCompressionSession进行数据流的硬编码。
 
 (1)初始化VTCompressionSession
 
 VT_EXPORT OSStatus
 VTCompressionSessionCreate(
 CM_NULLABLE CFAllocatorRef                            allocator,
 int32_t                                                width,
 int32_t                                                height,
 CMVideoCodecType                                    codecType,
 CM_NULLABLE CFDictionaryRef                            encoderSpecification,
 CM_NULLABLE CFDictionaryRef                            sourceImageBufferAttributes,
 CM_NULLABLE CFAllocatorRef                            compressedDataAllocator,
 CM_NULLABLE VTCompressionOutputCallback                outputCallback,
 void * CM_NULLABLE                                    outputCallbackRefCon,
 CM_RETURNS_RETAINED_PARAMETER CM_NULLABLE VTCompressionSessionRef * CM_NONNULL compressionSessionOut)
 __OSX_AVAILABLE_STARTING(__MAC_10_8, __IPHONE_8_0);
 
 VTCompressionSession的初始化参数说明:
 
 allocator:分配器,设置NULL为默认分配
 width: 宽
 height: 高
 codecType: 编码类型,如kCMVideoCodecType_H264
 encoderSpecification: 编码规范。设置NULL由videoToolbox自己选择
 sourceImageBufferAttributes: 源像素缓冲区属性.设置NULL不让videToolbox创建,而自己创建
 compressedDataAllocator: 压缩数据分配器.设置NULL,默认的分配
 outputCallback: 当VTCompressionSessionEncodeFrame被调用压缩一次后会被异步调用.注:当你设置NULL的时候,你需要调用VTCompressionSessionEncodeFrameWithOutputHandler方法进行压缩帧处理,支持iOS9.0以上
 outputCallbackRefCon: 回调客户定义的参考值.
 compressionSessionOut: 压缩会话变量。
 
 (2)配置VTCompressionSession

 使用VTSessionSetProperty()调用进行配置compression。
 kVTCompressionPropertyKey_AllowFrameReordering: 允许帧重新排序.默认为true
 kVTCompressionPropertyKey_AverageBitRate: 设置需要的平均编码率
 kVTCompressionPropertyKey_H264EntropyMode：H264的熵编码模式。有两种模式:一种基于上下文的二进制算数编码CABAC和可变长编码VLC.在slice层之上（picture和sequence）使用定长或变长的二进制编码，slice层及其以下使用VLC或CABAC.详情请参考
 kVTCompressionPropertyKey_RealTime: 视频编码压缩是否是实时压缩。可设置CFBoolean或NULL.默认为NULL
 kVTCompressionPropertyKey_ProfileLevel: 对于编码流指定配置和标准 .比如kVTProfileLevel_H264_Main_AutoLevel
 配置过VTCompressionSession后,可以可选的调用VTCompressionSessionPrepareToEncodeFrames进行准备工作编码帧。
 
 (3)开始硬编码流入的数据
 
 使用VTCompressionSessionEncodeFrame方法进行编码.当编码结束后调用outputCallback回调函数。

 VT_EXPORT OSStatus
 VTCompressionSessionEncodeFrame(
     CM_NONNULL VTCompressionSessionRef    session,
     CM_NONNULL CVImageBufferRef            imageBuffer,
     CMTime                                presentationTimeStamp,
     CMTime                                duration, // may be kCMTimeInvalid
     CM_NULLABLE CFDictionaryRef            frameProperties,
     void * CM_NULLABLE                    sourceFrameRefCon,
     VTEncodeInfoFlags * CM_NULLABLE        infoFlagsOut )
     __OSX_AVAILABLE_STARTING(__MAC_10_8, __IPHONE_8_0);
 presentationTimeStamp： 获取到的这个sample buffer数据的展示时间戳。每一个传给这个session的时间戳都要大于前一个展示时间戳.
 duration: 对于获取到sample buffer数据,这个帧的展示时间.如果没有时间信息,可设置kCMTimeInvalid.
 frameProperties: 包含这个帧的属性.帧的改变会影响后边的编码帧.
 sourceFrameRefCon: 回调函数会引用你设置的这个帧的参考值.
 infoFlagsOut:指向一个VTEncodeInfoFlags来接受一个编码操作.如果使用异步运行,kVTEncodeInfo_Asynchronous被设置；同步运行,kVTEncodeInfo_FrameDropped被设置；设置NULL为不想接受这个信息.
 
(4)执行VTCompressionOutputCallback回调函数
 
 typedef void (*VTCompressionOutputCallback)(
         void * CM_NULLABLE outputCallbackRefCon,
         void * CM_NULLABLE sourceFrameRefCon,
         OSStatus status,
         VTEncodeInfoFlags infoFlags,
         CM_NULLABLE CMSampleBufferRef sampleBuffer );
 outputCallbackRefCon: 回调函数的参考值
 sourceFrameRefCon: VTCompressionSessionEncodeFrame函数中设置的帧的参考值
 status: 压缩的成功为noErr,如失败有错误码
 infoFlags: 包含编码操作的信息标识
 sampleBuffer: 如果压缩成功或者帧不丢失,则包含这个已压缩的数据CMSampleBuffer,否则为NULL
 
 
 */

@interface EncodeH264Manager : NSObject

SingleInterface(manager)

@property (nonatomic, strong) CommonVideoConfiguration *configuration;

- (void)startWithConfiguration:(CommonVideoConfiguration *)configuration;
- (void)stop;

@end

NS_ASSUME_NONNULL_END

