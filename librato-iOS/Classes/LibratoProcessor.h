//
//  LibratoProcessor.h
//  Librato-iOS
//
//  Created by Adam Yanalunas on 9/26/13.
//  Copyright (c) 2013 Amco International Education Services, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LibratoPersister.h"
#import "MTLModel.h"

typedef void(^TimedExecutionBlock)(void);

@class LibratoClient, LibratoMetric, LibratoPersister;

@interface LibratoProcessor : MTLModel {
    NSMutableDictionary *_queued;
}

@property (nonatomic) NSTimeInterval autosubmitInterval;
@property (nonatomic, strong) NSTimer *autoSubmitTimer;
@property (nonatomic) BOOL clearOnFailure;
@property (nonatomic, strong) NSDate *createTime;
@property (nonatomic, strong) NSMutableDictionary *queued;
@property (nonatomic, strong) NSString *source;
@property (nonatomic, strong) NSDate *measureTime;
@property (nonatomic, strong) LibratoClient *client;
@property (nonatomic, strong, readonly) NSDate *lastSubmitTime;
@property (nonatomic, strong) id<LibratoPersister> persister;
@property (nonatomic, readonly) NSUInteger perRequest;
@property (nonatomic, strong) NSString *prefix;

- (BOOL)submit;
- (LibratoMetric *)time:(TimedExecutionBlock)block named:(NSString *)name options:(NSDictionary *)options;
- (id<LibratoPersister>)createPersister;
- (NSTimeInterval)epochTime;
- (void)setupCommonOptions:(NSDictionary *)options;
- (void)autosubmitCheck;


@end
