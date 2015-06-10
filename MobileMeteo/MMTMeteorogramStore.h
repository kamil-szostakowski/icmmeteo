//
//  MMTMeteorogramStore.h
//  MobileMeteo
//
//  Created by Kamil on 07.06.2015.
//  Copyright (c) 2015 Kamil Szostakowski. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

#import "MMTMeteorogramQuery.h"
#import "MMTMeteorogramFetchDelegate.h"

@interface MMTMeteorogramStore : NSObject

- (void)getMeteorogramWithQuery:(MMTMeteorogramQuery*)query completion:(MMTMeteorogramFetchCompletion)completion;
@end
