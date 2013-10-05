//
//  LibratoClient.m
//  Librato-iOS
//
//  Created by Adam Yanalunas on 9/26/13.
//  Copyright (c) 2013 Amco International Education Services, LLC. All rights reserved.
//

#import "LibratoClient.h"
#import "LibratoConnection.h"
#import "LibratoQueue.h"

NSString *const DEFAULT_API_ENDPIONT = @"https://metrics-api.librato.com/v1";
NSString *email;
NSString *APIKey;

@interface LibratoClient ()

@property (nonatomic, strong) NSString *userAgent;

@end

@implementation LibratoClient

- (instancetype)init
{
    self = [self initWithBaseURL:[NSURL URLWithString:DEFAULT_API_ENDPIONT]];
    [self setDefaultHeader:@"Accept" value:@"application/json"];
    self.parameterEncoding = AFJSONParameterEncoding;

    return self;
}

// TODO: Implelement
- (NSString *)agentIdentifier
{
    return @"";
}


- (void)authenticateEmail:(NSString *)emailAddress APIKey:(NSString *)apiKey
{
    [self flushAuthentication];
    email = emailAddress;
    APIKey = apiKey;
}


- (void)getMetric:(NSString *)name options:(NSDictionary *)options
{
    NSMutableDictionary *query = options.mutableCopy;
    if ([query[@"startTime"] isKindOfClass:NSDate.class])
    {
        query[@"startTime"] = @(((NSDate *)query[@"startTime"]).timeIntervalSince1970);
    }

    if ([query[@"endTime"] isKindOfClass:NSDate.class])
    {
        query[@"endTime"] = @(((NSDate *)query[@"endTime"]).timeIntervalSince1970);
    }

    __block ClientSuccessBlock success;
    if (query[@"success"])
    {
        success = [query[@"success"] copy];
        [query removeObjectForKey:@"success"];
    }

    __block ClientFailureBlock failure;
    if (query[@"failure"])
    {
        failure = [query[@"failure"] copy];
        [query removeObjectForKey:@"failure"];
    }

    if (query.count)
    {
        query[@"resolution"] = query[@"resolution"] ?: @(1);
    }

    NSURLRequest *request = [self requestWithMethod:@"GET" path:[NSString stringWithFormat:@"metrics/%@", name] parameters:query];

    AFJSONRequestOperation *op = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        if (success)
        {
            success(JSON, response.statusCode);
        }
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
        if (failure) {
            failure(error, JSON);
        }
    }];

    dispatch_async(dispatch_get_main_queue(), ^{
        [op start];
    });
}


- (void)getMeasurements:(NSString *)named options:(NSDictionary *)options
{
    if (![options.allKeys containsObject:@"startTime"] || !options.count)
    {
        @throw [LibratoInvalidDataException exceptionWithReason:NSLocalizedStringFromTable(@"EXCEPTION_REASON_INVALID_DATA_MISSING_START_OR_COUNT", LIBRATO_LOCALIZABLE, nil)];
    }

    if (![options.allKeys containsObject:@"success"])
    {
        @throw [LibratoInvalidDataException exceptionWithReason:NSLocalizedStringFromTable(@"EXCEPTION_REASON_INVALID_DATA_MISSING_SUCCESS_BLOCK", LIBRATO_LOCALIZABLE, nil)];
    }

    NSMutableDictionary *query = options.mutableCopy;
    ClientSuccessBlock wrappedSuccess = ^(NSDictionary *JSON, NSUInteger code) {
        if ([JSON.allKeys containsObject:@"measurements"]) {
            ((ClientSuccessBlock)options[@"success"])(JSON[@"measurements"], code);
        }
    };
    query[@"success"] = [wrappedSuccess copy];

    [self getMetric:named options:query];
}


- (void)setUser:(NSString *)user andToken:(NSString *)token
{
    [self clearAuthorizationHeader];
    [self setAuthorizationHeaderWithUsername:user password:token];
}


