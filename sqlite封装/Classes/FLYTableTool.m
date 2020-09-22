//
//  FLYTableTool.m
//  sqlite封装
//
//  Created by fly on 2020/5/9.
//  Copyright © 2020 fly. All rights reserved.
//

#import "FLYTableTool.h"
#import "FLYModelTool.h"
#import "FLYSqliteTool.h"

@implementation FLYTableTool

+ (NSArray *)tableSortedColumnNames:(Class)cls uid:(nullable NSString *)uid
{
    NSString * tableName = [FLYModelTool tableName:cls];
    
   
   //查询创建表时的sql语句 (sqlite_master是一张隐藏的系统表，用来管理数据库里的所有表。其中的"sql"字段，放的是我们创建表时的sql语句)
    NSString * queryCreateSqlStr = [NSString stringWithFormat:@"select sql from sqlite_master where type = 'table' and name = '%@'", tableName];
    
    //查出来的只有一条，所以我们直接取第一条
    NSMutableDictionary * dict = [FLYSqliteTool querySql:queryCreateSqlStr uid:uid].firstObject;
    
    //取出创建表时的sql语句
    NSString * createTableSql = dict[@"sql"];
    
    if ( createTableSql.length == 0 )
    {
        return nil;
    }
    
    
    /*
    CREATE TABLE "FLYStudent" (
      "age2" integer,
      "stuNum" integer,
      "score" real,
      "name" text,
      PRIMARY KEY ("stuNum")
    );
     */
    
    //过滤引号和换行 （防止直接修改数据库格式变成上面那样）
    //stringByTrimmingCharactersInSet方法只能过滤字符串收尾两端的特殊字符串
    //createTableSql = [createTableSql stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"\"\n\t"]];

    //根据\"或\n或\t分割成小数组
    NSArray * strArray = [createTableSql componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"\"\n\t"]];
    //用空分割，拼接数组元素成一个字符串
    createTableSql = [strArray componentsJoinedByString:@""];

    
    
    //CREATE TABLE FLYStudent(age integer,stuNum integer,score real,name text, primary key(stuNum))
    
    //取出 age integer,stuNum integer,score real,name text, primary key
    //按照"("把sql语句分割成数据，取第1个元素就是所有的字段和类型
    NSString * nameAndTypeStr = [createTableSql componentsSeparatedByString:@"("][1];
    
    //再按照","分割成数组 (@[ @"age integer", @"stuNum integer",... ])
    NSArray * nameAndTypeArray = [nameAndTypeStr componentsSeparatedByString:@","];
    
    NSMutableArray * names = [NSMutableArray array];
    
    for ( NSString * nameAndType in nameAndTypeArray )
    {
        //过滤最后一个没用的"primary key" (判断是否包含)
        if ( [nameAndType containsString:@"primary"] || [nameAndType containsString:@"PRIMARY"] )
        {
            continue;
        }
        
        //过滤字符串前后两端的空格
        NSString * nameAndTypeTemp = [nameAndType stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        
        // age integer
        //按照空格分割成数组，取出name
        NSString * name = [nameAndTypeTemp componentsSeparatedByString:@" "].firstObject;
        [names addObject:name];
    }
    
    
    //排序 (不可变数组用sortedArrayUsingComparator:，可变数组用sortUsingComparator:)
    [names sortUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
        
        //compare比较连个字符串，返回NSOrderedAscending、NSOrderedSame、NSOrderedDescending
        return [obj1 compare:obj2];
        
    }];
    
    return names.copy;
}


/** 判断表是否存在 */
+ (BOOL)isTableExists:(Class)cls uid:(nullable NSString *)uid
{
    NSString * tableName = [FLYModelTool tableName:cls];
     
    
    //查询创建表时的sql语句 (sqlite_master是一张隐藏的系统表，用来管理数据库里的所有表。其中的"sql"字段，放的是我们创建表时的sql语句)
     NSString * queryCreateSqlStr = [NSString stringWithFormat:@"select sql from sqlite_master where type = 'table' and name = '%@'", tableName];
     
    //查出来的只有一条，所以我们直接取第一条
    NSMutableDictionary * dic = [FLYSqliteTool querySql:queryCreateSqlStr uid:uid].firstObject;
    
    //如果有数据，说明存在
    return dic.count > 0;
}

@end


