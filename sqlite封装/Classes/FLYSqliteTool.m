//
//  FLYSqliteTool.m
//  sqlite封装
//
//  Created by fly on 2020/5/7.
//  Copyright © 2020 fly. All rights reserved.
//

#import "FLYSqliteTool.h"
#import <sqlite3.h>

//数据库都存放在沙盒的Cache路径里
//#define kCachePath NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES).firstObject
#define kCachePath @"/Users/fly/Desktop/test"

@implementation FLYSqliteTool

sqlite3 *sqlite = nil;

+ (BOOL)dealSql:(NSString *)sql uid:(nullable NSString *)uid
{
    
    //1.打开/创建一个数据库
    if ( ![self openDB:uid] )
    {
        NSLog(@"数据库打开失败，uid = %@", uid);
        return NO;
    }
    
    
    
    //2.执行数据库语句
    
    //执行语句，并判断是否等于SQLITE_OK，把结果赋值给result
    //第一个参数：打开的数据库对象
    //第二个参数：需要执行的数据库语句
    //第三个参数：查询返回的回调，因为我们这个方法不负责查询，所以后面的参数就不填了
    BOOL result = sqlite3_exec(sqlite, sql.UTF8String, nil, nil, nil) == SQLITE_OK;
    
    
    
    //3.关闭数据库
    [self closeDB];
    
    
    return result;
}


/** 执行多条语句 (里面用到了事务，要么全部执行成功，不然有一条失败就全部失败) */
+ (BOOL)dealSqls:(NSArray <NSString *> *)sqls uid:(nullable NSString *)uid
{
    //开启事务
    [self beginTransaction:uid];
    
    for ( NSString * sql in sqls )
    {
        BOOL result = [self dealSql:sql uid:uid];
        
        //判断是否执行成功，不成功则回滚事务，返回NO
        if ( result == NO )
        {
            NSLog(@"sql错误：%@", sql);
            [self rollBackTransaction:uid];
            return NO;
        }
    }
    
    //提交事务
    [self commitTransaction:uid];
    
    return YES;
}



+(NSMutableArray <NSMutableDictionary *> *)querySql:(NSString *)sql uid:(nullable NSString *)uid
{
    //打开数据库
    [self openDB:uid];
    
    
    //准备语句(预处理语句)
    
    //1.创建准备语句
    
    //参数1：一个已经打开的数据库
    //参数2：需要执行的spl语句
    //参数3：参数2取出多少字节的长度 (一般写 -1，代表自动计算)
    //参数4：准备语句
    //参数5：通过参数3，取出参数2的长度字节之后，剩下的字符串
    sqlite3_stmt *ppStmt = nil;
    BOOL result = sqlite3_prepare_v2(sqlite, sql.UTF8String, -1, &ppStmt, nil) == SQLITE_OK;
    if ( !result )
    {
        NSLog(@"准备语句编译失败：%@", sql);
        return nil;
    }
    
    
    //2.绑定数据 (外界传的是带参的sql语句，所以这步省略，参数为“？”的时候才需要这步)
    
    
    //3.执行 （每执行一次sqlite3_step()，就查询一条数据，直到它的返回值不等于SQLITE_ROW）
    NSMutableArray * rowDictArray = [NSMutableArray array];
    while ( sqlite3_step(ppStmt) == SQLITE_ROW )
    {
        //一行记录 转成 字典
        NSMutableDictionary * rowDict = [NSMutableDictionary dictionary];
        //将字典放入数组
        [rowDictArray addObject:rowDict];
        
        //1.获取所有列的个数
        int columnCount = sqlite3_column_count(ppStmt);
        
        //2.遍历所有列的个数
        for ( int i = 0; i < columnCount; i++ )
        {
            //2.1 获取列名 (第二个参数代表获取第几列的列名)
            const char * column_name = sqlite3_column_name(ppStmt, i);
            NSString * columnName = [NSString stringWithUTF8String:column_name];
            
            //2.2 获取列值
            //不同列的数据类型，使用不同的函数，进行获取
            //2.2.1 获取列的数据类型
            int type = sqlite3_column_type(ppStmt, i);
            
            //2.2.2 根据列的类型，使用h不同的函数，进行获取
            id value = nil;
            switch (type)
            {
                case SQLITE_INTEGER:
                    value = @(sqlite3_column_int(ppStmt, i));
                    break;
                    
                case SQLITE_FLOAT:
                    value = @(sqlite3_column_double(ppStmt, i));
                    break;
                    
                case SQLITE_BLOB:
                    value = CFBridgingRelease(sqlite3_column_blob(ppStmt, i));
                    break;
                    
                case SQLITE_NULL:
                    value = @"";
                    break;
                    
                case SQLITE3_TEXT:
                    value = [NSString stringWithUTF8String:(const char *)sqlite3_column_text(ppStmt, i)];
                    break;
                    
                default:
                    break;
            }
            
            //将取出的列名和数值存入字典
            [rowDict setValue:value forKey:columnName];
        }
        
    }
    
    
    //4.重置 (如果下一步就释放资源了，那重置就可以省略)
    
    
    //5.释放资源
    sqlite3_finalize(ppStmt);
    
    
    
    //关闭数据库
    [self closeDB];
    
    return rowDictArray;
}



#pragma mark - private methods

//打开数据库
+ (BOOL)openDB:(NSString *)uid
{
    //后缀名在Sqlite里无所谓，写fly都行，但为了规范一般写db、db2、sqlite
    NSString * dbName = @"common.sqlite";
    if ( uid.length != 0 )
    {
        dbName = [NSString stringWithFormat:@"%@.sqlite", uid];
    }
    NSString * dbPath = [kCachePath stringByAppendingPathComponent:dbName];
    
    
    //打开/创建数据库，并判断是否成功 (sqlite3_open()如果数据库存在则打开，不存在则创建)
    //第一个参数：文件名称  第二个参数：数据库对象
    BOOL result = sqlite3_open(dbPath.UTF8String, &sqlite) == SQLITE_OK;
    
    return result;
}

//关闭数据库
+ (void)closeDB
{
    sqlite3_close(sqlite);
}



/** 开启事务 */
+ (void)beginTransaction:(NSString *)uid
{
    [self dealSql:@"begin transaction" uid:uid];
}

/** 提交事务 */
+ (void)commitTransaction:(NSString *)uid
{
    [self dealSql:@"commit transaction" uid:uid];
}

/** 回滚事务 */
+ (void)rollBackTransaction:(NSString *)uid
{
    [self dealSql:@"rollback transaction" uid:uid];
}

@end
