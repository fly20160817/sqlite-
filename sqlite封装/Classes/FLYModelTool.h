//
//  FLYModelTool.h
//  sqlite封装
//
//  Created by fly on 2020/5/8.
//  Copyright © 2020 fly. All rights reserved.
//

//把 model 的东西，转换成 sqlite 

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface FLYModelTool : NSObject

/**传进来类名，返回表名*/
+ (NSString *)tableName:(Class)cls;

/**传进来类名，返回带_tmp后缀的表名*/
+ (NSString *)tmpTableName:(Class)cls;

/**返回传入Class的所有成员变量(字段)，以及成员变量对应的类型*/
+ (NSDictionary *)classIvarNameAndType:(Class)cls;

/**返回传入Class的所有成员变量(字段)，以及成员变量映射到数据库对应的类型*/
+ (NSDictionary *)classIvarNameAndSqliteType:(Class)cls;

/**把所有的 成员变量 和 对应的数据库类型，拼接成一个字符串*/
+ (NSString *)columnNamesAndTypes:(Class)cls;

/**获取模型中所有的成员变量，并排序好 (排序是为了和数据库表的字段的数组进行对比)*/
+ (NSArray *)allTableSortedIvarNames:(Class)cls;

@end

NS_ASSUME_NONNULL_END
