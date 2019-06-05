//
//  LiveManager.m
//  AudioDemo
//
//  Created by 朱志佳 on 2019/6/5.
//  Copyright © 2019 朱志佳. All rights reserved.
//

#import "LiveManager.h"
#import <LFLiveKit.h>
#import "AVHeader.h"

@interface LiveManager ()

@property (nonatomic, strong) LFLiveSession *session;

@end

@implementation LiveManager

SingleImplementation(manager)

- (instancetype)init
{
    self = [super init];
    if (self) {
        
    }
    return self;
}

- (void)startWithPreView:(UIView *)preView
{
    self.session.preView = preView;
    self.session.running = YES;
    LFLiveStreamInfo *stream = [LFLiveStreamInfo new];
    stream.url = @"rtmp://172.17.44.151:1935/hls/abc";//@"rtmp://172.17.44.151:1935/rtmplive/abc";
    [self.session startLive:stream];
}

- (void)stop{
    [self.session stopLive];
}

- (void)changeOnBeaty
{
    self.session.beautyFace = !self.session.beautyFace;
}
- (void)changeOnCamera
{
    if (self.session.captureDevicePosition == AVCaptureDevicePositionBack) {
        self.session.captureDevicePosition = AVCaptureDevicePositionFront;
    }
    else {
        self.session.captureDevicePosition = AVCaptureDevicePositionBack;
    }
}

#pragma mark -setter/getter
- (LFLiveSession *)session
{
    if (!_session) {
        LFLiveSession *session = [[LFLiveSession alloc] initWithAudioConfiguration:[LFLiveAudioConfiguration defaultConfiguration] videoConfiguration:[LFLiveVideoConfiguration defaultConfiguration]];
        _session = session;
    }
    return _session;
}

#pragma mark 权限申请管理
+ (void)requestAccessForVideoCompletionHandler:(void (^)(BOOL granted))handler{
    
    AVAuthorizationStatus status = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    switch (status) {
        case AVAuthorizationStatusNotDetermined:{
            [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
                handler(granted);
            }];
            break;
        }
        case AVAuthorizationStatusAuthorized:{
            handler(YES);
            break;
        }
        case AVAuthorizationStatusDenied:
        case AVAuthorizationStatusRestricted:{
            handler(NO);
            break;
        }
        default:
            break;
    }
}

+ (void)requestAccessForAudioCompletionHandler:(void (^)(BOOL granted))handler{
    AVAuthorizationStatus status = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeAudio];
    switch (status) {
        case AVAuthorizationStatusNotDetermined:{
            [AVCaptureDevice requestAccessForMediaType:AVMediaTypeAudio completionHandler:^(BOOL granted) {
                handler(granted);
            }];
            break;
        }
        case AVAuthorizationStatusAuthorized:{
            handler(YES);
            break;
        }
        case AVAuthorizationStatusDenied:
        case AVAuthorizationStatusRestricted:{
            handler(NO);
            break;
        }
        default:
            break;
    }
}

@end
