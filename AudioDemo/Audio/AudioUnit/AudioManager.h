//
//  AudioManager.h
//  AudioDemo
//
//  Created by 朱志佳 on 2019/5/5.
//  Copyright © 2019 朱志佳. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AVHeader.h"
NS_ASSUME_NONNULL_BEGIN
/**
 Audio Unit播放PCM文件 详解
 https://www.jianshu.com/p/57dd36e704be
 
 总结如下：数据流走向。输入设备(麦克风)->element1->应用(application)->element0->输出设备(扬声器)
 
 Audio Unit 是一个处理单元，Remote I/O Unit是较常用的一个Unit。
 Audio Unit以pull的模式工作，output的unit在start的时候会从input bus加载samples；这个input bus可以是上一个unit，也可以是其他指定好格式的来源。每次加载，就是一次 rendering cycle。iOS不支持加载第三方的audio unit，只能加载iOS提供的unit。
 demo中用到的是Remote I/O Unit，类型是kAudioUnitSubType_RemoteIO。
 Remote I/O Unit在input和output的设备之间建立连接，用较低的延迟处理声音信息。从设备输入的hardware format音频流，转成application设置的format，处理完再以application的format传给输出的设备。
 
 图中Element 也叫 bus；
 Element 0的有一半是对着扬声器，是output bus；Element 1有一半对着麦克风，是input bus；
 音频流从输入域（input scope）输入， 从输出域（output scope）输出；

 AudioUnit的属性中，最重要的是stream format，包括采样率、packet information和编码类型；AudioStreamBasicDescriptions (ASBD) 是CoreAudio通用的流结构描述文件。
 比如说，以下是输出到扬声器的音频格式：
 (AudioStreamBasicDescription) outputFormat = {
 mSampleRate = 0
 mFormatID = 1819304813
 mFormatFlags = 41
 mBytesPerPacket = 4
 mFramesPerPacket = 1
 mBytesPerFrame = 4
 mChannelsPerFrame = 2
 mBitsPerChannel = 32
 mReserved = 0
 }
 
 AudioUnitGetProperty 和 AudioUnitSetProperty  可以获取和设置AudioUnit属性；
 AudioUnitGetPropertyInfo 用于在设置或者读取属性之前，获取属性可以修改的大小和是否可写，避免error的产生；
 AudioUnitInitialize 是初始化AudioUnit，需要在设置好absd之后调用；初始化是一个耗时的操作，需要分配buffer、申请系统资源等；
 kAudioUnitProperty_SetRenderCallback 用来设置回调，AURenderCallbackStruct是回调的结构体；
 
AudioBufferList是音频的缓存数据结构，具体如下：
 struct AudioBufferList
 {
 UInt32      mNumberBuffers;
 AudioBuffer mBuffers[1]; // this is a variable length array of mNumberBuffers elements
 };
 
 struct AudioBuffer
 {
 UInt32              mNumberChannels;
 UInt32              mDataByteSize;
 void* __nullable    mData;
 };
 mNumberBuffers： AudioBuffer的数量
 mBuffers：AudioBuffer的指针数组，数组长度等于mNumberBuffers
 AudioBuffer：mNumberChannels是声道数，mDataByteSize是buffer大小，mData 音频数据的buffer
 
 具体细节
 1、设置AVAudioSession，因为demo只用到播放功能，故设置AVAudioSession为AVAudioSessionCategoryPlayback；
 2、初始化AudioComponentDescription，然后再调用AudioComponentFindNext得到AudioComponent，最后调用AudioComponentInstanceNew初始化，得到AudioUnit；
 3、初始化AudioBufferList，mNumberBuffers和mNumberChannels设置为1，需要注意的是mData，初始化mData的时候需要手动分配内存；
 4、设置AudioUnit的output bus的输入格式（AudioStreamBasicDescription)
 Sample Rate:              44100
 Format ID:                 lpcm
 Format Flags:                 4
 Bytes per Packet:             2
 Frames per Packet:            1
 Bytes per Frame:              2
 Channels per Frame:           1
 Bits per Channel:            16
 
5、设置AudioUnit的回调函数，注意是OUTPUT_BUS的输入域的回调；调用AudioUnitInitialize初始化AudioUnit；
 
 6、调用AudioOutputUnitStart开始，AudioUnit会调用之前设置的PlayCallback，在回调函数中把音频数据赋值给AudioBufferList；
 */
@class AudioManager;
@protocol AudioManagerDelegate <NSObject>

- (void)onPlayToEnd:(AudioManager *)audioManager;

@end

@interface AudioManager : NSObject

@property (nonatomic, weak) id<AudioManagerDelegate> delegate;

SingleInterface(manager)
@property (nonatomic,copy)NSString *file;//写入 或者 读取文件的路径
@property (nonatomic,assign)BOOL isReadNeedConvert;//音频播放是否需要格式转换（注意：audio unit 默认是只支持pcm数据音频文件，需要播放其他格式数据文件如.mp3的就需要 转码数据格式convert 到pcm）
@property (nonatomic,copy)NSString *convertFile;//读取的音频文件数据 转换格式后 写入的路径 自定义的。
//录制和播放 通过audioSessionCategory 参数设置
- (void)startWithAVAudioSessionCategory:(AVAudioSessionCategory)audioSessionCategory;
- (void)start;
- (void)stop;
- (void)finished;

@end

NS_ASSUME_NONNULL_END
