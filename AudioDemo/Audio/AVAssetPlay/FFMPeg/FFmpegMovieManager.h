//
//  FFmpegMovieManager.h
//  AudioDemo
//
//  Created by 朱志佳 on 2019/6/4.
//  Copyright © 2019 朱志佳. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AVHeader.h"
NS_ASSUME_NONNULL_BEGIN

@interface FFmpegMovieManager : NSObject

SingleInterface(manager);

@property (nonatomic, copy) NSString *file;

/* 解码后的UIImage */
@property (nonatomic, strong, readonly) UIImage *currentImage;

/* 视频的frame高度 */
@property (nonatomic, assign, readonly) int sourceWidth, sourceHeight;

/* 输出图像大小。默认设置为源大小。 */
@property (nonatomic,assign) int outputWidth, outputHeight;

/* 视频的长度，秒为单位 */
@property (nonatomic, assign, readonly) double duration;

/* 视频的当前秒数 */
@property (nonatomic, assign, readonly) double currentTime;

/* 视频的帧率 */
@property (nonatomic, assign, readonly) double fps;

/* 从视频流中读取下一帧。返回假，如果没有帧读取（视频）。 */
- (BOOL)stepFrame;

/* 寻求最近的关键帧在指定的时间 */
- (void)seekTime:(double)seconds;

- (uint8_t *)getYUVdata;

- (CVPixelBufferRef)getCurrentCVPixelBuffer;

- (void)restart;
- (void)startWithPath:(NSString *)file;
- (void)start;
- (void)stop;
@end

NS_ASSUME_NONNULL_END
