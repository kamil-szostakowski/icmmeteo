//
//  MMTMeteorogramController.h
//  Mobile Meteo
//
//  Created by Kamil Szostakowski on 08.05.2015.
//  Copyright (c) 2015 Kamil Szostakowski. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

@interface MMTMeteorogramController : UIViewController

@property (nonatomic, copy) NSString *meteorogramTitle;
@property (nonatomic, copy) NSString *cityName;
@property (nonatomic, copy) CLLocation *cityLocation;
@end
