//
//  MMTMeteorogramFetchDelegate.m
//  MobileMeteo
//
//  Created by Kamil Szostakowski on 08.06.2015.
//  Copyright (c) 2015 Kamil Szostakowski. All rights reserved.
//

#import "MMTMeteorogramFetchDelegate.h"

@interface MMTMeteorogramFetchDelegate ()

@property (nonatomic, strong) NSData *responseData;
@property (nonatomic, strong) MMTMeteorogramFetchCompletion completion;
@end

@implementation MMTMeteorogramFetchDelegate

- (instancetype)initWithCompletion:(MMTMeteorogramFetchCompletion)completion
{
    if(completion)
    {
        self = [super init];
        
        if(self)
            _completion = completion;
        
        return self;
    }
    
    return nil;
}

#pragma mark - Delegate methods

- (NSURLRequest *)connection:(NSURLConnection *)connection willSendRequest:(NSURLRequest *)request redirectResponse:(NSURLResponse *)response
{
    if(response)
    {
        NSHTTPURLResponse *redirectResponse = (NSHTTPURLResponse *)response;
        NSString *locationUri = redirectResponse.allHeaderFields[@"Location"];
    
        NSString *queryString = [[locationUri componentsSeparatedByString:@"?"] lastObject];
        queryString = [NSString stringWithFormat:@"?%@", queryString];
    
        NSURL *redirectUrl = [NSURL URLWithString:queryString relativeToURL:[NSURL mmt_meteorogramDownloadBaseUrl]];

        return [NSURLRequest requestWithURL:redirectUrl];
    }
    
    return request;
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    NSMutableData *responseData = self.responseData ? self.responseData.mutableCopy : data;
    
    if (self.responseData)
    {
        [responseData appendData:data];
    }
            
    self.responseData = [NSData dataWithData:responseData];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    self.completion(self.responseData, nil);
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    self.responseData = nil;
    self.completion(nil, error);
}

@end
