//
//  LibratoException.m
//  librato-iOS
//
//  Created by Adam Yanalunas on 10/4/13.
//  Copyright (c) 2013 Amco International Education Services, LLC. All rights reserved.
//

#import "LibratoException.h"

@implementation LibratoException

+ (instancetype)exception
{
    return (id)[self.class exceptionWithName:NSStringFromClass(self.class) reason:self.class.reason userInfo:nil];
}


+ (instancetype)exceptionWithReason:(NSString *)reason
{
    return (id)[self.class exceptionWithName:NSStringFromClass(self.class) reason:reason userInfo:nil];
}


+ (NSString *)reason
{
    [NSException raise:NSGenericException format:@"LibratoException is an abstract class. Reason must be overriden in subclass."];
    return nil;
}

@end


@implementation LibratoNotImplementedException

+ (NSString *)reason
{
    return NSLocalizedStringFromTable(@"EXCEPTION_REASON_NOT_IMPLEMENTED", LIBRATO_LOCALIZABLE, nil);
}

@end


@implementation LibratoInvalidDataException

+ (NSString *)reason
{
    return NSLocalizedStringFromTable(@"EXCEPTION_REASON_INVALID_DATA", LIBRATO_LOCALIZABLE, nil);
}

@end