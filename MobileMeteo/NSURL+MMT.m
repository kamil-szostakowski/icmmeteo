//
//  MMTNSURL+MMT.m
//  MobileMeteo
//
//  Created by Kamil Szostakowski on 10.06.2015.
//  Copyright (c) 2015 Kamil Szostakowski. All rights reserved.
//

#import "NSURL+MMT.h"

@implementation NSURL (MMT)

+ (NSURL *)mmt_baseUrl
{
    return [NSURL URLWithString:@"http://www.meteo.pl"];
}

+ (NSURL *)mmt_meteorogramSearchUrlWithQuery:(MMTMeteorogramQuery *)query
{
    CLLocationDegrees lat = query.location.coordinate.latitude;
    CLLocationDegrees lng = query.location.coordinate.longitude;

    NSString *searchComponentFormat = @"/um/php/mgram_search.php?NALL=%f&EALL=%f&lang=pl&fdate=%@";
    NSString *searchComponent = [NSString stringWithFormat:searchComponentFormat, lat, lng, query.date];

    return [NSURL URLWithString:searchComponent relativeToURL:[self mmt_baseUrl]];
}

+ (NSURL *)mmt_meteorogramDownloadBaseUrl
{    
    return [NSURL URLWithString: @"/um/metco/mgram_pict.php" relativeToURL:[self mmt_baseUrl]];
}
@end
