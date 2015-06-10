//
//  MMTMeteorogramFetchDelegateTests.m
//  MobileMeteo
//
//  Created by Kamil Szostakowski on 08.06.2015.
//  Copyright (c) 2015 Kamil Szostakowski. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>
#import "MMTMeteorogramFetchDelegate.h"

@interface MMTMeteorogramFetchDelegateTests : XCTestCase
@end

@implementation MMTMeteorogramFetchDelegateTests

#pragma mark - Test methods

- (void)testEmptyInitialization
{
    MMTMeteorogramFetchDelegate *delegate = [[MMTMeteorogramFetchDelegate alloc] initWithCompletion:nil];
    XCTAssertNil(delegate);
}

- (void)testInitialization
{
    MMTMeteorogramFetchDelegate *delegate = [[MMTMeteorogramFetchDelegate alloc] initWithCompletion:^(NSData *image, NSError *error){}];
    XCTAssertNotNil(delegate);
}

- (void)testFinishCallback
{
    XCTestExpectation *finishCallbackExpectation = [self expectationWithDescription:@"Finish callback expectation"];
    MMTMeteorogramFetchDelegate *delegate = [[MMTMeteorogramFetchDelegate alloc] initWithCompletion:^(NSData *image, NSError *error)
    {
        [finishCallbackExpectation fulfill];
    }];
    
    [delegate connectionDidFinishLoading:nil];
    
    [self waitForExpectationsWithTimeout:1 handler:nil];
}

- (void)testFinishCallbackResponse
{
    NSData *data = [NSData dataWithData:[NSMutableData dataWithLength:100]];
    XCTestExpectation *finishCallbackExpectation = [self expectationWithDescription:@"Finish callback expectation"];

    MMTMeteorogramFetchDelegate *delegate = [[MMTMeteorogramFetchDelegate alloc] initWithCompletion:^(NSData *image, NSError *error)
    {
        XCTAssertNil(error);
        XCTAssertNotNil(image);
        XCTAssertEqualObjects(image, data);
        [finishCallbackExpectation fulfill];
    }];
    
    [delegate connection:nil didReceiveData:data];
    [delegate connectionDidFinishLoading:nil];
    
    [self waitForExpectationsWithTimeout:1 handler:nil];
}

- (void)testFinishCallbackForMultipartResponse
{
    NSData *partOfResponse = [NSData dataWithData:[NSMutableData dataWithLength:100]];
    NSData *responseData = [NSData dataWithData:[NSMutableData dataWithLength:300]];
    XCTestExpectation *finishCallbackExpectation = [self expectationWithDescription:@"Finish callback expectation"];
    
    MMTMeteorogramFetchDelegate *delegate = [[MMTMeteorogramFetchDelegate alloc] initWithCompletion:^(NSData *image, NSError *error)
    {
        XCTAssertNil(error);
        XCTAssertNotNil(image);
        XCTAssertEqualObjects(image, responseData);
        [finishCallbackExpectation fulfill];
    }];
    
    [delegate connection:nil didReceiveData:partOfResponse];
    [delegate connection:nil didReceiveData:partOfResponse];
    [delegate connection:nil didReceiveData:partOfResponse];
    [delegate connectionDidFinishLoading:nil];
    
    [self waitForExpectationsWithTimeout:1 handler:nil];
}

- (void)testConnectionWillSendRequest
{
    NSURL *url = [NSURL URLWithString:@"http://www.meteo.pl/um/metco/mgram_pict.php?ntype=0u&row=367&col=227&lang=pl&fdate=2015060812"];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    MMTMeteorogramFetchDelegate *delegate = [[MMTMeteorogramFetchDelegate alloc] initWithCompletion:^(NSData *image, NSError *error){}];
    NSURLRequest *req = [delegate connection:nil willSendRequest:request redirectResponse:nil];
    
    XCTAssertEqualObjects(url.absoluteString, req.URL.absoluteString);
}

- (void)testConnectionWillSendRedirectionRequest
{
    NSString *expectedUrl = @"http://www.meteo.pl/um/metco/mgram_pict.php?ntype=0u&row=367&col=227&lang=pl&fdate=2015060812";
    NSURL *url = [NSURL URLWithString:@"http://www.meteo.pl/um/php/mgram_search.php?NALL=53.585869&EALL=19.570815&lang=pl&fdate=2015060812"];
    
    NSHTTPURLResponse *response = [[NSHTTPURLResponse alloc] initWithURL:url statusCode:301 HTTPVersion:@"1.1" headerFields:@ {
        @"Location": @"./meteorogram_map_um.php?ntype=0u&row=367&col=227&lang=pl&fdate=2015060812"
    }];

    MMTMeteorogramFetchDelegate *delegate = [[MMTMeteorogramFetchDelegate alloc] initWithCompletion:^(NSData *image, NSError *error){}];
    NSURLRequest *request = [delegate connection:nil willSendRequest:nil redirectResponse:response];

    XCTAssertEqualObjects(expectedUrl, request.URL.absoluteString);
}

- (void)testConnectionFailedWithError
{
    XCTestExpectation *finishCallbackExpectation = [self expectationWithDescription:@"Finish callback expectation"];
    
    MMTMeteorogramFetchDelegate *delegate = [[MMTMeteorogramFetchDelegate alloc] initWithCompletion:^(NSData *image, NSError *error)
    {
        if (error)
            [finishCallbackExpectation fulfill];
    }];
    
    [delegate connection:nil didFailWithError:[NSError errorWithDomain:@"domain" code:1 userInfo:nil]];
    [self waitForExpectationsWithTimeout:1 handler:nil];
}

@end
