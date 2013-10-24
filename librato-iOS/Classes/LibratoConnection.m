//
//  LibratoConnection.m
//  Librato-iOS
//
//  Created by Adam Yanalunas on 9/26/13.
//  Copyright (c) 2013 Amco International Education Services, LLC. All rights reserved.
//

#import "LibratoConnection.h"
#import "LibratoClient.h"
#import "LibratoVersion.h"

NSString *const DEFAULT_API_ENDPOINT = @"https://metrics-api.librato.com";
NSString *const DEFAULT_API_VERSION = @"v1";

@implementation LibratoConnection

- (instancetype)initWithClient:(LibratoClient *)client usingEndpoint:(NSString *)endpoint
{
    if ((self = [super init]))
    {
        self.client = client;
        self.APIEndpoint = endpoint;
    }

    return self;
}


- (NSString *)userAgent
{
    if (self.client.customUserAgent)
    {
        return self.client.customUserAgent;
    }

    NSMutableArray *chunks = NSMutableArray.array;
    NSString *agentIdentifier = self.client.agentIdentifier;
    if (agentIdentifier && agentIdentifier.length) {
        [chunks addObject:agentIdentifier];
    }

    [chunks addObject:[NSString stringWithFormat:@"Librato-iOS/%@", LibratoVersion.version]];
    [chunks addObject:[self.platform componentsJoinedByString:@"; "]];

    return [chunks componentsJoinedByString:@" "];
}


- (NSArray *)platform
{
    // Cribbed from AFNetworking. Not necessary as AFNetworking automatically injects this?
    NSString *version = [NSString stringWithFormat:@"%@/%@ (%@; iOS %@; Scale/%0.2f)", [[[NSBundle mainBundle] infoDictionary] objectForKey:(__bridge NSString *)kCFBundleExecutableKey] ?: [[[NSBundle mainBundle] infoDictionary] objectForKey:(__bridge NSString *)kCFBundleIdentifierKey], (__bridge id)CFBundleGetValueForInfoDictionaryKey(CFBundleGetMainBundle(), kCFBundleVersionKey) ?: [[[NSBundle mainBundle] infoDictionary] objectForKey:(__bridge NSString *)kCFBundleVersionKey], [[UIDevice currentDevice] model], [[UIDevice currentDevice] systemVersion], ([[UIScreen mainScreen] respondsToSelector:@selector(scale)] ? [[UIScreen mainScreen] scale] : 1.0f)];;
    return @[version];
}


#pragma mark - Properties
- (NSString *)APIEndpoint
{
    if (!_APIEndpoint)
    {
        _APIEndpoint = DEFAULT_API_ENDPOINT;
    }

    return _APIEndpoint;
}

@end
