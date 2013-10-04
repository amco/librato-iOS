//
//  LibratoPersister.h
//  Librato-iOS
//
//  Created by Adam Yanalunas on 9/27/13.
//  Copyright (c) 2013 Amco International Education Services, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@class LibratoClient;

@protocol LibratoPersister <NSObject>

- (BOOL)persistUsingClient:(LibratoClient *)client queued:(NSDictionary *)queued options:(NSDictionary *)options;

@end


@interface LibratoPersister : NSObject

@end
