//
//  LibratoMetric.h
//  Librato-iOS
//
//  Created by Adam Yanalunas on 9/27/13.
//  Copyright (c) 2013 Amco International Education Services, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString *const LibratoMetricMeasureTimeKey;
extern NSString *const LibratoMetricNameKey;
extern NSString *const LibratoMetricSourceKey;
extern NSString *const LibratoMetricValueKey;

@interface LibratoMetric : NSObject

@property (nonatomic, strong) NSMutableDictionary *data;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSDate *measureTime;
@property (nonatomic, strong) NSString *type;

- (instancetype)initWithName:(NSString *)name valued:(NSNumber *)value options:(NSDictionary *)options;
+ (instancetype)metricNamed:(NSString *)name valued:(NSNumber *)value options:(NSDictionary *)options;

- (NSDictionary *)JSON;
- (NSString *)source;
- (void)setSource:(NSString *)source;
- (NSNumber *)value;
- (void)setValue:(NSNumber *)value;

@end
