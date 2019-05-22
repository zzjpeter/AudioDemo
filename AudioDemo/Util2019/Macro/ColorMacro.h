//
//  ColorMacro.h
//  TooToo
//
//  Created by liuning on 15/12/21.
//  Copyright © 2015年 MoHao. All rights reserved.
//

#ifndef ColorMacro_h
#define ColorMacro_h

//16进制转RGB
#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]
//16进制转RGB加透明度
#define UIColorFromRGBA(rgbValue,a) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:a]

#endif /* ColorMacro_h */
