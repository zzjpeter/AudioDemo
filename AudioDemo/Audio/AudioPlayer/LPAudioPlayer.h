//
//  LPAudioPlayer.h
//  LesParkExplore
//
//  Created by cgh on 2018/11/13.
//

#import <Foundation/Foundation.h>
#import "ZHeader.h"

@interface AudioModel : NSObject

@property (nonatomic,copy)NSString *filePath;
@property (nonatomic,copy)NSString *fileName;
@property (nonatomic,copy)NSString *type;

@end

@interface LPAudioPlayer : NSObject

+ (instancetype)sharedAudioPlayer;

/** 播放背景音乐 */
- (void)playBackGroundAudioWithAudioModel:(AudioModel *)audioModel;

- (void)replayBackGroundAudio;

/** 播放按钮点击音效, 调用会立刻停止正在播放的上一个按钮点击音, 参数规则同上 */
- (void)playClickAudioWithAudioModel:(AudioModel *)audioModel;

/** 播放结果音效,按钮播放 调用及参数规则同上*/
- (void)playResultAudioWithAudioModel:(AudioModel *)audioModel;

- (void)stopBackGroundPlayer;

- (void)stopClickPlayer;

- (void)stopResultPlayer;

- (void)stopAllAudioPlayer;

- (BOOL)backPlayerIsPlaying;

- (void)enterToBack;

- (void)becomeFront;

@end
