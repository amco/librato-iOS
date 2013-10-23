//
//  Librato.h
//  Librato-iOS
//
//  Created by Adam Yanalunas on 9/30/13.
//  Copyright (c) 2013 Amco International Education Services, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LibratoException.h"
#import "LibratoGaugeMetric.h"
#import "LibratoMetric.h"
#import "LibratoPersister.h"
#import "LibratoClient.h"


extern NSString *const LIBRATO_LOCALIZABLE;


@class LibratoConnection, LibratoClient;


@interface Librato : NSObject


typedef void (^LibratoMetricContext)(Librato *librato);
typedef void (^LibratoNotificationContext)(NSNotification *notification);


@property (nonatomic, strong) LibratoClient *client;
@property (nonatomic, strong) NSString *prefix;
@property (nonatomic, strong) dispatch_queue_t queue;

+ (NSDate *)minimumMeasureTime;

- (instancetype)initWithEmail:(NSString *)email token:(NSString *)apiKey prefix:(NSString *)prefix;

- (LibratoClient *)client;
- (void)add:(id)metrics;
- (void)authenticateEmail:(NSString *)emailAddress APIKey:(NSString *)apiKey;
- (NSString *)APIEndpoint;
- (void)setAPIEndpoint:(NSString *)APIEndpoint;
- (LibratoConnection *)connection;
- (NSString *)customUserAgent;
- (void)setCustomUserAgent:(NSString *)userAgent;
- (NSString *)persistence;
- (void)setPersistence:(NSString *)persistence;
- (id<LibratoPersister>)persister;
- (void)getMetric:(NSString *)name options:(NSDictionary *)options;
- (void)getMeasurements:(NSString *)named options:(NSDictionary *)options;
- (void)updateMetricsNamed:(NSString *)name options:(NSDictionary *)options;
- (void)updateMetrics:(NSDictionary *)metrics;
- (void)setSubmitSuccessBlock:(ClientSuccessBlock)successBlock;
- (void)setSubmitFailureBlock:(ClientFailureBlock)failureBlock;
- (NSArray *)groupNamed:(NSString *)name valued:(NSDictionary *)values;
- (NSArray *)groupNamed:(NSString *)name context:(LibratoMetricContext)context;
- (id)listenForNotification:(NSString *)named context:(LibratoNotificationContext)context;
- (void)submit:(id)metrics;
@end
