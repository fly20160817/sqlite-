//
//  FLYModelProtocal.h
//  sqlite封装
//
//  Created by fly on 2020/5/8.
//  Copyright © 2020 fly. All rights reserved.
//

//协议

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol FLYModelProtocal <NSObject>

@required
/**
 操作模型必须实现的方法，通过这个方法获取主键信息
 
 @return 主键字符串
 */
+ (NSString *)primaryKey;


@optional

/**
 需要忽略的成员变量 (不一定每个成员变量都需要保存进数据库)
 
 @return 忽略的字段数组
 */
+ (NSArray *)ignoreColumnNames;


/**
 新字段名称 -> 旧字段名称 的映射表格
 
 @return 映射表格
 */
+ (NSDictionary *)newNameToOldNameDic;

@end

NS_ASSUME_NONNULL_END
