//
//  LibratoDirectPersister.m
//  Librato-iOS
//
//  Created by Adam Yanalunas on 9/27/13.
//  Copyright (c) 2013 Amco International Education Services, LLC. All rights reserved.
//

#import "LibratoClient.h"
#import "LibratoDirectPersister.h"
#import "LibratoMetricCollection.h"

@implementation LibratoDirectPersister

- (BOOL)persistUsingClient:(LibratoClient *)client queued:(NSDictionary *)queued options:(NSDictionary *)options
{
    NSArray *requests;
    BOOL perRequest = ((NSNumber *)options[@"perRequest"]).boolValue;
    if (perRequest)
    {
        @throw LibratoNotImplementedException.exception;
    }
    else
    {
        NSMutableDictionary *jsonRequests = @{}.mutableCopy;
        [queued enumerateKeysAndObjectsUsingBlock:^(NSString *key, LibratoMetricCollection *collection, BOOL *stop) {
            jsonRequests[key] = collection.toJSON;
        }];
        requests = @[jsonRequests];
    }

    [requests enumerateObjectsUsingBlock:^(NSDictionary *metricData, NSUInteger idx, BOOL *stop) {
        [client sendPayload:metricData withSuccess:^(NSDictionary *JSON, NSUInteger code) {
            // TODO: Hook for success block
        } orFailure:^(NSError *error, NSDictionary *JSON) {
            // TODO: Hook for failure block
        }];
    }];
    
    return YES;
}

@end
