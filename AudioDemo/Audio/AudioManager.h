//
//  AudioManager.h
//  AudioDemo
//
//  Created by 朱志佳 on 2019/5/5.
//  Copyright © 2019 朱志佳. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface AudioManager : NSObject

+(instancetype)sharedAudioManager;

- (void)startRecoder;
- (void)stopRecoder;

@end

NS_ASSUME_NONNULL_END
