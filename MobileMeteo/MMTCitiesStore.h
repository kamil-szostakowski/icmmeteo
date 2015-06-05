//
//  MMTCitiesStore.h
//  Mobile Meteo
//
//  Created by Kamil Szostakowski on 08.05.2015.
//  Copyright (c) 2015 Kamil Szostakowski. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^ListFetchCompletion)(NSArray *error);

@interface MMTCitiesStore : NSObject

- (NSArray*)getAllCities;
- (NSArray*)getCitiesMachingCriteria:(NSString*)criteria;
- (void)findCitiesMachingCriteris:(NSString*)criteria completion:(ListFetchCompletion)completion;
@end
