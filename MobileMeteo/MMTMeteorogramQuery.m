//
//  MMTMeteorogramQuery.m
//  MobileMeteo
//
//  Created by Kamil on 05.06.2015.
//  Copyright (c) 2015 Kamil Szostakowski. All rights reserved.
//

#import "MMTMeteorogramQuery.h"

@implementation MMTMeteorogramQuery

- (instancetype)initWithLocation:(CLLocation *)location
{
    return [self initWithLocation:location date:[NSDate date]];
}

- (instancetype)initWithLocation:(CLLocation *)location date:(NSDate*)date
{
    self = date ? [super init] : nil;
    
    if(self)
    {
        _location = location;
        _date = [self generateDateString:date];
    }
    
    return self;
}

#pragma mark - Helper methods

- (NSString*)generateDateString:(NSDate*)date
{
    NSCalendarUnit units = NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay|NSCalendarUnitHour;
    NSCalendar *calendar = [[NSCalendar currentCalendar] copy];
    calendar.timeZone = [NSTimeZone timeZoneWithName:@"GMT"];
    
    NSDateComponents *components = [calendar components:units fromDate:date];
    NSInteger tZero = components.hour < 12 ? 0 : 12;
    
    return [NSString stringWithFormat:@"%04ld%02ld%02ld%02ld", components.year, components.month, components.day, tZero];
}
@end
