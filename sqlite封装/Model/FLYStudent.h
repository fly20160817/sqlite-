//
//  FLYStudent.h
//  sqlite封装
//
//  Created by fly on 2020/5/8.
//  Copyright © 2020 fly. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FLYModelProtocal.h"

NS_ASSUME_NONNULL_BEGIN

@interface FLYStudent : NSObject < FLYModelProtocal >

@property (nonatomic, assign) int stuNum;
@property (nonatomic, strong) NSString * name;
@property (nonatomic, assign) int age;
@property (nonatomic, assign) float score;
@property (nonatomic, assign) float score2;
@property (nonatomic, assign) float score3;

@property (nonatomic, strong) NSDictionary * dic;
@property (nonatomic, strong) NSArray * array;

@end

NS_ASSUME_NONNULL_END
