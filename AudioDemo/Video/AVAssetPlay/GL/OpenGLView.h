//
//  OpenGLView.h
//  AudioDemo
//
//  Created by 朱志佳 on 2019/5/31.
//  Copyright © 2019 朱志佳. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <OpenGLES/ES2/gl.h>
#import <OpenGLES/ES2/glext.h>

NS_ASSUME_NONNULL_BEGIN

@interface OpenGLView : UIView

@property (nonatomic , assign) BOOL isFullYUVRange;

- (void)setupGL;
- (void)displayPixelBuffer:(CVPixelBufferRef)pixelBuffer;

@end

NS_ASSUME_NONNULL_END
