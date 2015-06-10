//
//  MMTCategoryNSURLTests.m
//  MobileMeteo
//
//  Created by Kamil Szostakowski on 10.06.2015.
//  Copyright (c) 2015 Kamil Szostakowski. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>
#import <CoreLocation/CoreLocation.h>

#import "NSURL+MMT.h"
#import "MMTMeteorogramQuery.h"

@interface MMTCategoryNSURLTests : XCTestCase
@end

@implementation MMTCategoryNSURLTests

- (void)testBaseUrl
{
    XCTAssertEqualObjects(@"http://www.meteo.pl", [[NSURL mmt_baseUrl] absoluteString]);
}

- (void)testMeteorogramSearchUrl
{
    CLLocation *expectedLocation = [[CLLocation alloc] initWithLatitude:53.585869 longitude:19.570815];
    NSString *expectedUrl = @"http://www.meteo.pl/um/php/mgram_search.php?NALL=53.585869&EALL=19.570815&lang=pl&fdate=2015060812";
    
    id queryMock = [OCMockObject mockForClass:[MMTMeteorogramQuery class]];
    [(MMTMeteorogramQuery*)[[queryMock stub] andReturn:@"2015060812"] date];
    [(MMTMeteorogramQuery*)[[queryMock stub] andReturn:expectedLocation] location];
    
    XCTAssertEqualObjects(expectedUrl, [[NSURL mmt_meteorogramSearchUrlWithQuery:queryMock] absoluteString]);
}

- (void)testMeteorogramDownloadUrl
{
    XCTAssertEqualObjects(@"http://www.meteo.pl/um/metco/mgram_pict.php", [[NSURL mmt_meteorogramDownloadBaseUrl] absoluteString]);
}
@end
