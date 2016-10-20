//
//  NSString+SanitizedForMetricTests.m
//  librato-iOS
//
//  Created by Sergey Kuryanov on 20.10.16.
//  Copyright © 2016 Amco International Education Services, LLC. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "NSString+AULSanitizedForMetric.h"

@interface NSString_SanitizedForMetricTests : XCTestCase
@property (nonatomic, strong) NSString *testString;
@end

@implementation NSString_SanitizedForMetricTests

- (void)setUp {
    [super setUp];
    
    self.testString = @"A-Za-z0-9.:-_<>{}[];\'\"!@#$%^&*()_+=œ∑´®†¥¨ˆøπ“‘«åß∂ƒ©˙∆˚¬…æΩ≈ç√∫˜µ≤≥÷";
}

- (void)tearDown {
    self.testString = nil;
    
    [super tearDown];
}

- (void)testThatOnlyAllowedCharactersPresent {
    NSString *expectedString = @"A-Za-z0-9.:-_-------------------_------------------------------------";
    
    XCTAssertEqualObjects(self.testString.sanitizedForMetric, expectedString);
}

@end
