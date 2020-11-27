//
//  ExtAudioConverter.h
//  ExtAudioConverter
//
//  Created by zhuzj on 19/4/9.
//  Copyright (c) 2019年 zhuzj. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AudioToolbox/AudioToolbox.h>
#import "Music.h"
enum BitDepth{
    BitDepth_8  = 8,
    BitDepth_16 = 16,
    BitDepth_24 = 24,
    BitDepth_32 = 32
};

//TODO:Add delegate

typedef void(^ConvertSuccess)(BOOL success, NSString *filePath);

@interface ExtAudioConverter : NSObject

//Must set
@property(nonatomic,retain)NSString* inputFile;//Absolute path
@property(nonatomic,retain)NSString* outputFile;//Absolute path

//optional
@property(nonatomic,assign)int outputSampleRate;//Default 44100.0
@property(nonatomic,assign)int outputNumberChannels;//Default 2
@property(nonatomic,assign)enum BitDepth outputBitDepth;//Default BitDepth_16
@property(nonatomic,assign)AudioFormatID outputFormatID;//Default Linear PCM
@property(nonatomic,assign)AudioFileTypeID outputFileType;//Default kAudioFileCAFType
//TODO:add bit rate parameter

+ (BOOL)convertToMp3:(NSString *)inputFile outputFile:(NSString *)outputFile convertSuccess:(ConvertSuccess)convertSuccess;

-(BOOL)convert:(ConvertSuccess)convertSuccess;

#pragma mark API
+ (void)convertDefault:(ConvertSuccess)convertSuccess inputFile:(NSString *)inputFile outputFile:(NSString *)outputFile;

+ (void)convertWithInputFile:(NSString *)inputFile
                  outputFile:(NSString *)outputFile
            outputSampleRate:(int)outputSampleRate
        outputNumberChannels:(int)outputNumberChannels
              outputBitDepth:(enum BitDepth)outputBitDepth
              outputFormatID:(AudioFormatID)outputFormatID
              outputFileType:(AudioFileTypeID)outputFileType
              convertSuccess:(ConvertSuccess)convertSuccess;

@end
