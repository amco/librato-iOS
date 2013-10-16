//
//  LibratoQueue.h
//  Librato-iOS
//
//  Created by Adam Yanalunas on 9/27/13.
//  Copyright (c) 2013 Amco International Education Services, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LibratoProcessor.h"

extern NSString *const QueueAutosubmitCountKey;
extern NSString *const QueueSkipMeasurementTimesKey;

@interface LibratoQueue : LibratoProcessor

- (instancetype)initWithOptions:(NSDictionary *)options;
- (LibratoQueue *)add:(id)metrics;
- (void)clear;
- (BOOL)isEmpty;
- (LibratoQueue *)merge:(NSDictionary *)dictionary;
- (NSUInteger)size;

@end
