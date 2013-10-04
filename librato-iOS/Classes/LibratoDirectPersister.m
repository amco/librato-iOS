//
//  LibratoDirectPersister.m
//  Librato-iOS
//
//  Created by Adam Yanalunas on 9/27/13.
//  Copyright (c) 2013 Amco International Education Services, LLC. All rights reserved.
//

#import "LibratoClient.h"
#import "LibratoDirectPersister.h"

@implementation LibratoDirectPersister

- (BOOL)persistUsingClient:(LibratoClient *)client queued:(NSDictionary *)queued options:(NSDictionary *)options
{
    NSArray *requests;
    BOOL perRequest = ((NSNumber *)options[@"perRequest"]).boolValue;
    if (perRequest)
    {
        // TODO: Implement
        @throw [NSException exceptionWithName:@"Not implemented" reason:@"Chunking not yet supported by this persister" userInfo:nil];
    }
    else
    {
        requests = @[queued];
    }

    [requests enumerateObjectsUsingBlock:^(NSDictionary *metricData, NSUInteger idx, BOOL *stop) {
        [client sendPayload:metricData withSuccess:^(NSDictionary *JSON, NSUInteger code) {
            NSLog(@"WE HAVE WON. %@", JSON);
        } orFailure:^(NSError *error, NSDictionary *JSON) {
            NSLog(@"LOST THE WAR. %@", error);
        }];
    }];
    return YES;
}

@end
