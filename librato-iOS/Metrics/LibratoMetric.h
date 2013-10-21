//
//  LibratoMetric.h
//  Librato-iOS
//
//  Created by Adam Yanalunas on 9/27/13.
//  Copyright (c) 2013 Amco International Education Services, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MTLModel.h"
#import "MTLJSONAdapter.h"

extern NSString *const LibratoMetricMeasureTimeKey;
extern NSString *const LibratoMetricNameKey;
extern NSString *const LibratoMetricSourceKey;
extern NSString *const LibratoMetricValueKey;

@interface LibratoMetric : MTLModel <MTLJSONSerializing>

@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSDate *measureTime;
@property (nonatomic, copy) NSString *type;
@property (nonatomic, copy) NSString *source;
@property (nonatomic, copy) NSNumber *value;

- (instancetype)initWithName:(NSString *)name valued:(NSNumber *)value options:(NSDictionary *)options;
- (NSDictionary *)JSONDictionary;

+ (instancetype)metricNamed:(NSString *)name valued:(NSNumber *)value;
+ (instancetype)metricNamed:(NSString *)name valued:(NSNumber *)value options:(NSDictionary *)options;
+ (instancetype)metricNamed:(NSString *)name valued:(NSNumber *)value source:(NSString *)source measureTime:(NSDate *)date;

@end
