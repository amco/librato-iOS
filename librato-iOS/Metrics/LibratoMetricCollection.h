//
//  LibratoMetricCollection.h
//  librato-iOS
//
//  Created by Adam Yanalunas on 10/15/13.
//  Copyright (c) 2013 Amco International Education Services, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MTLModel.h"

@interface LibratoMetricCollection : MTLModel

@property (nonatomic, strong) NSMutableArray *models;
@property (nonatomic, copy) NSString *name;

+ (instancetype)collectionNamed:(NSString *)name;

- (void)addObject:(LibratoMetric *)metric;
- (NSMutableArray *)toJSON;

@end
