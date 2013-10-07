//
//  LibratoDemoEventTracker.m
//  librato-iOS Demo
//
//  Created by Adam Yanalunas on 10/7/13.
//  Copyright (c) 2013 Amco International Education Services, LLC. All rights reserved.
//

#import "LibratoDemoEventTracker.h"
#import "Librato.h"


NSString *const libratoEmail  = @"<Librato email>";
NSString *const libratoToken  = @"<Librato token>";
NSString *const libratoPrefix = @"demo";


@interface LibratoDemoEventTracker ()

- (NSNumber *)randomNumber;

@end


@implementation LibratoDemoEventTracker


#pragma mark - Lifecycle
/*
 Simple non-threadsafe singleton creator
*/
+ (Librato *)sharedInstance
{
    static dispatch_once_t onceToken;
    static Librato *_librato;
    
    dispatch_once(&onceToken, ^{
        _librato = [Librato.alloc initWithEmail:libratoEmail token:libratoToken prefix:libratoPrefix];
    });
    
    return _librato;
}


#pragma mark - Examples
/*
 Creates a "counter" metric and shows that you can change values via the options or with property accessors
*/
- (void)counterMetricExample
{
    LibratoMetric *simpleMetric = [LibratoMetric metricNamed:@"works" valued:self.randomNumber options:@{@"source": @"demo app"}];
    simpleMetric.measureTime = [NSDate dateWithTimeIntervalSinceNow:-(3600 * 24)];
    
    NSLog(@"%@", simpleMetric);
    
    [LibratoDemoEventTracker.sharedInstance submit:simpleMetric];
}


/*
 Creates two different metrics but submits them simultaneously
*/
- (void)multipleMetricSubmissionExample
{
    LibratoMetric *memoryMetric  = [LibratoMetric metricNamed:@"memory.available" valued:self.randomNumber options:nil];
    LibratoMetric *storageMetric = [LibratoMetric metricNamed:@"storage.available" valued:self.randomNumber options:nil];
    
    NSLog(@"%@", memoryMetric);
    NSLog(@"%@", storageMetric);
    
    [LibratoDemoEventTracker.sharedInstance submit:@[memoryMetric, storageMetric]];
}


/*
 Creates and auto-submits two counter metrics: "meaning" and "plutonium", the latter using an NSDictionary to set the value and source simultaneously
*/
- (void)dictionaryCreationExample
{
    [LibratoDemoEventTracker.sharedInstance submit:@{@"meaning": self.randomNumber, @"plutonium": @{@"value": @238, @"source": @"Russia, with love"}}];
}


/*
 Creates a series of counter measurements and submits them as a gague metric
*/
- (void)gaugeMetricExample
{
    LibratoMetric *metric1 = [LibratoMetric metricNamed:@"bagels" valued:self.randomNumber options:nil];
    LibratoMetric *metric2 = [LibratoMetric metricNamed:@"bagels" valued:self.randomNumber options:nil];
    LibratoMetric *metric3 = [LibratoMetric metricNamed:@"bagels" valued:self.randomNumber options:nil];
    LibratoMetric *metric4 = [LibratoMetric metricNamed:@"bagels" valued:self.randomNumber options:nil];
    LibratoMetric *metric5 = [LibratoMetric metricNamed:@"bagels" valued:self.randomNumber options:nil];
    LibratoMetric *metric6 = [LibratoMetric metricNamed:@"bagels" valued:self.randomNumber options:nil];
    LibratoMetric *metric7 = [LibratoMetric metricNamed:@"bagels" valued:self.randomNumber options:nil];
    LibratoMetric *metric8 = [LibratoMetric metricNamed:@"bagels" valued:@0 options:nil];
    
    NSArray *bagels = @[metric1, metric2, metric3, metric4, metric5, metric6, metric7, metric8];
    NSLog(@"%@", bagels);
    LibratoGaugeMetric *bagelGuage = [LibratoGaugeMetric metricNamed:@"bagel_guage" measurements:bagels];
    
    [LibratoDemoEventTracker.sharedInstance submit:bagelGuage];
}


#pragma mark - Helpers
- (NSNumber *)randomNumber
{
    return @(abs(rand() % 100));
}


@end
