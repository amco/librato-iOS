//
//  NSString+SanitizedForMetric.m
//  Librato-iOS
//
//  Created by Adam Yanalunas on 10/3/13.
//  Copyright (c) 2013 Amco International Education Services, LLC. All rights reserved.
//

#import "NSString+SanitizedForMetric.h"

@implementation NSString (SanitizedForMetric)

- (NSString *)sanitizedForMetric
{
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"[^A-Za-z0-9.:-_]" options:0 error:NULL];
    NSString *cleaned = [regex stringByReplacingMatchesInString:self options:0 range:NSMakeRange(0, self.length) withTemplate:@"-"];
    return [cleaned substringToIndex:(self.length < 255 ? self.length : 255)];
}


@end
