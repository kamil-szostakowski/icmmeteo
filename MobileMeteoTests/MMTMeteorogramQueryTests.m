//
//  MMTMeteorogramQueryTests.m
//  MobileMeteo
//
//  Created by Kamil on 05.06.2015.
//  Copyright (c) 2015 Kamil Szostakowski. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import <CoreLocation/CoreLocation.h>

#import "MMTMeteorogramQuery.h"

@interface MMTMeteorogramQueryTests : XCTestCase

@property (nonatomic, strong) CLLocation *location;
@property (nonatomic, strong) NSDateFormatter *formatter;
@end

@implementation MMTMeteorogramQueryTests

- (void)setUp
{
    [super setUp];
    
    self.location = [[CLLocation alloc] initWithLatitude:53.03 longitude:18.57];
    self.formatter = [NSDateFormatter new];
    self.formatter.dateFormat = @"YYYY-MM-dd'T'HH:mm";
    self.formatter.timeZone = [NSTimeZone timeZoneForSecondsFromGMT:7200];
}

- (void)tearDown
{
    self.formatter = nil;
    
    [super tearDown];
}

- (void)testEmptyInitialization
{
    MMTMeteorogramQuery *query = [[MMTMeteorogramQuery alloc] initWithLocation:self.location date:nil];
    XCTAssertNil(query);
}

- (void)testCoordinate
{
    NSDate *date = [self.formatter dateFromString:@"2015-04-15T10:00"];
    MMTMeteorogramQuery *query = [[MMTMeteorogramQuery alloc] initWithLocation:self.location date:date];
    
    XCTAssertEqual(53.03, query.location.coordinate.latitude);
    XCTAssertEqual(18.57, query.location.coordinate.longitude);
}

- (void)testDateBeforeNoon
{
    NSDate *date = [self.formatter dateFromString:@"2015-04-15T10:00"];
    MMTMeteorogramQuery *query = [[MMTMeteorogramQuery alloc] initWithLocation:self.location date:date];
    
    XCTAssertEqualObjects(@"2015041500", query.date);
}

- (void)testDateAfterNoonOfLocalTimeZone
{
    NSDate *date = [self.formatter dateFromString:@"2015-02-13T13:00"];
    MMTMeteorogramQuery *query = [[MMTMeteorogramQuery alloc] initWithLocation:self.location date:date];
    
    XCTAssertEqualObjects(@"2015021300", query.date);
}

- (void)testDateAfterNoonOfGMTTimeZone
{
    NSDate *date = [self.formatter dateFromString:@"2015-02-13T14:00"];
    MMTMeteorogramQuery *query = [[MMTMeteorogramQuery alloc] initWithLocation:self.location date:date];
    
    XCTAssertEqualObjects(@"2015021312", query.date);
}

@end
