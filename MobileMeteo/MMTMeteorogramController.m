//
//  MMTMeteorogramController.m
//  Mobile Meteo
//
//  Created by Kamil Szostakowski on 08.05.2015.
//  Copyright (c) 2015 Kamil Szostakowski. All rights reserved.
//

#import "MMTMeteorogramController.h"

@interface MMTMeteorogramController ()

@property (strong, nonatomic) IBOutlet UINavigationBar *navigationBar;
@property (strong, nonatomic) IBOutlet UILabel *lblInfo;
@end

@implementation MMTMeteorogramController

-(void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationBar.topItem.prompt = self.meteorogramTitle;
    self.navigationBar.topItem.title = self.cityName;
    NSLog(@"Location: %@", self.cityLocation);
    if(![self.cityLocation isEqual:[NSNull null]])
    {
        self.lblInfo.text = [NSString stringWithFormat:@"Meteorogram: Lat: %f Lng: %f", self.cityLocation.coordinate.latitude, self.cityLocation.coordinate.longitude];
    }
    else
    {
        self.lblInfo.text = @"Meteorogram";
    }
}

#pragma mark - Action methods

- (IBAction)onCloseBtnTouchAction:(id)sender
{
    [self performSegueWithIdentifier:kSegueUnwindToListOfCities sender:self];
}

@end
