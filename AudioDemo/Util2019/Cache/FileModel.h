//
//  FileModel.h
//  ManageUtil2018
//
//  Created by 朱志佳 on 2019/8/26.
//  Copyright © 2019 zhuzj. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface FileModel : NSObject

@property (nonatomic,strong) NSMutableArray <FileModel *>*subPaths;

@property (nonatomic, assign) BOOL isDir;

@property (nonatomic,copy) NSString *fileName;

@property (nonatomic,copy) NSString *path;

@end

NS_ASSUME_NONNULL_END
