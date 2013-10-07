//
//  LibratoQueue.m
//  Librato-iOS
//
//  Created by Adam Yanalunas on 9/27/13.
//  Copyright (c) 2013 Amco International Education Services, LLC. All rights reserved.
//

#import "Librato.h"
#import "LibratoQueue.h"
#import "LibratoMetric.h"

NSString *const QueueAutosubmitCountKey = @"autosubmitCount";
NSString *const QueueSkipMeasurementTimesKey = @"skipMeasurementTimes";

@interface LibratoQueue ()

@property (nonatomic) NSUInteger autosubmitCount;
@property (nonatomic) BOOL skipMeasurementTimes;

@end

@implementation LibratoQueue

- (instancetype)initWithOptions:(NSDictionary *)options
{
    self = [super init];

    if (options.count)
    {
        self.autosubmitCount = ((NSNumber *)options[QueueAutosubmitCountKey]).integerValue;
        self.skipMeasurementTimes = ((NSNumber *)options[QueueSkipMeasurementTimesKey]).boolValue;
        [self setupCommonOptions:options];
    }

    return self;
}


- (LibratoQueue *)add:(id)metrics
{
    NSArray *collection;
    if ([metrics isKindOfClass:NSArray.class])
    {
        collection = metrics;
    }
    else if ([metrics isKindOfClass:LibratoMetric.class])
    {
        collection = @[metrics];
    }
    else if ([metrics isKindOfClass:NSDictionary.class])
    {
        collection = [self createMetricsFromDictionary:metrics];
    }

    [collection enumerateObjectsUsingBlock:^(LibratoMetric *metric, NSUInteger idx, BOOL *stop) {
        if (self.prefix)
        {
            metric.name = [NSString stringWithFormat:@"%@.%@", self.prefix, metric.name];
        }

        if (metric.measureTime)
        {
            [self checkMeasurementTime:metric];
        }
        else if (![self skipMeasurementTimes])
        {
            // Should probably just default to epochTime when a Metric is created
            metric.measureTime = [NSDate dateWithTimeIntervalSince1970:self.epochTime];
        }

        // Sure, let's stack even more responsibility in this loop. What could possibly be bad about that?
        if (![self.queued.allKeys containsObject:metric.type])
        {
            [self.queued addEntriesFromDictionary:@{metric.type: NSMutableArray.array}];
        }

        [(NSMutableArray *)[self.queued objectForKey:metric.type] addObject:metric.JSON];
    }];

    [self submitCheck];

    return self;
}


- (NSArray *)createMetricsFromDictionary:(NSDictionary *)data
{
    NSMutableArray *metrics = NSMutableArray.array;

    [data enumerateKeysAndObjectsUsingBlock:^(NSString *key, id value, BOOL *stop) {
        LibratoMetric *metric;

        // TODO: This is going to cause me grief
        if ([value isKindOfClass:NSNumber.class])
        {
            metric = [LibratoMetric metricNamed:key valued:value options:nil];
        }
        else
        {
            metric = [LibratoMetric metricNamed:key valued:(NSNumber *)((NSDictionary *)value[@"value"]) options:value];
        }

        [metrics addObject:metric];
    }];

    return metrics;
}


- (NSString *)separateTypeFromMetric:(LibratoMetric *)metric
{
    // This is too responsible. Metric should take care of mutation and answering this question.
    NSString *typeKey = @"type";
    NSString *name = metric.data[typeKey];
    if (name)
    {
        [metric.data removeObjectForKey:typeKey];
    }
    else
    {
        name = @"gauges";
    }

    return name;
}


- (NSArray *)counters
{
    return self.queued[@"counters"] ?: NSArray.array;
}


- (BOOL)isEmpty
{
    return _queued.count == 0;
}


- (void)clear
{
    self.queued = NSMutableDictionary.dictionary;
}


- (void)flush
{
    [self clear];
}


- (NSArray *)gauges
{
    return self.queued[@"gauges"] ?: NSArray.array;
}


- (LibratoQueue *)merge
{

    return self;
}


- (NSMutableDictionary *)queued
{
    if (!_queued)
    {
        _queued = NSMutableDictionary.dictionary;
        
        if (self.source)
        {
            _queued[@"source"] = self.source;
        }

        if (self.measureTime)
        {
            _queued[@"measureTime"] = self.measureTime;
        }
    }

    return _queued;
}


- (NSUInteger)size
{
    __block NSUInteger result = 0;
    [self.queued enumerateKeysAndObjectsUsingBlock:^(id key, id data, BOOL *stop) {
        result += [data count];
    }];

    return result;
}


- (NSUInteger)length
{
    return self.size;
}


#pragma mark - Private
- (void)checkMeasurementTime:(LibratoMetric *)metric
{
    if(![self minimumTimeIsBeforeMetricTime:metric])
    {
        @throw [LibratoInvalidDataException exceptionWithReason:[NSString stringWithFormat:NSLocalizedStringFromTable(@"EXCEPTION_REASON_INVALID_DATA_DATE_OUT_OF_BOUNDS_TEMPLATE", LIBRATO_LOCALIZABLE, nil), metric.measureTime]];
    }
}


- (BOOL)minimumTimeIsBeforeMetricTime:(LibratoMetric *)metric
{
    return ([metric.measureTime compare:Librato.minimumMeasureTime] == NSOrderedDescending);
}


- (NSArray *)reconcileMeasurements:(NSArray *)measurements forSource:(NSString *)source
{
    if (!source || [self.source isEqualToString:source])
    {
        return measurements;
    }

    NSMutableArray *results = [NSMutableArray arrayWithCapacity:measurements.count];
    [results addObjectsFromArray:measurements];
    [results enumerateObjectsUsingBlock:^(LibratoMetric *metric, NSUInteger idx, BOOL *stop) {
        if (!metric.source)
        {
            metric.source = source;
        }
    }];

    return results;
}


- (void)submitCheck
{
    [self autosubmitCheck];
    if (self.autosubmitCount && self.length >= self.autosubmitCount)
    {
        [self submit];
    }
}


- (NSString *)description
{
    return [NSString stringWithFormat:@"<%@: %p, queued: %i>", NSStringFromClass([self class]), self, self.queued.count];
}


@end
