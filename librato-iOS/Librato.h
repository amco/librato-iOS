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

@property (nonatomic, strong) LibratoClient *client;
@property (nonatomic, strong) NSString *prefix;

+ (NSDate *)minimumMeasureTime;

- (instancetype)initWithEmail:(NSString *)email token:(NSString *)apiKey prefix:(NSString *)prefix;

- (NSString *)APIEndpoint;
- (void)setAPIEndpoint:(NSString *)APIEndpoint;
- (void)authenticateEmail:(NSString *)emailAddress APIKey:(NSString *)apiKey;
- (LibratoClient *)client;
- (LibratoConnection *)connection;
- (NSString *)persistence;
- (void)setPersistence:(NSString *)persistence;
- (id<LibratoPersister>)persister;
- (void)getMetric:(NSString *)name options:(NSDictionary *)options;
- (void)getMeasurements:(NSString *)named options:(NSDictionary *)options;
- (void)updateMetricsNamed:(NSString *)name options:(NSDictionary *)options;
- (void)updateMetrics:(NSDictionary *)metrics;
- (void)submit:(id)metrics;
@end
