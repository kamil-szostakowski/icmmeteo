//
//  MMTMeteorogramStore.m
//  MobileMeteo
//
//  Created by Kamil on 07.06.2015.
//  Copyright (c) 2015 Kamil Szostakowski. All rights reserved.
//

#import "MMTMeteorogramStore.h"

@implementation MMTMeteorogramStore

- (void)getMeteorogramWithQuery:(MMTMeteorogramQuery*)query completion:(MMTMeteorogramFetchCompletion)completion
{
    MMTMeteorogramFetchDelegate *delegate = [[MMTMeteorogramFetchDelegate alloc] initWithCompletion:completion];
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL mmt_meteorogramSearchUrlWithQuery:query]];
    
    [[[NSURLConnection alloc] initWithRequest:request delegate:delegate] start];
}

@end
