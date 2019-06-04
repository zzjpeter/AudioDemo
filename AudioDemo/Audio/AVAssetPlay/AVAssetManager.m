//
//  AVAssetManager.m
//  AudioDemo
//
//  Created by 朱志佳 on 2019/6/4.
//  Copyright © 2019 朱志佳. All rights reserved.
//

#import "AVAssetManager.h"
#import <AssetsLibrary/ALAssetsLibrary.h>
#import "AudioSampleManager.h"
#import "NSArray+Safe.h"

@interface AVAssetManager ()<AudioManagerDelegate>

// avfoudation
@property (nonatomic , strong) AVAsset *mAsset;
@property (nonatomic , strong) AVAssetReader *mReader;
@property (nonatomic , strong) AVAssetReaderTrackOutput *mReaderAudioTrackOutput;

@property (nonatomic, assign) CMBlockBufferRef blockBufferOut;
@property (nonatomic, assign) AudioBufferList audioBufferList;

@property (nonatomic , strong) AVAssetReaderTrackOutput *mReaderVideoTrackOutput;
@property (nonatomic , strong) CADisplayLink *mDisplayLink;

// 时间戳
@property (nonatomic, assign) long mAudioTimeStamp;
@property (nonatomic, assign) long mVideoTimeStamp;


@end

@implementation AVAssetManager

SingleImplementation(manager)

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self initialize];
    }
    return self;
}

- (void)initialize
{
    CADisplayLink *mDisplayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(displayLinkCallback:)];
    self.mDisplayLink = mDisplayLink;
    [mDisplayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    [mDisplayLink setPaused:YES];
    
    [self loadAsset];
}

- (void)loadAsset {
    
    NSURL *url = [[NSBundle mainBundle] URLForResource:@"test.mov" withExtension:nil];
    
    NSDictionary *inputOptions = @{
                                   AVURLAssetPreferPreciseDurationAndTimingKey : @(YES)
                                   };
    AVURLAsset *inputAsset = [[AVURLAsset alloc] initWithURL:url options:inputOptions];
    @weakify(self)
    [inputAsset loadValuesAsynchronouslyForKeys:@[@"tracks"] completionHandler:^{
        @strongify(self)
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSError *error = nil;
            AVKeyValueStatus trackStatus = [inputAsset statusOfValueForKey:@"tracks" error:&error];
            if (trackStatus != AVKeyValueStatusLoaded) {
                NSLog(@"error %@", error);
                return;
            }
            self.mAsset = inputAsset;
            self.hasLoadAssetSuccess = YES;
            if (self.loadAssetSuccess) {
                self.loadAssetSuccess(YES);
            }
        });
    }];
    
}

- (void)start
{
    self.mReader = [self createAssetReader];
    if ([self.mReader startReading] == NO)
    {
        NSLog(@"Error reading from file at URL: %@", self.mAsset);
        return;
    }
    NSLog(@"Start reading success.");
    
    [AudioSampleManager sharedmanager].delegate = self;
    [AudioSampleManager sharedmanager].isPlayBackDataFromDelegate = YES;
    [[AudioSampleManager sharedmanager] startWithAVAudioSessionCategory:AVAudioSessionCategoryPlayback];
    
    [self.mDisplayLink setPaused:NO];
    self.mAudioTimeStamp = self.mVideoTimeStamp = 0;
}

- (void)stop
{
    self.mDisplayLink.paused = YES;
    [[AudioSampleManager sharedmanager] stop];
}

#pragma mark assetReader
- (AVAssetReader*)createAssetReader
{
    NSError *error = nil;
    AVAssetReader *assetReader = [AVAssetReader assetReaderWithAsset:self.mAsset error:&error];
    [self initAudioAsset:assetReader];
    [self initVideoAsset:assetReader];
    
    return assetReader;
}
#pragma mark assetReader 1.mReaderAudioTrackOutput
- (void)initAudioAsset:(AVAssetReader*)assetReader
{
    NSDictionary *outputSettings = @{
                                     AVFormatIDKey : @(kAudioFormatLinearPCM),
                                     AVLinearPCMBitDepthKey : @(16),
                                     AVLinearPCMIsBigEndianKey : @(NO),
                                     AVLinearPCMIsFloatKey : @(NO),
                                     AVLinearPCMIsNonInterleaved : @(YES),
                                     AVSampleRateKey : @(44100.0),
                                     AVNumberOfChannelsKey : @(1),
                                     };
    NSArray<AVAssetTrack *> *audioTracks = [self.mAsset tracksWithMediaType:AVMediaTypeAudio];
    self.mReaderAudioTrackOutput = [AVAssetReaderTrackOutput assetReaderTrackOutputWithTrack:audioTracks.firstObject outputSettings:outputSettings];
    self.mReaderAudioTrackOutput.alwaysCopiesSampleData = NO;
    if ([assetReader canAddOutput:self.mReaderAudioTrackOutput]) {
        [assetReader addOutput:self.mReaderAudioTrackOutput];
    }else
    {
        NSLog(@"no canAddOutput##%@",self.mReaderAudioTrackOutput);
    }
    
    NSArray *formatDesc = audioTracks.firstObject.formatDescriptions;
    for (NSInteger i = 0; i < formatDesc.count; i++) {
        CMAudioFormatDescriptionRef item = (__bridge_retained CMAudioFormatDescriptionRef)[formatDesc safeObjectAtIndex:i];
        const AudioStreamBasicDescription *fmtDesc = CMAudioFormatDescriptionGetStreamBasicDescription(item);
        if (fmtDesc) {
            [self printAudioStreamBasicDescription:*fmtDesc];
        }
        CFRelease(item);
    }
}
#pragma mark assetReader 2.mReaderVideoTrackOutput
- (void)initVideoAsset:(AVAssetReader*)assetReader
{
    NSDictionary *outputSettings = @{
                                     (id)kCVPixelBufferPixelFormatTypeKey : @(kCVPixelFormatType_420YpCbCr8BiPlanarFullRange)
                                     };
    NSArray<AVAssetTrack *> *videoTracks = [self.mAsset tracksWithMediaType:AVMediaTypeVideo];
    self.mReaderVideoTrackOutput = [AVAssetReaderTrackOutput assetReaderTrackOutputWithTrack:videoTracks.firstObject outputSettings:outputSettings];
    self.mReaderVideoTrackOutput.alwaysCopiesSampleData = NO;
    
    if ([assetReader canAddOutput:self.mReaderVideoTrackOutput]) {
        [assetReader addOutput:self.mReaderVideoTrackOutput];
    }else
    {
        NSLog(@"no canAddOutput##%@",self.mReaderVideoTrackOutput);
    }
}

