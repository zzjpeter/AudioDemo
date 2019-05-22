//
//  CommonConstant.h
//  
//
//  Created by 朱志佳 on 2019/5/17.
//

#ifndef CommonConstant_h
#define CommonConstant_h

static inline BOOL IsEmpty(id thing) {
    return thing == nil || thing == NULL
    || [thing isEqual:[NSNull null]]
    || ([thing respondsToSelector:@selector(length)]
        && [(NSData *)thing length] == 0)
    || ([thing respondsToSelector:@selector(count)]
        && [(NSArray *)thing count] == 0);
}

static inline BOOL IsEmptyOrNull(NSString *str) {
    if (![str isKindOfClass:[NSString class]]) {
        return IsEmpty(str);
    }
    
    if ([str isEqualToString:@"<null>"]) {
        return YES;
    } else {
        NSString *trimedString = [str stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        return trimedString.length == 0;
    }
}

static inline BOOL IsOutOfArrayCount(NSInteger index, NSArray *array) {
    if (IsEmpty(array)) return YES;
    return index < 0 || index >= array.count;
}


#endif /* CommonConstant_h */
