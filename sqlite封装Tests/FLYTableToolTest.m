//
//  FLYTableToolTest.m
//  sqlite封装Tests
//
//  Created by fly on 2020/5/11.
//  Copyright © 2020 fly. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "FLYTableTool.h"

@interface FLYTableToolTest : XCTestCase

@end

@implementation FLYTableToolTest

- (void)setUp {
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
}

- (void)testExample {
    // This is an example of a functional test case.
    // Use XCTAssert and related functions to verify your tests produce the correct results.
    
    
    Class cls = NSClassFromString(@"FLYStudent");
    NSArray * result = [FLYTableTool tableSortedColumnNames:cls uid:nil];
    
    NSLog(@"result = %@", result);
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

@end
