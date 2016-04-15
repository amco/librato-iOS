//
//  LibratoGaugeMetric.m
//  Librato-iOS
//
//  Created by Adam Yanalunas on 10/2/13.
//  Copyright (c) 2013 Amco International Education Services, LLC. All rights reserved.
//

#import "LibratoMetric.h"
#import "LibratoGaugeMetric.h"

NSString *const LibratoMetricMeasurementsKey = @"measurements";

NSString *const countObserverPath = @"measurements";
NSString *const countKey = @"count";
NSString *const sumKey = @"sum";
NSString *const maxKey = @"max";
NSString *const minKey = @"min";
NSString *const squaresKey = @"sum_squares";

@implementation LibratoGaugeMetric

+ (instancetype)metricNamed:(NSString *)name measurements:(NSArray *)measurements
{
    LibratoGaugeMetric *metric = [LibratoGaugeMetric.alloc initWithName:name valued:nil options:nil];
    [metric computeMeasurements: measurements];

    return metric;
}


- (instancetype)init
{
    NSAssert(false, @"You must use initWithName:valued:options: to initialize a LibratoGagueMetric instance");
    self = nil;
    
    return nil;
}


- (instancetype)initWithName:(NSString *)name valued:(NSNumber *)value options:(NSDictionary *)options
{
    if ((self = [super initWithName:name valued:nil options:options]))
    {
        self.type = @"gauges";
    }

    return self;
}


#pragma mark - Calculations
- (void)calculateStatisticsFromMeasurements:(NSArray *)measurements
{
    _counter   = [measurements valueForKeyPath:@"@count.self"];
    _sum     = [measurements valueForKeyPath:@"@sum.value"];
    _max     = [measurements valueForKeyPath:@"@max.value"];
    _min     = [measurements valueForKeyPath:@"@min.value"];
    _squares = [measurements valueForKeyPath:@"@sum.squared"];
}


#pragma mark - MTLJSONSerializing
+ (NSDictionary *)JSONKeyPathsByPropertyKey
{
    return @{
        @"name": LibratoMetricNameKey,
        @"measureTime": LibratoMetricMeasureTimeKey,
        @"source": LibratoMetricSourceKey,
        @"count": countKey,
        @"sum": sumKey,
        @"min": minKey,
        @"max": maxKey,
        @"squares": squaresKey,
        @"type": NSNull.null,
        LibratoMetricValueKey: NSNull.null
    };
}


#pragma mark - Helpers
- (void)computeMeasurements:(NSArray *)measurements
{
    [self calculateStatisticsFromMeasurements:measurements];
}


@end
