//
//  MMTMeteorogramFetchDelegate.h
//  MobileMeteo
//
//  Created by Kamil Szostakowski on 08.06.2015.
//  Copyright (c) 2015 Kamil Szostakowski. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^MMTMeteorogramFetchCompletion)(NSData*, NSError*);

@interface MMTMeteorogramFetchDelegate : NSObject<NSURLConnectionDataDelegate>

- (instancetype)initWithCompletion:(MMTMeteorogramFetchCompletion)completion;
@end
