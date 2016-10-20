//
//  NSString+AYLSanitizedForMetric.m
//  Librato-iOS
//
//  Created by Adam Yanalunas on 10/3/13.
//  Copyright (c) 2013 Amco International Education Services, LLC. All rights reserved.
//

#import "NSString+AYLSanitizedForMetric.h"

@implementation NSString (AYLSanitizedForMetric)

- (NSString *)ayl_sanitizedForMetric
{
    NSCharacterSet *allowedSet = [NSCharacterSet characterSetWithCharactersInString:@"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890.:-_"];
    NSString *cleaned = [[self componentsSeparatedByCharactersInSet:allowedSet.invertedSet] componentsJoinedByString:@"-"];
    return [cleaned substringToIndex:(self.length < 255 ? self.length : 255)];
}


@end