#pragma mark -delegate audio CMSampleBufferRef to AudioBufferList
- (AudioBufferList *)onRequestAudioData
{
    CMSampleBufferRef sampleBuffer = [self.mReaderAudioTrackOutput copyNextSampleBuffer];
    size_t bufferListSizeNeededOut = 0;
    if (self.blockBufferOut != NULL) {
        CFRelease(self.blockBufferOut);
        self.blockBufferOut = NULL;
    }
    if (!sampleBuffer) {
        return NULL;
    }
    OSStatus error = CMSampleBufferGetAudioBufferListWithRetainedBlockBuffer(sampleBuffer,
                                                                             &bufferListSizeNeededOut,
                                                                             &_audioBufferList,
                                                                             sizeof(self.audioBufferList),
                                                                             kCFAllocatorSystemDefault,
                                                                             kCFAllocatorSystemDefault,
                                                                             kCMSampleBufferFlag_AudioBufferList_Assure16ByteAlignment,
                                                                             &_blockBufferOut);
    if (error) {
        NSLog(@"CMSampleBufferGetAudioBufferListWithRetainedBlockBuffer error: %d", (int)error);
    }
    
    CMTime presentationTimeStamp = CMSampleBufferGetPresentationTimeStamp(sampleBuffer);
    int timeStamp = (1000 * (int)presentationTimeStamp.value) / presentationTimeStamp.timescale;
    NSLog(@"audio timestamp %d", timeStamp);
    self.mAudioTimeStamp = timeStamp;
    
    CFRelease(sampleBuffer);
    
    return &_audioBufferList;
}

- (void)onPlayToEnd:(AudioSampleManager *)AudioSampleManager
{
    NSLog(@"%@##%@",NSStringFromClass([self class]),NSStringFromSelector(_cmd));
}

#pragma mark actions
- (void)displayLinkCallback:(CADisplayLink *)sender {
    //    if (self.mVideoTimeStamp < self.mAudioTimeStamp) {
    [self renderVideo];
    //    }
}

#pragma mark video CMSampleBufferRef to CVPixelBufferRef
- (void)renderVideo {
    CMSampleBufferRef videoSampleBuffer = [self.mReaderVideoTrackOutput copyNextSampleBuffer];
    if (!videoSampleBuffer) {
        return;
    }
    
    CVPixelBufferRef pixelBuffer = CMSampleBufferGetImageBuffer(videoSampleBuffer);
    if (pixelBuffer) {
        [self.mGLView displayPixelBuffer:pixelBuffer];
        
        CMTime presentationTimeStamp = CMSampleBufferGetPresentationTimeStamp(videoSampleBuffer);
        int timeStamp = (1000 * (int)presentationTimeStamp.value) / presentationTimeStamp.timescale;
        NSLog(@"video timestamp %d", timeStamp);
        self.mVideoTimeStamp = timeStamp;
    }
    
    CFRelease(videoSampleBuffer);
}


#pragma mark other
- (void)printAudioStreamBasicDescription:(AudioStreamBasicDescription)asbd {
    char formatID[5];
    UInt32 mFormatID = CFSwapInt32HostToBig(asbd.mFormatID);
    bcopy (&mFormatID, formatID, 4);
    formatID[4] = '\0';
    printf("Sample Rate:         %10.0f\n",  asbd.mSampleRate);
    printf("Format ID:           %10s\n",    formatID);
    printf("Format Flags:        %10X\n",    (unsigned int)asbd.mFormatFlags);
    printf("Bytes per Packet:    %10d\n",    (unsigned int)asbd.mBytesPerPacket);
    printf("Frames per Packet:   %10d\n",    (unsigned int)asbd.mFramesPerPacket);
    printf("Bytes per Frame:     %10d\n",    (unsigned int)asbd.mBytesPerFrame);
    printf("Channels per Frame:  %10d\n",    (unsigned int)asbd.mChannelsPerFrame);
    printf("Bits per Channel:    %10d\n",    (unsigned int)asbd.mBitsPerChannel);
    printf("\n");
}

@end
