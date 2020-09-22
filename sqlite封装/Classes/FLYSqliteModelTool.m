//
//  FLYSqliteModelTool.m
//  sqlite封装
//
//  Created by fly on 2020/5/8.
//  Copyright © 2020 fly. All rights reserved.
//


/*
 关于这个工具类的封装
 
 实现方案
 方案1: 基于配置 (需要为model新建一个plist文件，把表名、字段名、字段类型、约主键等放进去)
 方案2: runtime动态获取
 
 我们这里用的是方案2。
 */


#import "FLYSqliteModelTool.h"
#import "FLYModelTool.h"
#import "FLYSqliteTool.h"
#import "FLYTableTool.h"

@interface FLYSqliteModelTool ()

/**动态建表 (模型的类名做为表名，uid表示放在哪个数据库里(一个用户对应一个数据库))*/
+ (BOOL)createTabel:(Class)cls uid:(nullable NSString *)uid;

/**判断表格是否需要更新*/
+ (BOOL)isTableRequiredUpdate:(Class)cls uid:(nullable NSString *)uid;

/** 更新表格 */
+ (BOOL)updateTable:(Class)cls uid:(nullable NSString *)uid;

@end


@implementation FLYSqliteModelTool





#pragma mark - 保存

/** 保存模型 */
+ (BOOL)saveOrUpdateModel:(id)model uid:(nullable NSString *)uid
{
    //如果用户在使用过程中，直接调用这个方法，去保存模型
    //保存一个模型
    
    
    Class cls = [model class];
    
    //1.判断表是否存在，不存在则创建
    if ( ![FLYTableTool isTableExists:cls uid:uid] )
    {
        [self createTabel:cls uid:uid];
    }
    
    
    //2.检测表是否需要更新，需要则更新
    if ( [self isTableRequiredUpdate:cls uid:uid] )
    {
        [self updateTable:cls uid:uid];
    }
    
    
    //3.判断记录是否存在 (主键)
    //如果存在，更新
    //如果不存在，插入
    //从表里面，按照主键进行查询，是否能查的到
    
    //获取表格名称
    NSString * tableName = [FLYModelTool tableName:cls];
    
    
    //获取主键 (通过协议获取)
    //判断cls类能否响应primaryKey方法
    if ( ![cls respondsToSelector:@selector(primaryKey)] )
    {
        NSLog(@"如果想要操作这个模型，必须要在模型的.m文件里实现 + (NSString *)primaryKey; 这个方法，来告诉我主键信息");
        return NO;
    }
    
    NSString * primaryKey = [cls primaryKey];
    //获取主键的值
    id primaryValue = [model valueForKeyPath:primaryKey];
    
    
    NSString * checkSql = [NSString stringWithFormat:@"select * from %@ where %@ = '%@'", tableName, primaryKey, primaryValue];
    NSArray * result = [FLYSqliteTool querySql:checkSql uid:uid];
    
    
    
    //获取字段名称数组
    NSArray * columnNames = [FLYModelTool classIvarNameAndType:cls].allKeys;
    
    //获取值数组
    NSMutableArray * values = [NSMutableArray array];
    for ( NSString * columnName in columnNames )
    {
        id value = [model valueForKeyPath:columnName];
        
        //如果是字典或者数组，把字典或者数组，处理成为一个字符串，保存到数据库里 (NSMutableArray是NSArray的子类，也会进入这个方法)
        if ( [value isKindOfClass:[NSArray class]] || [value isKindOfClass:[NSDictionary class]] )
        {
            //把字典/数组 转成 data
            NSData * data = [NSJSONSerialization dataWithJSONObject:value options:NSJSONWritingPrettyPrinted error:nil];
            //data 转 字符串
            value = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        }
        
        [values addObject:value];
    }
    
    //拼接sql语句的参数
    NSInteger count = columnNames.count;
    NSMutableArray * setValueArray = [NSMutableArray array];
    for ( int i = 0; i < count; i++ )
    {
        NSString * name = columnNames[i];
        id value = values[i];
        NSString * setStr = [NSString stringWithFormat:@"%@='%@'", name, value];
        [setValueArray addObject:setStr];
    }
    NSString * params = [setValueArray componentsJoinedByString:@","];
    
    
    //有结果就 更新
    NSString * execSql = @"";
    if ( result.count > 0 )
    {
        execSql = [NSString stringWithFormat:@"update %@ set %@ where %@ = '%@'", tableName, params, primaryKey, primaryValue];
    }
    //没有结果就 插入
    else
    {
        //insert into 表名(字段1, 字段2, 字段3) values ('值1', '值2', '值3')
        //'  值1', '值2', '值3  '  注意要拼上单引号，先把前后的打出来，再在逗号的前后各加一个
        execSql = [NSString stringWithFormat:@"insert into %@(%@) values('%@')", tableName, [columnNames componentsJoinedByString:@","], [values componentsJoinedByString:@"','"]];
    }
    
    return [FLYSqliteTool dealSql:execSql uid:uid];
    
}