- (void)sendPayload:(NSDictionary *)payload withSuccess:(ClientSuccessBlock)success orFailure:(ClientFailureBlock)failure
{
    [self setUser:email andToken:APIKey];
    NSURLRequest *request = [self requestWithMethod:@"POST" path:@"metrics" parameters:payload];
    AFJSONRequestOperation *op = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        if (success)
        {
            success(JSON, response.statusCode);
        }
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
        if (failure) {
            failure(error, JSON);
        }
    }];

    dispatch_async(dispatch_get_main_queue(), ^{
        [op start];
    });
}


- (void)flushAuthentication
{
    email = nil;
    APIKey = nil;
    _connection = nil;
}


- (NSDictionary *)metrics
{
    // TODO: Implement
    return NSDictionary.dictionary;
}


- (NSDictionary *)list __deprecated
{
    return self.metrics;
}


- (LibratoQueue *)newQueue:(NSDictionary *)options
{
    NSMutableDictionary *opts = options.mutableCopy;
    opts[@"client"] = self;

    return [LibratoQueue.alloc initWithOptions:opts];
}


- (NSString *)persistence
{
    if (!_persistence)
    {
        _persistence = @"Direct";
    }

    return _persistence;
}


- (id<LibratoPersister>)persister
{
    return (self.queue ? self.queue.persister : nil);
}


#pragma mark - Network
- (void)submit:(id)metrics
{
    [self.queue add:metrics];
    [self.queue submit];
}


- (void)updateMetricsNamed:(NSString *)name options:(NSDictionary *)options
{
    NSMutableDictionary *query = options.mutableCopy;
    NSURLRequest *request = [self requestWithMethod:@"PUT" path:[NSString stringWithFormat:@"metrics/%@", name] parameters:options];

    __block ClientSuccessBlock success;
    if (query[@"success"])
    {
        success = [query[@"success"] copy];
        [query removeObjectForKey:@"success"];
    }

    __block ClientFailureBlock failure;
    if (query[@"failure"])
    {
        failure = [query[@"failure"] copy];
        [query removeObjectForKey:@"failure"];
    }

    AFJSONRequestOperation *op = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        if (success)
        {
            success(JSON, response.statusCode);
        }
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
        if (failure) {
            failure(error, JSON);
        }
    }];

    dispatch_async(dispatch_get_main_queue(), ^{
        [op start];
    });
}


- (void)updateMetrics:(NSDictionary *)metrics
{
    @throw [LibratoNotImplementedException exceptionWithReason:[NSString stringWithFormat:NSLocalizedStringFromTable(@"EXCEPTION_REASON_NOT_IMPLEMENTED_TEMPLATE", LIBRATO_LOCALIZABLE, nil), NSStringFromSelector(_cmd)]];
}


#pragma mark - Properties
- (NSString *)APIEndpoint
{
    if (!_APIEndpoint)
    {
        _APIEndpoint = DEFAULT_API_ENDPIONT;
    }

    return _APIEndpoint;
}


- (LibratoConnection *)connection
{
    if (!_connection) {
        if (!email || !APIKey)
        {
            @throw [LibratoInvalidDataException exceptionWithReason:NSLocalizedStringFromTable(@"EXCEPTION_REASON_INVALID_DATA_MISSING_CREDENTIALS", LIBRATO_LOCALIZABLE, nil)];
        }

        _connection = [LibratoConnection.alloc initWithClient:self usingEndpoint:self.APIEndpoint];
    }

    return _connection;
}


- (NSString *)customUserAgent
{
    return self.userAgent;
}


- (void)setCustomUserAgent:(NSString *)userAgent
{
    self.userAgent = userAgent;
    _connection = nil;
}


- (LibratoQueue *)queue
{
    if (!_queue)
    {
        _queue = [LibratoQueue.alloc initWithOptions:@{@"client": self, QueueSkipMeasurementTimesKey: @YES, QueueSkipMeasurementTimesKey: @YES}];
    }

    return _queue;
}


- (NSString *)description
{
    return [NSString stringWithFormat:@"<%@: %p, persister: %@, queued: %i>", NSStringFromClass([self class]), self, self.persister, self.queue.queued.count];
}



@end
