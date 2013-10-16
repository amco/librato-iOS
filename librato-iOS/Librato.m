//
//  Librato.m
//  Librato-iOS
//
//  Created by Adam Yanalunas on 9/30/13.
//  Copyright (c) 2013 Amco International Education Services, LLC. All rights reserved.
//

#import "Librato.h"
#import "LibratoClient.h"
#import "LibratoConnection.h"
#import "LibratoPersister.h"
#import "LibratoQueue.h"
#import "LibratoDirectPersister.h"

NSString *const LIBRATO_LOCALIZABLE = @"Librato-Localizable";

@implementation Librato

#pragma mark - Class methods
+ (NSDate *)minimumMeasureTime
{
    return [NSDate.date dateByAddingTimeInterval:-(3600*24*365)];
}


#pragma mark - Lifecycle
- (instancetype)initWithEmail:(NSString *)email token:(NSString *)apiKey prefix:(NSString *)prefix
{
    if((self = [super init]))
    {
        self.prefix = prefix ?: @"";
        self.queue = dispatch_queue_create("LibratoQueue", NULL);
        [self authenticateEmail:email APIKey:apiKey];
    }

    return self;
}


- (LibratoClient *)client
{
    if (!_client)
    {
        _client = LibratoClient.new;
        _client.queue = [LibratoQueue.alloc initWithOptions:@{@"client": _client, @"prefix": self.prefix}];
    }
    
    return _client;
}


#pragma mark - Setup
- (void)authenticateEmail:(NSString *)emailAddress APIKey:(NSString *)apiKey
{
    [self.client authenticateEmail:emailAddress APIKey:apiKey];
}


#pragma mark - Property accessors
- (NSString *)APIEndpoint
{
    return self.client.APIEndpoint;
}


- (void)setAPIEndpoint:(NSString *)APIEndpoint
{
    self.client.APIEndpoint = APIEndpoint;
}


- (LibratoConnection *)connection
{
    return self.client.connection;
}


- (NSString *)customUserAgent
{
    return self.client.customUserAgent;
}


- (void)setCustomUserAgent:(NSString *)userAgent
{
    self.client.customUserAgent = userAgent;
}


- (NSString *)persistence
{
    return self.client.persistence;
}


- (void)setPersistence:(NSString *)persistence
{
    self.client.persistence = persistence;
}


- (id<LibratoPersister>)persister
{
    return self.client.persister;
}


- (void)getMetric:(NSString *)name options:(NSDictionary *)options
{
    [self.client getMetric:name options:options];
}


- (void)getMeasurements:(NSString *)named options:(NSDictionary *)options
{
    [self.client getMeasurements:named options:options];
}


- (void)updateMetricsNamed:(NSString *)name options:(NSDictionary *)options
{
    [self.client updateMetricsNamed:name options:options];
}


- (void)updateMetrics:(NSDictionary *)metrics
{
    [self.client updateMetrics:metrics];
}


#pragma mark - Helpers
- (NSArray *)groupNamed:(NSString *)name valued:(NSDictionary *)values
{
    __block NSMutableArray *metrics = NSMutableArray.array;
    __block LibratoMetric *metric;
    [values enumerateKeysAndObjectsUsingBlock:^(NSString *entry, NSNumber *value, BOOL *stop) {
        metric = [LibratoMetric metricNamed:[NSString stringWithFormat:@"%@.%@", name, entry] valued:value options:nil];
        [metrics addObject:metric];
    }];
    
    return metrics;
}


- (NSArray *)groupNamed:(NSString *)name context:(LibratoMetricContext)context
{
    NSString *originalPrefix = self.client.queue.prefix;
    self.client.queue.prefix = (originalPrefix.length ? [NSString stringWithFormat:@"%@.%@", originalPrefix, name] : name);
    context(self);
    self.client.queue.prefix = originalPrefix;
    [self submit:nil];
}


- (id)listenForNotification:(NSString *)named context:(LibratoNotificationContext)context
{
    // TODO: Investigate using NSOperationQueue subclass instead of GCD inside of block.
    // https://developer.apple.com/library/ios/featuredarticles/Short_Practical_Guide_Blocks/index.html#//apple_ref/doc/uid/TP40009758-CH1-SW33
    id subscription = [NSNotificationCenter.defaultCenter addObserverForName:named object:nil queue:nil usingBlock:^(NSNotification *note) {
        dispatch_async(self.queue, ^{
            context(note);
        });
    }];
    
    return subscription;
}


#pragma mark - Submission
- (void)submit:(id)metrics
{
    [self.client submit:metrics];
}


#pragma mark - Overrides
- (NSString *)description
{
    return [NSString stringWithFormat:@"<%@: %p, persister: %@, prefix: %@>", NSStringFromClass([self class]), self, self.client.persister, self.prefix];
}


@end