#pragma mark - 删除

/** 删除模型 */
+ (BOOL)deleteModel:(id)model uid:(nullable NSString *)uid
{
    Class cls = [model class];
    
    //获取主键 (通过协议获取)
    //判断cls类能否响应primaryKey方法
    if ( ![cls respondsToSelector:@selector(primaryKey)] )
    {
        NSLog(@"如果想要操作这个模型，必须要在模型的.m文件里实现 + (NSString *)primaryKey; 这个方法，来告诉我主键信息");
        return NO;
    }
    
    NSString * primaryKey = [cls primaryKey];
    id primaryValue = [model valueForKeyPath:primaryKey];
    
    NSString * tableName = [FLYModelTool tableName:cls];
    NSString * deleteSql = [NSString stringWithFormat:@"delete from %@ where %@ = '%@'", tableName, primaryKey, primaryValue];
    
    
    return [FLYSqliteTool dealSql:deleteSql uid:uid];
}


/** 根据条件删除模型 */
+ (BOOL)deleteModel:(Class)cls whereStr:(NSString *)whereStr uid:(nullable NSString *)uid
{
    NSString * tableName = [FLYModelTool tableName:cls];
    NSString * deleteSql = [NSString stringWithFormat:@"delete from %@", tableName];
    
    if( whereStr.length > 0 )
    {
        deleteSql = [deleteSql stringByAppendingFormat:@" where %@", whereStr];
    }
    
    
    return [FLYSqliteTool dealSql:deleteSql uid:uid];
}


/** 根据条件删除模型 */
+ (BOOL)deleteModel:(Class)cls columnName:(NSString *)name relation:(ColumnNameToValueRelationType)relation value:(id)value uid:(nullable NSString *)uid
{
    NSString * tableName = [FLYModelTool tableName:cls];
    NSString * deleteSql = [NSString stringWithFormat:@"delete from %@ where %@ %@ '%@'", tableName, name, self.columnNameToValueRelationTypeDic[@(relation)], value];
    
    return [FLYSqliteTool dealSql:deleteSql uid:uid];
}


/** 根据条件删除模型 (直接传sql语句进来，条件复杂的时候使用)*/
+ (BOOL)deleteModelsWithSql:(NSString *)sql uid:(nullable NSString *)uid
{
    return [FLYSqliteTool dealSql:sql uid:uid];
}



#pragma mark - 查询

/** 查询 */
+ (NSArray *)queryAllModels:(Class)cls uid:(NSString *)uid
{
    NSString * tableName = [FLYModelTool tableName:cls];
    
    //1.sql
    NSString * sql = [NSString stringWithFormat:@"select * from %@", tableName];
    
    //2.执行查询
    NSArray<NSDictionary *> * results = [FLYSqliteTool querySql:sql uid:uid];
    
    //3.处理查询结果集 -> 模型数组
    return [self parseResults:results withClass:cls];
}


/** 根据条件查询 (传 列名、大小关系的符号、值) */
+ (NSArray *)queryModel:(Class)cls columnName:(NSString *)name relation:(ColumnNameToValueRelationType)relation value:(id)value uid:(nullable NSString *)uid
{
    NSString * tableName = [FLYModelTool tableName:cls];
    
    //1.拼接sql语句
    NSString * sql = [NSString stringWithFormat:@"select * from %@ where %@ %@ '%@'", tableName, name, self.columnNameToValueRelationTypeDic[@(relation)], value];
    
    //2.执行查询
    NSArray<NSDictionary *> * results = [FLYSqliteTool querySql:sql uid:uid];

    //3.处理查询结果集 -> 模型数组
    return [self parseResults:results withClass:cls];
}


