//
//  MMTCitiesStore.m
//  Mobile Meteo
//
//  Created by Kamil Szostakowski on 08.05.2015.
//  Copyright (c) 2015 Kamil Szostakowski. All rights reserved.
//

#import "MMTCitiesStore.h"
#import <CoreLocation/CoreLocation.h>

@interface MMTCitiesStore ()

@property (nonatomic, strong) CLGeocoder *geocoder;
@end

@implementation MMTCitiesStore

- (NSArray*)getAllCities
{
    NSArray *cities = @[];
    NSArray *names = @[@"Białystok", @"Bydgoszcz", @"Gdańsk", @"Gorzów Wielkopolski", @"Katowice", @"Kielce", @"Kraków", @"Lublin", @"Łódź",
             @"Olsztyn", @"Opole", @"Poznań", @"Rzeszów", @"Szczecin", @"Toruń", @"Warszawa", @"Wrocław", @"Zielona Góra"];
    
    for (NSString *name in names)
    {
        cities = [cities arrayByAddingObject:[self cityWithName:name region:@"" location:nil]];
    }
    
    return cities;
}

- (NSArray*)getCitiesMachingCriteria:(NSString*)criteria
{
    return [[self getAllCities] filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"SELF.name CONTAINS[cd] %@", criteria]];
}

- (void)findCitiesMachingCriteris:(NSString*)criteria completion:(ListFetchCompletion)completion
{
    if(!self.geocoder)
    {
        self.geocoder = [CLGeocoder new];
    }
    
    NSString *addressString = [NSString stringWithFormat:@"%@, Poland", criteria];
    
    [self.geocoder geocodeAddressString:addressString completionHandler:^(NSArray *placemarks, NSError *error)
    {
        NSArray *cities = @[];
        
        for (CLPlacemark *placemark in placemarks)
        {
            cities = [cities arrayByAddingObject:[self cityWithName:placemark.name region:placemark.administrativeArea location:placemark.location]];
        }                        
        
        completion(cities);
    }];
}

#pragma mark - Helper methods

- (NSDictionary*)cityWithName:(NSString*)name region:(NSString*)region location:(CLLocation*)location
{
    return @
    {
        @"name": name,
        @"region": region,
        @"location": location ? location : [NSNull null],
    };
}

@end
