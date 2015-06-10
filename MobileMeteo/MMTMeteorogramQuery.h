//
//  MMTMeteorogramQuery.h
//  MobileMeteo
//
//  Created by Kamil on 05.06.2015.
//  Copyright (c) 2015 Kamil Szostakowski. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@interface MMTMeteorogramQuery : NSObject

@property (nonatomic, readonly) CLLocation *location;
@property (nonatomic, readonly) NSString *date;

- (instancetype)initWithLocation:(CLLocation *)location;
- (instancetype)initWithLocation:(CLLocation *)location date:(NSDate*)date NS_DESIGNATED_INITIALIZER;
@end