/** 根据条件查询 (直接传sql语句进来，条件复杂的时候使用)*/
+ (NSArray *)queryModels:(Class)cls sql:(NSString *)sql uid:(nullable NSString *)uid
{
    //执行查询
    NSArray<NSDictionary *> * results = [FLYSqliteTool querySql:sql uid:uid];

    //处理查询结果集 -> 模型数组
    return [self parseResults:results withClass:cls];
}



#pragma mark - 关于表的操作

+ (BOOL)createTabel:(Class)cls uid:(nullable NSString *)uid
{
    //1.创建表格的sql语句拼接出来
    //create table if not exists 表名( 字段1 字段1类型 (约束), 字段2 字段2类型 (约束),......, primary key(字段) )
    
    //1.1 获取表格名称
    NSString * tableName = [FLYModelTool tableName:cls];
    
    
    //1.2 获取主键 (通过协议获取)
    //判断cls类能否响应primaryKey方法
    if ( ![cls respondsToSelector:@selector(primaryKey)] )
    {
        NSLog(@"如果想要操作这个模型，必须要在模型的.m文件里实现 + (NSString *)primaryKey; 这个方法，来告诉我主键信息");
        return NO;
    }
    
    NSString * primaryKey = [cls primaryKey];
    
    
    //1.3 获取一个模型里面所有的字段，以及类型
    NSString * sqlParams = [FLYModelTool columnNamesAndTypes:cls];
    
    
    //1.4 拼接成完整的sql语句
    NSString * createTableSql = [NSString stringWithFormat:@"create table if not exists %@(%@, primary key(%@))", tableName, sqlParams, primaryKey];
    
    
    //2.执行
    return [FLYSqliteTool dealSql:createTableSql uid:uid];
}


/**判断表格是否需要更新*/
+ (BOOL)isTableRequiredUpdate:(Class)cls uid:(nullable NSString *)uid
{
    //获取排序好的模型中所有的成员变量
    NSArray * modelNames = [FLYModelTool allTableSortedIvarNames:cls];
    
    //获取排序好的表中所有的字段
    NSArray * tableNames = [FLYTableTool tableSortedColumnNames:cls uid:uid];
    
    
    //判断两个数组是否一样
    return ![modelNames isEqualToArray:tableNames];
}


