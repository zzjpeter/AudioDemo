//
//  VerticalLabel.h
//  LabelDemo
//
//  Created by wangergang on 2016/12/7.
//  Copyright © 2016年 MYCompangName. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
    
    VerticalAlignmentMiddle = 0, //default
    VerticalAlignmentTop,
    VerticalAlignmentBottom,
    
} VerticalAlignment;

@interface VerticalLabel : UILabel {

@private
    VerticalAlignment _verticalAlignment;
}

@property (nonatomic) VerticalAlignment verticalAlignment;

@end
