//
//  LibratoMetricCollection.m
//  librato-iOS
//
//  Created by Adam Yanalunas on 10/15/13.
//  Copyright (c) 2013 Amco International Education Services, LLC. All rights reserved.
//

#import "LibratoMetricCollection.h"

@implementation LibratoMetricCollection


#pragma mark - Lifecycle
+ (instancetype)collectionNamed:(NSString *)name
{
    LibratoMetricCollection *collection = [LibratoMetricCollection.alloc init];
    collection.name = name;
    
    return collection;
}

- (instancetype)init
{
    self = [super init];
    if (!self) return nil;
    
    self.models = NSMutableArray.array;
    
    return self;
}


#pragma mark - Pseudo overrides
- (void)addObject:(LibratoMetric *)metric
{
    [self.models addObject:metric];
}


#pragma mark - Helpers
- (NSMutableArray *)toJSON
{
    NSMutableArray *jsonModels = NSMutableArray.array;
    [self.models enumerateObjectsUsingBlock:^(LibratoMetric *metric, NSUInteger idx, BOOL *stop) {
        [jsonModels addObject:metric.JSONDictionary];
    }];
    
    return jsonModels;
}


#pragma mark - Overrides
- (NSString *)description
{
    return [NSString stringWithFormat:@"<%@: %p, entries: %i>", NSStringFromClass([self class]), self, self.models.count];
}


@end
