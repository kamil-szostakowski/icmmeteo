//
//  MMTNSURL+MMT.h
//  MobileMeteo
//
//  Created by Kamil Szostakowski on 10.06.2015.
//  Copyright (c) 2015 Kamil Szostakowski. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MMTMeteorogramQuery.h"

@interface NSURL (MMTN)

+ (NSURL *)mmt_baseUrl;
+ (NSURL *)mmt_meteorogramSearchUrlWithQuery:(MMTMeteorogramQuery *)query;
+ (NSURL *)mmt_meteorogramDownloadBaseUrl;
@end
