//
//  FLYModelTool.m
//  sqlite封装
//
//  Created by fly on 2020/5/8.
//  Copyright © 2020 fly. All rights reserved.
//

#import "FLYModelTool.h"
#import <objc/runtime.h>
#import "FLYModelProtocal.h"

@implementation FLYModelTool

+ (NSString *)tableName:(Class)cls
{
    return NSStringFromClass(cls);
}


+ (NSString *)tmpTableName:(Class)cls
{
    return [NSStringFromClass(cls) stringByAppendingString:@"_tmp"];
}


+ (NSDictionary *)classIvarNameAndType:(Class)cls
{
    //获取需要忽略的成员变量
    NSArray * ignoreNames;
    if ( [cls respondsToSelector:@selector(ignoreColumnNames)] )
    {
        ignoreNames = [cls ignoreColumnNames];
    }
    
    
    //获取这个类里面，所有的成员变量以及类型 (获取 成员变量(带下划线) 而不是 属性，因为 属性 内部可能重写了set或get方法，或者可能是只读的，不能用来存值)
    //第二个参数代表个数,传进去会给它赋值
    unsigned int outCount = 0;
    Ivar * ivarList = class_copyIvarList(cls, &outCount);
    
    NSMutableDictionary * nameAndTypeDict = [NSMutableDictionary dictionary];
    for ( int i = 0; i < outCount; i++ )
    {
        Ivar ivar = ivarList[i];
        
        //1. 获取成员变量名称
        NSString * ivarName = [NSString stringWithUTF8String:ivar_getName(ivar)];
        //判断以下划线为前缀
        if ( [ivarName hasPrefix:@"_"] )
        {
            //截掉成员变量前的下划线
            ivarName = [ivarName substringFromIndex:1];
        }
    
        //判断ivarName是否在忽略数组里
        if ( [ignoreNames containsObject:ivarName] )
        {
            continue;
        }
        
        
        //2. 获取成员变量类型
        NSString * type = [NSString stringWithUTF8String:ivar_getTypeEncoding(ivar)];
        
        //如果类型是NSString类型，它里面的值是@\"NSString\"，我们要过滤@和\"
        type = [type stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"@\""]];
        
        
        //3.放入字典
        [nameAndTypeDict setValue:type forKey:ivarName];
    }
    
    return nameAndTypeDict;
}


+ (NSDictionary *)classIvarNameAndSqliteType:(Class)cls
{
    NSMutableDictionary * dict = [self classIvarNameAndType:cls].mutableCopy;
    
    [dict enumerateKeysAndObjectsUsingBlock:^(NSString * key, NSString * obj, BOOL * _Nonnull stop) {
        
        //oc数据类型 转成 sqlite数据类型
        dict[key] = [self ocTypeToSqliteType][obj];
        
    }];
    
    return dict;
}


+ (NSString *)columnNamesAndTypes:(Class)cls
{
/*
    {
        age = integer;
        name = text;
        score = real;
        stuNum = integer;
    }
 
把上面拼接成 age integer, name text, score real, stuNum integer ，方便外界sql语句填参
*/
    
    
    NSDictionary * nameAndTypeDict = [self classIvarNameAndSqliteType:cls];
    
    NSMutableArray * result = [NSMutableArray array];
    
    [nameAndTypeDict enumerateKeysAndObjectsUsingBlock:^(NSString * key, NSString * obj, BOOL * _Nonnull stop) {
        
        [result addObject:[NSString stringWithFormat:@"%@ %@", key, obj]];
    }];
    
    //以“,”为分隔符，对数组元素拼接成一个字符串
    return [result componentsJoinedByString:@","];
}


+ (NSArray *)allTableSortedIvarNames:(Class)cls
{
    NSDictionary * dic = [self classIvarNameAndType:cls];
    //取出所有的name (key存放的是name，Value存放的是类型)
    NSArray * keys = dic.allKeys;
    
    //排序 (不可变数组用sortedArrayUsingComparator:，可变数组用sortUsingComparator:)
    keys = [keys sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
        
        //compare比较连个字符串，返回NSOrderedAscending、NSOrderedSame、NSOrderedDescending
        return [obj1 compare:obj2];
    }];
    
    return keys;
}



#pragma mark - private methods

//oc数据类型 和 sqlite数据类型 映射表
+ (NSDictionary *)ocTypeToSqliteType
{
    return @{
        @"d" : @"real",  // double
        @"f" : @"real",  // float
        
        @"i" : @"integer", // int
        @"q" : @"integer", // long
        @"Q" : @"integer", // long long
        @"B" : @"integer", // bool
        
        @"NSData" : @"blob",
        @"NSDictionary" : @"text",
        @"NSMutableDictionary" : @"text",
        @"NSArray" : @"text",
        @"NSMutableArray" : @"text",
        
        @"NSString" : @"text"
    };
}

@end
