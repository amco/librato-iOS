//
//  LibratoQueue.m
//  Librato-iOS
//
//  Created by Adam Yanalunas on 9/27/13.
//  Copyright (c) 2013 Amco International Education Services, LLC. All rights reserved.
//

#import "Librato.h"
#import "LibratoMetricCollection.h"
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
    if (!metrics) return self;
    
    // TODO: Clean up duplicate ways to add to the collection
    if ([metrics isKindOfClass:LibratoMetric.class])
    {
        LibratoMetric *metric = metrics;
        if (metric.measureTime)
        {
            [self checkMeasurementTime:metric];
        }
        
        LibratoMetricCollection *bucket = [self collectionNamed:metric.type];
        [bucket addMetric:metrics];
        return self;
    }
    
    NSArray *collection;
    if ([metrics isKindOfClass:NSArray.class])
    {
        collection = metrics;
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
            metric.measureTime = [NSDate dateWithTimeIntervalSince1970:self.class.epochTime];
        }

        // Sure, let's stack even more responsibility in this loop. What could possibly be bad about that?
        LibratoMetricCollection *bucket = [self collectionNamed:metric.type];
        [bucket addMetric:metric];
    }];

    [self submitCheck];

    return self;
}


- (LibratoMetricCollection *)collectionNamed:(NSString *)name
{
    if (![self.queued.allKeys containsObject:name])
    {
        [self.queued addEntriesFromDictionary:@{name: [LibratoMetricCollection collectionNamed:name]}];
    }
    
    return self.queued[name];
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
        // TODO: Well this is certainly some grief
        else if ([value respondsToSelector:@selector(enumerateObjectsUsingBlock:)])
        {
            // Could be array of NSDictionary, LibratoMetric, whatev. Sanitize again.
            [value enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                [self add:obj];
            }];
        }
        // TODO: Here's some more grief
        else if ([value isKindOfClass:LibratoMetricCollection.class])
        {
            [metrics addObjectsFromArray:((LibratoMetricCollection *)value).models];
        }
        else
        {
            metric = [LibratoMetric metricNamed:key valued:(NSNumber *)((NSDictionary *)value[@"value"]) options:value];
        }
        
        if (metric)
        {
            [metrics addObject:metric];
        }
    }];

    return metrics;
}


// TODO: Unused? Remove?
- (NSString *)separateTypeFromMetric:(LibratoMetric *)metric __deprecated
{
    // This is too responsible. Metric should take care of mutation and answering this question.
    NSString *name = metric.type;
    if (name.length == 0)
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
    [self.queued removeAllObjects];
}


- (void)flush
{
    [self clear];
}


- (NSArray *)gauges __deprecated
{
    return self.queued[@"gauges"] ?: NSArray.array;
}


- (LibratoQueue *)merge:(NSDictionary *)dictionary
{
    [dictionary enumerateKeysAndObjectsUsingBlock:^(NSString *key, LibratoMetricCollection *collection, BOOL *stop) {
        if (self.queued[key])
        {
            [((LibratoMetricCollection *)self.queued[key]).models addObjectsFromArray:collection.models];
        }
        else
        {
            self.queued[key] = collection;
        }
    }];
    
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
    [self.queued enumerateKeysAndObjectsUsingBlock:^(id key, LibratoMetricCollection *collection, BOOL *stop) {
        result += collection.models.count;
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
    return [NSString stringWithFormat:@"<%@: %p, queued: %i>", NSStringFromClass([self class]), self, self.size];
}


@end
