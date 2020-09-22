//
//  FLYSqliteTool.h
//  sqlite封装
//
//  Created by fly on 2020/5/7.
//  Copyright © 2020 fly. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface FLYSqliteTool : NSObject

/******用户机制 (app可能登陆不同的账号，每个账号对应的数据库不一样)******
 
如果 uid等于nil，代表查询的是公有数据库 common.db
如果 uid等于fly，查询的是fly用户的数据库 fly.db
 
 */



/*
Sqlite语句有很多种类，无非分为三类：
 数据操作语句 DML(增删改)
 数据查询语句 DQL(查询)
 数据定义语句 DDL(表格)
 
我们可以把这三类操作归为两种操作：
 执行语句（返回是否成功） 包含：DML(增删改)
 查询语句 (返回结果集)   包含：DQL(查询) DDL(表格)
 
*/


/** 执行语句 （增删改）*/
+ (BOOL)dealSql:(NSString *)sql uid:(nullable NSString *)uid;

/** 执行多条语句 (里面用到了事务，要么全部执行成功，不然有一条失败就全部失败) */
+ (BOOL)dealSqls:(NSArray <NSString *> *)sqls uid:(nullable NSString *)uid;

/** 查询语句 (返回字典组成的数据) */
+ (NSMutableArray <NSMutableDictionary *> *)querySql:(NSString *)sql uid:(nullable NSString *)uid;

@end

NS_ASSUME_NONNULL_END
