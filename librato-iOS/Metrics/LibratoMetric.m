//
//  LibratoMetric.m
//  Librato-iOS
//
//  Created by Adam Yanalunas on 9/27/13.
//  Copyright (c) 2013 Amco International Education Services, LLC. All rights reserved.
//

#import "LibratoMetric.h"
#import "NSString+SanitizedForMetric.h"

NSString *const LibratoMetricMeasureTimeKey = @"measure_time";
NSString *const LibratoMetricNameKey = @"name";
NSString *const LibratoMetricSourceKey = @"source";
NSString *const LibratoMetricValueKey = @"value";

@implementation LibratoMetric

#pragma mark - Lifecycle
+ (instancetype)metricNamed:(NSString *)name valued:(NSNumber *)value options:(NSDictionary *)options
{
    return [LibratoMetric.alloc initWithName:name valued:value options:options];
}


- (instancetype)initWithName:(NSString *)name valued:(NSNumber *)value options:(NSDictionary *)options
{
    if ((self = super.init))
    {
        self.data = (options ? options.mutableCopy : @{}.mutableCopy);
        self.name = name;
        self.value = value ?: @0;
        self.source = options[LibratoMetricSourceKey];
        self.type = @"counters";
    }

    return self;
}


#pragma mark - Properties
- (NSString *)name
{
    return self.data[LibratoMetricNameKey] ?: nil;
}


- (void)setName:(NSString *)name
{
    NSAssert(name.length > 0, @"Measurements must be named");
    self.data[LibratoMetricNameKey] = name.sanitizedForMetric;
}


- (NSDate *)measureTime
{
    return self.data[LibratoMetricMeasureTimeKey] ?: nil;
}


- (void)setMeasureTime:(NSDate *)measureTime
{
    self.data[LibratoMetricMeasureTimeKey] = measureTime;
}


- (NSString *)source
{
    return self.data[LibratoMetricSourceKey] ?: nil;
}


- (void)setSource:(NSString *)source
{
    if (source.length)
    {
        self.data[LibratoMetricSourceKey] = source.sanitizedForMetric;
    }
    else
    {
        [self.data removeObjectForKey:LibratoMetricSourceKey];
    }
}


- (NSNumber *)value
{
    return self.data[LibratoMetricValueKey] ?: nil;
}


- (void)setValue:(NSNumber *)value
{
    NSAssert([self isValidValue:value], @"Boolean is not a valid metric value");
    self.data[LibratoMetricValueKey] = value;
}


#pragma mark - Exporting data
- (NSDictionary *)JSON
{
    NSMutableDictionary *json = self.data.mutableCopy;
    if ([self.measureTime isKindOfClass:NSDate.class])
    {
        json[LibratoMetricMeasureTimeKey] = @(floor(self.measureTime.timeIntervalSince1970));
    }

    return json;
}


#pragma mark - Validation
- (BOOL)isValidValue:(NSNumber *)value
{
    return (strcmp([value objCType], @encode(BOOL)) == 0) ? NO : YES;
}


#pragma mark - KVC Collection Operators
- (NSUInteger)squared
{
    return pow(self.value.integerValue, 2);
}


#pragma mark - Overrides
- (NSString *)description
{
    return [NSString stringWithFormat:@"<%@: %p, name: %@, value: %@>", NSStringFromClass([self class]), self, self.name, self.value];
}


@end
