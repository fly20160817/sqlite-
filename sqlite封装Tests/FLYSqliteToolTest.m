//
//  FLYSqliteToolTest.m
//  sqlite封装Tests
//
//  Created by fly on 2020/5/7.
//  Copyright © 2020 fly. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "FLYSqliteTool.h"
#import "FLYModelTool.h"
#import "FLYSqliteModelTool.h"
#import "FLYStudent.h"

@interface FLYSqliteToolTest : XCTestCase

@end

@implementation FLYSqliteToolTest

//初始化的代码，在测试方法调用之前调用
- (void)setUp {
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

// 释放测试用例的资源代码，这个方法会每个测试用例执行后调用
- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
}

// 测试用例的例子，注意测试用例一定要test开头
- (void)testDealSql {
    
    NSString * sql = @"create table if not exists t_stu(id integer primary key autoincrement, name text not null, age integer, score real)";
    BOOL result = [FLYSqliteTool dealSql:sql uid:nil];
    XCTAssertEqual(result, YES);
    
}

- (void)testCreateTabel
{
    //BOOL result = [FLYSqliteModelTool createTabel:[FLYStudent class] uid:nil];
    //XCTAssertEqual(result, YES);
}

- (void)testQuerySql {
    
    NSString * sql = @"select * from t_stu";
    NSMutableArray * result = [FLYSqliteTool querySql:sql uid:nil];
    
    NSLog(@"result = %@", result);
}

- (void)testIsTableRequiredUpdate
{
    //BOOL result = [FLYSqliteModelTool isTableRequiredUpdate:[FLYStudent class] uid:nil];
    //XCTAssertEqual(result, YES);
}

- (void)testUpdateTable
{
    //Class cls = NSClassFromString(@"FLYStudent");
    //BOOL result = [FLYSqliteModelTool updateTable:cls uid:nil];
    
    //XCTAssertEqual(result, YES);
}


- (void)testSaveOrUpdateModel
{
    FLYStudent * stu = [[FLYStudent alloc] init];
    stu.stuNum = 101;
    stu.age = 131;
    stu.name = @"fly002";
    stu.score = 100;
    stu.array = @[@"2", @"3"];
    stu.dic = @{ @"c" : @"cc", @"d" : @"dd" };
    
    [FLYSqliteModelTool saveOrUpdateModel:stu uid:nil];
}


- (void)testDeleteModel
{
    FLYStudent * stu = [[FLYStudent alloc] init];
    stu.stuNum = 1;
    stu.age = 188;
    stu.name = @"fly";
    stu.score = 88;
    
    [FLYSqliteModelTool deleteModel:stu uid:nil];
}


- (void)testDeleteModelWhere
{
    [FLYSqliteModelTool deleteModel:[FLYStudent class] whereStr:@"score <= 100" uid:nil];
}


- (void)testDeleteModelWhere2
{
    [FLYSqliteModelTool deleteModel:[FLYStudent class] columnName:@"name" relation:ColumnNameToValueRelationTypeEqual value:@"fly" uid:nil];
}


//查询所有
- (void)testQueryAllModels
{
    NSArray * array = [FLYSqliteModelTool queryAllModels:[FLYStudent class] uid:nil];
    
    NSLog(@"array = %@", array);
}


//根据条件查询
- (void)testQueryModelWhere
{
    NSArray * array = [FLYSqliteModelTool queryModel:[FLYStudent class] columnName:@"name" relation:ColumnNameToValueRelationTypeEqual value:@"fly" uid:nil];
    
    NSLog(@"array = %@", array);
}


- (void)testPerformanceExample {
    // This is an example of a performance test case.
    //这是一个性能测试用例的例子。
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
        //把你想要测量时间的代码放在这里。
    }];
}

@end
