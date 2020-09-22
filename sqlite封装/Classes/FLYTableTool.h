//
//  FLYTableTool.h
//  sqlite封装
//
//  Created by fly on 2020/5/9.
//  Copyright © 2020 fly. All rights reserved.
//

//操作数据库表格的类

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface FLYTableTool : NSObject

/**获取表中所有的字段，并排序好 (排序是为了和外界的数组进行对比)*/
//uid是为了确定哪个数据库，cls是确定哪张表
+ (NSArray *)tableSortedColumnNames:(Class)cls uid:(nullable NSString *)uid;

/** 判断表是否存在 */
+ (BOOL)isTableExists:(Class)cls uid:(nullable NSString *)uid;

@end

NS_ASSUME_NONNULL_END
