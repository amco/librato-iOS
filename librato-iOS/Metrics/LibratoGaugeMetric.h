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

@property (nonatomic, strong) NSArray *measurements;

+ (instancetype)metricNamed:(NSString *)name measurements:(NSArray *)measurements;

@end
