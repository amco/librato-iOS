//
//  LibratoGaugeMetric.h
//  Librato-iOS
//
//  Created by Adam Yanalunas on 10/2/13.
//  Copyright (c) 2013 Amco International Education Services, LLC. All rights reserved.
//

#import "LibratoMetric.h"

extern NSString *const LibratoMetricMeasurementsKey;

@interface LibratoGaugeMetric : LibratoMetric

@property (nonatomic, strong) NSNumber *count;
@property (nonatomic, strong) NSNumber *sum;
@property (nonatomic, strong) NSNumber *min;
@property (nonatomic, strong) NSNumber *max;
@property (nonatomic, strong) NSNumber *squares;

+ (instancetype)metricNamed:(NSString *)name measurements:(NSArray *)measurements;

@end
