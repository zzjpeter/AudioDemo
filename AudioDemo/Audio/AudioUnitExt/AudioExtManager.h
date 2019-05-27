//
//  AudioExtManager.h
//  AudioDemo
//
//  Created by 朱志佳 on 2019/5/5.
//  Copyright © 2019 朱志佳. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AVHeader.h"
NS_ASSUME_NONNULL_BEGIN

/*
 //ExtendedAudioFile播放音频
 //https://www.jianshu.com/p/f252eddbd758
 前文介绍了AudioUnit的录音/播放功能，也介绍了通过AudioConvert进行音频的转换，但是AudioConvert的API使用起来较为麻烦，除了需要调用AudioFileGetProperty获取许多信息之外，还要调用AudioConverterFillComplexBuffer进行ConvertBuffer的填充，并在其数据输入回调中调用AudioFileReadPacketData，且要考虑AudioStreamPacketDescription的赋值。
 本文尝试使用更为简单的方法 Extended Audio File Services。
 Extended Audio File Services是high-level的API，提供音频文件的读/写，是Audio File Services 和 Audio Converter Services 的结合，在AudioFile和AudioConvert的基础上提供统一的接口进行读写操作。
 
 ExtAudioFileOpenURL是新建一个ExtAudioFileRef，用于读取音频文件；
 
 ExtAudioFileWrapAudioFileID是通过一个已有的AudioFileID，创建一个ExtAudioFileRef；
 开发者必须保证在ExtAudioFileRef被销毁前，AudioFileID是处于打开的状态，并且在ExtAudioFileRef被销毁后，手动关闭AudioFileID；
 
 ExtAudioFileGetProperty 获取对应PropertyID的属性；
 
 ExtAudioFileGetProperty 获取设置PropertyID的属性；
 
 */
@class AudioExtManager;
@protocol AudioManagerDelegate <NSObject>

- (void)onPlayToEnd:(AudioExtManager *)AudioExtManager;

@end

@interface AudioExtManager : NSObject

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
- (double)getCurrentTime;
@end

NS_ASSUME_NONNULL_END
