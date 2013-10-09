//
//  LibratoDemoEventTracker.h
//  librato-iOS Demo
//
//  Created by Adam Yanalunas on 10/7/13.
//  Copyright (c) 2013 Amco International Education Services, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>


@class Librato;


@interface LibratoDemoEventTracker : NSObject

+ (Librato *)sharedInstance;

- (void)counterMetricExample;
- (void)multipleMetricSubmissionExample;
- (void)dictionaryCreationExample;
- (void)groupDictionaryExample;
- (void)groupContextExample;
- (void)gaugeMetricExample;
- (void)notificationExample;
- (void)customUAExample;

@end
