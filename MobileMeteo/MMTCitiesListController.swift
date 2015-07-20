//
//  MMTModelUmController.swift
//  MobileMeteo
//
//  Created by Kamil Szostakowski on 08.07.2015.
//  Copyright (c) 2015 Kamil Szostakowski. All rights reserved.
//

import UIKit
import Foundation

class MMTCitiesListController: UIViewController, UITableViewDelegate, UISearchBarDelegate
{
    // MARK: Outlets
    
    @IBOutlet var searchBar: UISearchBar!
    @IBOutlet var tableView: UITableView!
        
    // MARK: Properties
    
    var modelType: MMTModelType!
    
    private var citiesStore: MMTCitiesStore!
    private var cities: [MMTCity]!
    private var selectedCity: MMTCity?
    
    private var query: MMTMeteorogramQuery
    {
        var city = self.selectedCity!
        return MMTMeteorogramQuery(location: city.location, name: city.name, type: self.modelType)
    }
    
    // MARK: Controller methods
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        citiesStore = MMTCitiesStore(db: MMTDatabase.instance)
        cities = citiesStore.getAllCities()
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?)
    {
        if (segue.identifier == Segue.DisplayMeteorogram) {
            segue.destinationViewController.setValue(query, forKey: "query")
        }
    }
    
    // MARK: Actions
    
    @IBAction func unwindToListOfCities(unwindSegue: UIStoryboardSegue)
    {
    }
    
    // MARK: UITableViewDelegate methods
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int
    {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return cities.count;
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        let city = cities[indexPath.row]
        let cell = tableView.dequeueReusableCellWithIdentifier("CitiesListCell", forIndexPath: indexPath) as! UITableViewCell
        
        cell.textLabel?.text = city.name
        cell.detailTextLabel?.text = city.region
        
        return cell;
    }
    
    func tableView(tableView: UITableView, accessoryButtonTappedForRowWithIndexPath indexPath: NSIndexPath)
    {
        selectedCity = cities[indexPath.row]        
        performSegueWithIdentifier(Segue.DisplayMeteorogram, sender: self)
    }
    
    // MARK: UISearchBarDelegate methods
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String)
    {
        searchBar.setShowsCancelButton(true, animated: true)
        let filteredCities = citiesStore.getCitiesMachingCriteria(searchBar.text)
        
        if searchBar.text == "" {
            displayCities(citiesStore.getAllCities())
        }
        else if filteredCities.count>0 {
            displayCities(filteredCities)
        }
        else {
            citiesStore.findCitiesMachingCriteris(searchBar.text) {(cities: [MMTCity]) in self.displayCities(cities) }
        }
    }
    
    func searchBarCancelButtonClicked(searchBar: UISearchBar) // called when cancel button pressed
    {
        searchBar.setShowsCancelButton(false, animated: true)
        searchBar.resignFirstResponder()
        searchBar.text = "";
    
        self.displayCities(citiesStore.getAllCities())
    }
    
    // MARK: Helper methods
    
    func displayCities(cities: [MMTCity])
    {
        self.cities = cities
        tableView.reloadData()
    }
}