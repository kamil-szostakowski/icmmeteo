//
//  MMTMeteorogramController.m
//  Mobile Meteo
//
//  Created by Kamil Szostakowski on 08.05.2015.
//  Copyright (c) 2015 Kamil Szostakowski. All rights reserved.
//

#import "MMTMeteorogramController.h"
#import "MMTMeteorogramStore.h"

@interface MMTMeteorogramController ()

@property (strong, nonatomic) IBOutlet UIImageView *meteorogramImage;
@property (strong, nonatomic) IBOutlet UINavigationBar *navigationBar;
@end

@implementation MMTMeteorogramController

-(void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationBar.topItem.prompt = self.meteorogramTitle;
    self.navigationBar.topItem.title = self.cityName;

    if(![self.cityLocation isEqual:[NSNull null]])
    {
        MMTMeteorogramQuery *query = [[MMTMeteorogramQuery alloc] initWithLocation:self.cityLocation date:[NSDate date]];
        [[MMTMeteorogramStore new] getMeteorogramWithQuery:query completion:^(NSData *meteorogram, NSError *error)
        {
            self.meteorogramImage.image = [UIImage imageWithData:meteorogram];
        }];
    }
}

#pragma mark - Action methods

- (IBAction)onCloseBtnTouchAction:(id)sender
{
    [self performSegueWithIdentifier:kSegueUnwindToListOfCities sender:self];
}

@end
