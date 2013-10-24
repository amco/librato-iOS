//
//  LibratoProcessor.m
//  Librato-iOS
//
//  Created by Adam Yanalunas on 9/26/13.
//  Copyright (c) 2013 Amco International Education Services, LLC. All rights reserved.
//

#import "LibratoClient.h"
#import "LibratoMetric.h"
#import "LibratoQueue.h"
#import "LibratoPersister.h"
#import "LibratoProcessor.h"

static NSUInteger MEASUREMENTS_PER_REQUEST = 500;
static NSTimeInterval MINIMUM_AUTOSUBMIT_INTERVAL = 1;
static NSTimeInterval SECONDS_BETWEEN_AUTOSUBMITS = 5;

@interface LibratoProcessor ()


@end

@implementation LibratoProcessor

#pragma mark - Lifecycle
- (void)dealloc
{
    if (self.autoSubmitTimer)
    {
        [self.autoSubmitTimer invalidate];
    }
}


#pragma mark - Submission
- (BOOL)submit
{
    if (self.queued.count == 0)
    {
        return true;
    }

    NSDictionary *options = @{@"per_request": @(self.perRequest)};
    BOOL persisted = NO;

    @try
    {
        persisted = [self.persister persistUsingClient:_client queued:self.queued options:options];
    }
    @catch (NSException *exception)
    {
        // TODO: Catch, clean and re-raise error?
    }

    if (persisted)
    {
        // Clear queue?
        _lastSubmitTime = NSDate.date;
    }

    return persisted;
}


// TODO: Refactor to be extension of operation, not accept block
- (LibratoMetric *)time:(TimedExecutionBlock)block named:(NSString *)name options:(NSDictionary *)options
{
    NSDate *start = NSDate.date;
    block();
    NSTimeInterval duration  = [NSDate.date timeIntervalSinceDate:start];

    return [LibratoMetric metricNamed:name valued:@(duration) options:options];
}


#pragma mark - Private
- (id<LibratoPersister>)createPersister
{
    NSString *type = [NSString stringWithFormat:@"Librato%@Persister", _client.persistence.capitalizedString];
    return NSClassFromString(type).new;
}

+ (NSTimeInterval)epochTime
{
    return [NSDate.date timeIntervalSince1970];
}


- (void)setupCommonOptions:(NSDictionary *)options
{
    self.autosubmitInterval = (options[@"autosubmitInterval"] ? ((NSNumber *)options[@"autosubmitInterval"]).doubleValue : SECONDS_BETWEEN_AUTOSUBMITS);
    self.autoSubmitTimer = [NSTimer timerWithTimeInterval:MINIMUM_AUTOSUBMIT_INTERVAL target:self selector:@selector(handleTimer:) userInfo:nil repeats:YES];
    [NSRunLoop.currentRunLoop addTimer:self.autoSubmitTimer forMode:NSDefaultRunLoopMode];
    self.client = options[@"client"] ?: LibratoClient.new;
    _perRequest = options[@"perRequest"] ? ((NSNumber *)options[@"perRequest"]).integerValue : MEASUREMENTS_PER_REQUEST;
    self.source = options[@"source"];
    self.measureTime = options[@"measureTime"];
    self.createTime = NSDate.date;
    self.clearOnFailure = ((NSNumber *)options[@"cleaerOnFailure"]).boolValue;
    self.prefix = options[@"prefix"] ?: @"";
    self.queued = options[@"queued"] ?: NSMutableDictionary.dictionary;
}


- (void)handleTimer:(NSTimer *)timer
{
    [self autosubmitCheck];
}


- (void)autosubmitCheck
{
    if (self.autosubmitInterval)
    {
        NSDate *last = self.lastSubmitTime ?: self.createTime;
        if ([NSDate.date timeIntervalSinceDate:last] >= self.autosubmitInterval)
        {
            [self submit];
        }
    }
}


#pragma mark - Properties
- (LibratoClient *)client
{
    if (_client)
    {
        _client = LibratoClient.new;
    }

    return _client;
}


- (id<LibratoPersister>)persister
{
    if (!_persister && _client)
    {
        _persister = [self createPersister];
    }

    return _persister;
}


@end
