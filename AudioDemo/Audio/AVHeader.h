//
//  AVHeader.h
//  AudioDemo
//
//  Created by 朱志佳 on 2019/5/23.
//  Copyright © 2019 朱志佳. All rights reserved.
//

#ifndef AVHeader_h
#define AVHeader_h

//文件类型枚举
typedef NS_ENUM(NSUInteger, CommonFileType) {
    CommonFileTypeRead = 1,
    CommonFileTypeWrite,
    CommonFileTypeConvert,
};

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "ZHeader.h"
#import <AVFoundation/AVFoundation.h>
#import <VideoToolbox/VideoToolbox.h>
#import "CommonVideoConfiguration.h"


#endif /* AVHeader_h */
