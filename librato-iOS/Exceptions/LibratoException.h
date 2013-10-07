//
//  LibratoException.h
//  librato-iOS
//
//  Created by Adam Yanalunas on 10/4/13.
//  Copyright (c) 2013 Amco International Education Services, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LibratoException : NSException

+ (NSString *)reason;
+ (instancetype)exception;
+ (instancetype)exceptionWithReason:(NSString *)reason;

@end

@interface LibratoNotImplementedException : LibratoException; @end
@interface LibratoInvalidDataException : LibratoException; @end
