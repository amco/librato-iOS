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
    metric.measurements = measurements;

    return metric;
}


- (instancetype)initWithName:(NSString *)name valued:(NSNumber *)value options:(NSDictionary *)options
{
    if ((self = [super initWithName:name valued:nil options:options]))
    {
        self.type = @"gauges";
        [self.data removeObjectForKey:LibratoMetricValueKey];
    }

    return self;
}


#pragma mark - Calculations
- (void)calculateStatisticsFromMeasurements:(NSArray *)measurements
{
    self.data[countKey]   = [measurements valueForKeyPath:@"@count.self"];
    self.data[sumKey]     = [measurements valueForKeyPath:@"@sum.value"];
    self.data[maxKey]     = [measurements valueForKeyPath:@"@max.value"];
    self.data[minKey]     = [measurements valueForKeyPath:@"@min.value"];
    self.data[squaresKey] = [measurements valueForKeyPath:@"@sum.squared"];
}


#pragma mark - Properties
- (void)setMeasurements:(NSArray *)measurements
{
    if (measurements)
    {
        // TODO: TO have to remove this is a logic flow fault. Clean up in parent.
        [self.data removeObjectForKey:@"value"];
        [self calculateStatisticsFromMeasurements:measurements];
    }
    else
    {
        [self.data removeObjectsForKeys:@[countKey, sumKey, maxKey, minKey, squaresKey]];
    }
}


@end
