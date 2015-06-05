//
//  MMTModelUmController.m
//  Mobile Meteo
//
//  Created by Kamil Szostakowski on 08.05.2015.
//  Copyright (c) 2015 Kamil Szostakowski. All rights reserved.
//

#import "MMTModelUmController.h"
#import "MMTCitiesStore.h"

@interface MMTModelUmController () <UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate>

@property (strong, nonatomic) IBOutlet UISearchBar *searchBar;
@property (strong, nonatomic) IBOutlet UITableView *tableView;

@property (strong, nonatomic) MMTCitiesStore *citiesStore;
@property (strong, nonatomic) NSArray *cities;
@property (copy, nonatomic) NSDictionary *selectedCity;
@end

@implementation MMTModelUmController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.citiesStore = [MMTCitiesStore new];
    self.cities = [self.citiesStore getAllCities];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:kSegueDisplayMeteorogram])
    {
        [segue.destinationViewController setValue:self.selectedCity[@"name"] forKey:@"cityName"];
        [segue.destinationViewController setValue:self.selectedCity[@"location"] forKey:@"cityLocation"];
        [segue.destinationViewController setValue:@"Model UM" forKey:@"meteorogramTitle"];
    }
}

-(BOOL)canPerformUnwindSegueAction:(SEL)action fromViewController:(UIViewController *)fromViewController withSender:(id)sender
{
    return YES;
}

- (IBAction)unwindToListOfCities:(UIStoryboardSegue *)unwindSegue
{
}

#pragma mark - UITableViewDelegate methods

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.cities.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *city = self.cities[indexPath.row];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CitiesListCell" forIndexPath:indexPath];
    
    cell.textLabel.text = city[@"name"];
    cell.detailTextLabel.text = city[@"region"];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{
    self.selectedCity= self.cities[indexPath.row];
    
    [self performSegueWithIdentifier:kSegueDisplayMeteorogram sender:self];
}

#pragma mark - UISearchBarDelegate methods

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    [self.searchBar setShowsCancelButton:YES animated:YES];
    
     NSArray *filteredCities = [self.citiesStore getCitiesMachingCriteria:self.searchBar.text];
    
    if ([self.searchBar.text isEqualToString:@""])
        [self displayCities:[self.citiesStore getAllCities]];
    
    else if(filteredCities.count>0)
        [self displayCities:filteredCities];
    
    else
        [self.citiesStore findCitiesMachingCriteris:self.searchBar.text completion:^(NSArray *cities) { [self displayCities:cities]; }];    
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    [self.searchBar setShowsCancelButton:NO animated:YES];
    [self.searchBar resignFirstResponder];
    self.searchBar.text = nil;

    [self displayCities:[self.citiesStore getAllCities]];
}

#pragma mark - Helper methods

- (void)displayCities:(NSArray*)cities
{
    self.cities = cities;
    [self.tableView reloadData];
}

@end
