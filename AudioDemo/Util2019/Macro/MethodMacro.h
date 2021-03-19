//
//  MethodMacro.h
//  TooToo
//
//  Created by liuning on 15/12/21.
//  Copyright © 2015年 MoHao. All rights reserved.
//

#ifndef MethodMacro_h
#define MethodMacro_h
 
/*安全解析方法*/ 

#define SafeGetBOOLValue(object) (![object isKindOfClass:[NSNull class]]?([object respondsToSelector:@selector(boolValue)]?[object boolValue]:FALSE):FALSE)
#define SafeGetStringValue(object) ((object!=nil && ![object isKindOfClass:[NSNull class]])?([object isKindOfClass:[NSString class]]?object:([object respondsToSelector:@selector(stringValue)]?[object performSelector:@selector(stringValue)]:@"")):@"")
#define SafeGetArrayValue(object) ([object isKindOfClass:[NSArray class]]?object:@[])
#define SafeGetDictionaryValue(object) ([object isKindOfClass:[NSDictionary class]]?object:@{})
#define SafeGetDateValue(object) ([object isKindOfClass:[NSDate class]]?object:nil)
#define SafeGetFloatValue(object) ((object!=nil && ![object isKindOfClass:[NSNull class]])?([object respondsToSelector:@selector(floatValue)]?[object floatValue]:0.0):0.0)
#define SafeGetDoubleValue(object) ((object!=nil && ![object isKindOfClass:[NSNull class]])?([object respondsToSelector:@selector(doubleValue)]?[object doubleValue]:0.0):0.0)
#define SafeGetIntValue(object) ((object!=nil && ![object isKindOfClass:[NSNull class]])?([object respondsToSelector:@selector(intValue)]?[object intValue]:0):0)
#define SafeString(object) ((object!=nil && ![object isKindOfClass:[NSNull class]])?object:@"")

#define PriceString(object) [NSString stringWithFormat:@"%.2f",SafeGetFloatValue(object)]
#define SafeGetPriceString(object) [NSString stringWithFormat:@"%g",SafeGetFloatValue(PriceString(object))]

/*类型转换方法*/

//角度转弧度
#define DEGREES_TO_RADIANS(__ANGLE__) ((__ANGLE__) / 180.0 * M_PI)
//弧度转角度
#define RADIANS_TO_DEGREES(__ANGLE__) ((__ANGLE__) / M_PI * 180.0)
//整型转字符串
#define IntToString(intValue) [NSString stringWithFormat:@"%ld",(long)intValue]

//日志输出宏
#ifdef DEBUG
#define FbeeLog(format, ...) printf("[%s] %s [第%d行] ----- %s\n", __TIME__, __FUNCTION__, __LINE__, [[NSString stringWithFormat:format, ## __VA_ARGS__] UTF8String])
#else
#define FbeeLog(format, ...)
#endif

#ifdef DEBUG
#define ZLog(...)//ZLog(fmt, ...) NSLog((@"%s [Line %d] " fmt), __PRETTY_FUNCTION__, __LINE__, ## __VA_ARGS__);
#else
#define ZLog(...)
#endif

#define ZWeakSelf __weak typeof(self) weakSelf = self;

/*----------------------------------------------------------------------------------
 *                      Block/Block-weak-strong避免循环引用                                *
 ----------------------------------------------------------------------------------*/
#define ZBLOCK_EXEC(block, ...) if (block) { block(__VA_ARGS__); }

//#define ZWeakObj(o) autoreleasepool{} __weak typeof(o) o##Weak = o;
//#define ZStrongObj(o) autoreleasepool{} __strong typeof(o) o = o##Weak;

// 避免宏循环引用
#ifndef ZWeakObj
#if DEBUG
#if __has_feature(objc_arc)
#define ZWeakObj(object) autoreleasepool{} __weak __typeof__(object) weak##_##object = object;
#else
#define ZWeakObj(object) autoreleasepool{} __block __typeof__(object) block##_##object = object;
#endif
#else
#if __has_feature(objc_arc)
#define ZWeakObj(object) try{} @finally{} {} __weak __typeof__(object) weak##_##object = object;
#else
#define ZWeakObj(object) try{} @finally{} {} __block __typeof__(object) block##_##object = object;
#endif
#endif
#endif

#ifndef ZStrongObj
#if DEBUG
#if __has_feature(objc_arc)
#define ZStrongObj(object) autoreleasepool{} __typeof__(object) object = weak##_##object;
#else
#define ZStrongObj(object) autoreleasepool{} __typeof__(object) object = block##_##object;
#endif
#else
#if __has_feature(objc_arc)
#define ZStrongObj(object) try{} @finally{} __typeof__(object) object = weak##_##object;
#else
#define ZStrongObj(object) try{} @finally{} __typeof__(object) object = block##_##object;
#endif
#endif
#endif

/**
 *     其他宏
 */

//block的调用
#define Call(block,...) \
!block?:block(__VA_ARGS__);
//block的调用，并带有返回值
#define CallRerurn(block,failReturnValue,...) \
block?(block(__VA_ARGS__)):(failReturnValue)

//防止block的强硬用循环相关
#define Weak(arg) \
__weak typeof(arg) wArg = arg;
#define Strong(arg) \
__strong typeof(wArg) arg = wArg;

#define WeakSelf \
Weak(self)
#define StrongSelf \
Strong(self)

//常用判断处理方法
#import "NSObject+Util.h"
#define AS(clz, value) ([clz qn_cast:(value)warnOnFailure:YES filepath:__FILE__ line:__LINE__])
#define CLASS_NAME(clz) (NSStringFromClass([clz qn_class]))
#define CLASS(clz) ([clz qn_class])
#define IS(clz, value) ([value isKindOfClass:CLASS(clz)])
#define IS_NOT(clz, value) (![value isKindOfClass:CLASS(clz)])

#define _UD (NSUserDefaults.standardUserDefaults)

#import "NSArray+Safe.h"

#import "NSString+EncodeUrl.h"

#import "ZSingleton.h"
#import "CacheManager.h"
#import "JumpManager.h"

#endif /* MethodMacro_h */
