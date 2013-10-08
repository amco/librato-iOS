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


extern NSString *const LIBRATO_LOCALIZABLE;


@class LibratoConnection, LibratoClient;


@interface Librato : NSObject


typedef void (^LibratoMetricContext)(Librato *l);


@property (nonatomic, strong) LibratoClient *client;
@property (nonatomic, strong) NSString *prefix;

+ (NSDate *)minimumMeasureTime;

- (instancetype)initWithEmail:(NSString *)email token:(NSString *)apiKey prefix:(NSString *)prefix;

- (LibratoClient *)client;
- (void)authenticateEmail:(NSString *)emailAddress APIKey:(NSString *)apiKey;
- (NSString *)APIEndpoint;
- (void)setAPIEndpoint:(NSString *)APIEndpoint;
- (NSString *)persistence;
- (void)setPersistence:(NSString *)persistence;
- (id<LibratoPersister>)persister;
- (LibratoConnection *)connection;
- (void)getMetric:(NSString *)name options:(NSDictionary *)options;
- (void)getMeasurements:(NSString *)named options:(NSDictionary *)options;
- (void)updateMetricsNamed:(NSString *)name options:(NSDictionary *)options;
- (void)updateMetrics:(NSDictionary *)metrics;
- (NSArray *)groupNamed:(NSString *)name valued:(NSDictionary *)values;
- (NSArray *)groupNamed:(NSString *)name context:(LibratoMetricContext)context;
- (void)submit;
- (void)submit:(id)metrics;
@end
