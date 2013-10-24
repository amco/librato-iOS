//
//  LibratoConnection.h
//  Librato-iOS
//
//  Created by Adam Yanalunas on 9/26/13.
//  Copyright (c) 2013 Amco International Education Services, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@class LibratoClient;

@interface LibratoConnection : NSObject

@property (nonatomic, copy) NSString *APIEndpoint;
@property (nonatomic, strong) LibratoClient *client;

- (instancetype)initWithClient:(LibratoClient *)client usingEndpoint:(NSString *)endpoint;
- (NSString *)userAgent;

@end
