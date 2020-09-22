//
//  FLYSqliteModelTool.h
//  sqlite封装
//
//  Created by fly on 2020/5/8.
//  Copyright © 2020 fly. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FLYModelProtocal.h"

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, ColumnNameToValueRelationType) {
    ColumnNameToValueRelationTypeMore,      //  >
    ColumnNameToValueRelationTypeLess,      //  <
    ColumnNameToValueRelationTypeEqual,     //  =
    ColumnNameToValueRelationTypeMoreEqual, //  >=
    ColumnNameToValueRelationTypeLessEqual, //  <=
};

@interface FLYSqliteModelTool : NSObject

/** 保存模型 */
+ (BOOL)saveOrUpdateModel:(id)model uid:(nullable NSString *)uid;



/** 删除模型 */
+ (BOOL)deleteModel:(id)model uid:(nullable NSString *)uid;

/** 根据条件删除模型 (传qel条件) */
+ (BOOL)deleteModel:(Class)cls whereStr:(NSString *)whereStr uid:(nullable NSString *)uid;

/** 根据条件删除模型 (传 列名、大小关系的符号、值) */
+ (BOOL)deleteModel:(Class)cls columnName:(NSString *)name relation:(ColumnNameToValueRelationType)relation value:(id)value uid:(nullable NSString *)uid;

/** 根据条件删除模型 (直接传sql语句进来，条件复杂的时候使用)*/
+ (BOOL)deleteModelsWithSql:(NSString *)sql uid:(nullable NSString *)uid;



/** 查询所有 */
+ (NSArray *)queryAllModels:(Class)cls uid:(nullable NSString *)uid;

/** 根据条件查询 (传 列名、大小关系的符号、值) */
+ (NSArray *)queryModel:(Class)cls columnName:(NSString *)name relation:(ColumnNameToValueRelationType)relation value:(id)value uid:(nullable NSString *)uid;

/** 根据条件查询 (直接传sql语句进来，条件复杂的时候使用)*/
+ (NSArray *)queryModels:(Class)cls sql:(NSString *)sql uid:(nullable NSString *)uid;



@end

NS_ASSUME_NONNULL_END
