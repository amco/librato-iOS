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
    
    [LibratoDemoEventTracker.sharedInstance submit:simpleMetric];
}


/*
 Creates two different metrics but submits them simultaneously
*/
- (void)multipleMetricSubmissionExample
{
    LibratoMetric *memoryMetric  = [LibratoMetric metricNamed:@"memory.available" valued:self.randomNumber options:nil];
    LibratoMetric *storageMetric = [LibratoMetric metricNamed:@"storage.available" valued:self.randomNumber options:nil];
    
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
 Uses the group helper to build a number of metrics under a common namespace.
 Different than setting the global namespace as this is only used for this group of metrics and the global namespace will automatically be applied to these as well.
 Metrics will be created in the order they are entered in the dictionary hash.
 
 The group prefix is the first argument and is joined to each metric named with a period.
 The dictionary's key value is the metric name as an NSString and the value is an NSNumber value.
 
 If the group is named "foo" and the first metric is named "bar" it will be submitted with the name "foo.bar"
*/
- (void)groupDictionaryExample
{
    NSDictionary *valueDict = @{
                                @"repos": @32,
                                @"stars": @331,
                                @"friends": @172
                                };
    NSArray *metrics = [LibratoDemoEventTracker.sharedInstance groupNamed:@"user" valued:valueDict];
    [LibratoDemoEventTracker.sharedInstance submit:metrics];
}


/*
 Provides a Librato context that automatically namespaces any metrics created within that context.
*/
- (void)groupContextExample
{
    [LibratoDemoEventTracker.sharedInstance groupNamed:@"user" context:^(Librato *l) {
        LibratoMetric *logins = [LibratoMetric metricNamed:@"logins" valued:@12 options:nil];
        LibratoMetric *logouts = [LibratoMetric metricNamed:@"logouts" valued:@7 options:nil];
        LibratoMetric *timeouts = [LibratoMetric metricNamed:@"timeouts" valued:@5 options:nil];
        [l submit:@[logins, logouts, timeouts]];
    }];
}


/*
 Provide the name of a notification and that notification will come into the block's context when it's caught.
 Contexts are executed asynchronously in a Librato-specific serial queue.
 A subscription with block is used and returned so you're responsible for unsubscribing when appropriate!
*/
- (void)notificationExample
{
    __weak Librato *weakDemo = LibratoDemoEventTracker.sharedInstance;
    id subscription = [LibratoDemoEventTracker.sharedInstance listenForNotification:@"state.sleeping" context:^(NSNotification *notification) {
        LibratoMetric *useName = [LibratoMetric metricNamed:notification.name valued:@100 options:nil];
        LibratoMetric *useInfo = [LibratoMetric metricNamed:notification.userInfo[@"name"] valued:notification.userInfo[@"value"] options:notification.userInfo];
        
        [weakDemo submit:@[useName, useInfo]];
    }];
    
    [NSNotificationCenter.defaultCenter postNotificationName:@"state.sleeping" object:nil userInfo:@{
                                                                                                     @"name": @"infoName",
                                                                                                     @"value": @42
                                                                                                     }];
    
    // Don't forget to remove your subscriptions when you're done lest they hang around and point to a nil object!
    [NSNotificationCenter.defaultCenter removeObserver:subscription];
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
    LibratoGaugeMetric *bagelGuage = [LibratoGaugeMetric metricNamed:@"bagel_guage" measurements:bagels];
    
    [LibratoDemoEventTracker.sharedInstance submit:bagelGuage];
}


/*
 You can add a custom string the User Agent sent with all of the Librato requests
 WARNING: Setting a custom UA will reset your client's connection so do not do this arbitrarily
*/
- (void)customUAExample
{
    Librato *l = LibratoDemoEventTracker.sharedInstance;
    l.customUserAgent = @"Demo UA";
    
    [l submit:@{@"ua.custom.instances": @1}];
}


/*
 Metrics can be created with increasing levels of specificity
 There are helpers for simple name & value metrics all the way up to all arguments specified
*/
- (void)metricCreationHelpersExample
{
    LibratoMetric *basic = [LibratoMetric metricNamed:@"basic" valued:@1];
    LibratoMetric *explicit = [LibratoMetric metricNamed:@"explicit" valued:@100 source:@"demo" measureTime:NSDate.date];
    LibratoMetric *custom = [LibratoMetric metricNamed:@"custom" valued:@50 options:@{@"source": @"demo"}];
    
    [LibratoDemoEventTracker.sharedInstance submit:@[basic, explicit, custom]];
}


#pragma mark - Helpers
- (NSNumber *)randomNumber
{
    return @(abs(rand() % 100));
}


@end
