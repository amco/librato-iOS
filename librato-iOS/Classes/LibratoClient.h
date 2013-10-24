//
//  LibratoClient.h
//  Librato-iOS
//
//  Created by Adam Yanalunas on 9/26/13.
//  Copyright (c) 2013 Amco International Education Services, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AFNetworking/AFNetworking.h>
#import "LibratoPersister.h"

typedef void (^ClientSuccessBlock)(NSDictionary *JSON, NSUInteger code);
typedef void (^ClientFailureBlock)(NSError *error, NSDictionary *JSON);

@class LibratoConnection, LibratoQueue;

@interface LibratoClient : AFHTTPClient

@property (nonatomic, copy) NSString *agentIdentifier;
@property (nonatomic, copy) NSString *APIEndpoint;
@property (nonatomic, copy) NSString *archivePath;
@property (nonatomic, strong) LibratoConnection *connection;
@property (nonatomic, assign, getter = isOnline) BOOL online;
@property (nonatomic, strong) NSString *persistence;
@property (nonatomic, strong) id<LibratoPersister> persister;
@property (nonatomic, strong) LibratoQueue *queue;
@property (nonatomic, copy) ClientSuccessBlock submitSuccessBlock;
@property (nonatomic, copy) ClientFailureBlock submitFailureBlock;

- (void)authenticateEmail:(NSString *)emailAddress APIKey:(NSString *)apiKey;
- (void)getMetric:(NSString *)name options:(NSDictionary *)options;
- (void)getMeasurements:(NSString *)named options:(NSDictionary *)options;
- (NSDictionary *)metrics;
- (void)sendPayload:(NSDictionary *)payload;
- (void)sendPayload:(NSDictionary *)payload withSuccess:(ClientSuccessBlock)success orFailure:(ClientFailureBlock)failure;
- (void)submit:(id)metrics;
- (void)updateMetricsNamed:(NSString *)name options:(NSDictionary *)options;
- (void)updateMetrics:(NSDictionary *)metrics;

- (void)flushAuthentication;
- (NSString *)customUserAgent;
- (void)setCustomUserAgent:(NSString *)userAgent;

@end
