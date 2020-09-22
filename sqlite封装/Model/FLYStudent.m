//
//  FLYStudent.m
//  sqlite封装
//
//  Created by fly on 2020/5/8.
//  Copyright © 2020 fly. All rights reserved.
//

#import "FLYStudent.h"

@implementation FLYStudent

//设置主键
+ (NSString *)primaryKey
{
    return @"stuNum";
}

//需要忽略的成员变量 (不一定每个成员变量都需要保存进数据库)
+ (NSArray *)ignoreColumnNames
{
    return @[ @"score2", @"score3" ];
}

//新字段名称 -> 旧字段名称 的映射表格 (key是新，value是旧)
+ (NSDictionary *)newNameToOldNameDic
{
    return @{ @"age" : @"age2" };
}


@end