/** 更新表格 */
+ (BOOL)updateTable:(Class)cls uid:(nullable NSString *)uid
{
    //存放sql语句的数组
    NSMutableArray * execSqls = [NSMutableArray array];
    
    //1.创建一个最新字段的临时表
    
    //1.1 获取表格名称
    NSString * tmpTableName = [FLYModelTool tmpTableName:cls];
    NSString * tableName = [FLYModelTool tableName:cls];
    
    //1.2 获取主键 (通过协议获取)
    //判断cls类能否响应primaryKey方法
    if ( ![cls respondsToSelector:@selector(primaryKey)] )
    {
        NSLog(@"如果想要操作这个模型，必须要在模型的.m文件里实现 + (NSString *)primaryKey; 这个方法，来告诉我主键信息");
        return NO;
    }
    
    NSString * primaryKey = [cls primaryKey];
    
    
    //1.3 获取一个模型里面所有的字段，以及类型
    NSString * sqlParams = [FLYModelTool columnNamesAndTypes:cls];
    
    
    //1.4 拼接成完整的sql语句
    NSString * createTableSql = [NSString stringWithFormat:@"create table if not exists %@(%@, primary key(%@))", tmpTableName, sqlParams, primaryKey];
    [execSqls addObject:createTableSql];
    
    
    
    //2.给临时表插入主键数据
    NSString * insertPrimaryKeyDataSql = [NSString stringWithFormat:@"insert into %@(%@) select %@ from %@", tmpTableName, primaryKey, primaryKey, tableName];
    [execSqls addObject:insertPrimaryKeyDataSql];
    
    
    
    
    
    
    //3.根据主键，把所有的数据更新到临时表里面
    
    //获取数据库表的字段数组
    NSArray * oldNames = [FLYTableTool tableSortedColumnNames:cls uid:uid];
    //获取最新model的字段数组
    NSArray * newNames = [FLYModelTool allTableSortedIvarNames:cls];
    
    //获取需要更名的字典
    NSDictionary * newNameToOldNameDic = [NSDictionary dictionary];
    if ( [cls respondsToSelector:@selector(newNameToOldNameDic)] )
    {
        newNameToOldNameDic = [cls newNameToOldNameDic];
    }
    
    
    for (NSString * columnName in newNames)
    {
        //判断映射表里是否有对应的旧字段名称
        //默认给 oldName 赋值为 新的name，如果映射表里面有改变，则赋值为老的name (需要判断老表里是否包含老字段，防止重复修改，第二次就找不到了)
        NSString * oldName = columnName;
        if ( [newNameToOldNameDic[columnName] length] != 0 && [oldNames containsObject:oldName] )
        {
            oldName = newNameToOldNameDic[columnName];
        }
        
        //如果老表里包含了Model的字段，应该把这个字段从老表更新到临时表格里
        //判断老表里面是否有这个字段 和 映射表的旧字段里是否有这个字段，没有就直接跳过 (还要过滤掉主键，因为步骤2的时候已经插入完了那个字段)
        if ( ( [oldNames containsObject:columnName] == NO && [oldNames containsObject:oldName] == NO ) || [columnName isEqualToString:primaryKey] )
        {
            continue;
        }
        
        
        NSString * updateSql = [NSString stringWithFormat:@"update %@ set %@ = (select %@ from %@ where %@.%@ = %@.%@)", tmpTableName, columnName, oldName, tableName, tmpTableName, primaryKey, tableName, primaryKey];
        [execSqls addObject:updateSql];
    }
    
    
    
    //4.删除老表
    NSString * deleteOldTabelSql = [NSString stringWithFormat:@"drop table if exists %@", tableName];
    [execSqls addObject:deleteOldTabelSql];
    
    
    
    //5.把临时表的名字改成老表的名字
    NSString * renameTableNameSql = [NSString stringWithFormat:@"alter table %@ rename to %@", tmpTableName, tableName];
    [execSqls addObject:renameTableNameSql];
    
    
    //执行所有的sql语句
    return [FLYSqliteTool dealSqls:execSqls uid:uid];
}



#pragma mark - private methods

//处理查询的结果 (字典数组 转 模型数组)
+ (NSArray *)parseResults:(NSArray<NSDictionary*> *)results withClass:(Class)cls
{
    NSMutableArray * models = [NSMutableArray array];
    
    //属性名称 -> 类型 的字典
    NSDictionary * nameTypeDic = [FLYModelTool classIvarNameAndType:cls];
    
    for (NSDictionary * modelDic in results)
    {
        id model = [[cls alloc] init];

        [modelDic enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
            
            NSString * type = nameTypeDic[key];
            id resultValue = obj;
            
            if ( [type isEqualToString:@"NSArray"] || [type isEqualToString:@"NSDictionary"] )
            {
                //字符串 转 data
                NSData * data = [obj dataUsingEncoding:NSUTF8StringEncoding];
                //data 序列化转数组/字典 (kNilOptions 等于0，填0代表序列化之后是不可变类型)
                resultValue = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
                
            }
            else if ( [type isEqualToString:@"NSMutableArray"] || [type isEqualToString:@"NSMutableDictionary"] )
            {
                //字符串 转 data
                NSData * data = [obj dataUsingEncoding:NSUTF8StringEncoding];
                //data 序列化转数组/字典 (NSJSONReadingMutableLeaves代表序列化之后是可变类型)
                resultValue = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:nil];
            }
            
            [model setValue:resultValue forKeyPath:key];
            
        }];
        
        
        [models addObject:model];
    }
    
    return models.copy;
}


//枚举的映射表
+ (NSDictionary *)columnNameToValueRelationTypeDic
{
    return @{
        @(ColumnNameToValueRelationTypeMore) : @">",
        @(ColumnNameToValueRelationTypeLess) : @"<",
        @(ColumnNameToValueRelationTypeEqual) : @"=",
        @(ColumnNameToValueRelationTypeMoreEqual) : @">=",
        @(ColumnNameToValueRelationTypeLessEqual) : @"<=",
    };
}


@end
