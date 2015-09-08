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

    @IBOutlet var topSpacing: NSLayoutConstraint!    
    @IBOutlet var infoBar: UIView!
    @IBOutlet var searchBar: UISearchBar!
    @IBOutlet var tableView: UITableView!
    @IBOutlet var lblForecastLenght: UILabel!
    @IBOutlet var lblForecastStart: UILabel!
        
    // MARK: Properties
    
    var meteorogramStore: MMTGridClimateModelStore!
    
    private var citiesIndex: [MMTCitiesGroup]!
    private var citiesStore: MMTCitiesStore!
    private var selectedCity: MMTCity?
    private var shouldDisplayMeteorogram = false
    
    private let kCurrentLocationKey = "currentLocation"
    
    private var isSearching: Bool {
        return count(searchBar.text) > 0
    }
    
    // MARK: Controller methods
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        citiesIndex = [MMTCitiesGroup]()
        citiesStore = MMTCitiesStore(db: MMTDatabase.instance)
        
        lblForecastStart.text = "Start prognozy t0: \(NSDateFormatter.shortStyleUtcDatetime(meteorogramStore.forecastStartDate))"        
        lblForecastLenght.text = "Długość prognozy: \(meteorogramStore.forecastLength)h, siatka \(meteorogramStore.gridNodeSize)km"
        
        tableView.tableHeaderView?.frame = CGRectMake(0, 0, view.frame.size.width, searchBar.bounds.height)
    }
    
    override func viewWillAppear(animated: Bool)
    {
        super.viewWillAppear(animated)
        
        searchBarCancelButtonClicked(searchBar)
        citiesStore.addObserver(self, forKeyPath: kCurrentLocationKey, options: .New, context: nil)
    }
    
    override func viewWillDisappear(animated: Bool)
    {
        super.viewWillDisappear(animated)
        citiesStore.removeObserver(self, forKeyPath: kCurrentLocationKey)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?)
    {
        searchBar.text = ""
        
        let a = segue.destinationViewController.respondsToSelector(Selector("city"))
        
        if segue.identifier == MMTSegue.DisplayMeteorogram
        {
            let
            controller = segue.destinationViewController as! MMTMeteorogramController
            controller.meteorogramStore = meteorogramStore
            controller.city = selectedCity
        }
        
        if segue.identifier == MMTSegue.DisplayMapScreen
        {
            let
            controller = segue.destinationViewController as! MMTCityMapPickerController
            controller.meteorogramStore = meteorogramStore
        }
    }
    
    override func observeValueForKeyPath(keyPath: String, ofObject object: AnyObject, change: [NSObject : AnyObject], context: UnsafeMutablePointer<Void>)
    {
        if keyPath == kCurrentLocationKey && !isSearching {
            updateIndexWithAllCities() { self.tableView.reloadData() }
        }
    }
    
    // MARK: Actions
    
    @IBAction func unwindToListOfCities(unwindSegue: UIStoryboardSegue)
    {
    }
    
    // MARK: UITableViewDelegate methods
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int
    {
        return citiesIndex.count
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return citiesIndex[section].type != .NotFound ? citiesIndex[section].cities.count : 1
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        let sectionType = citiesIndex[indexPath.section].type
        
        if sectionType == .NotFound {
            return tableView.dequeueReusableCellWithIdentifier("SpecialListCell", forIndexPath: indexPath) as! UITableViewCell
        }
        else
        {
            let city = citiesIndex[indexPath.section].cities[indexPath.row]
      
            let
            cell = tableView.dequeueReusableCellWithIdentifier("CitiesListCell", forIndexPath: indexPath) as! UITableViewCell
            cell.detailTextLabel?.text = sectionType != .CurrentLocation ? city.region : "Obecna lokalizacja"
            cell.textLabel!.text = city.name
            
            return cell
        }
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat
    {
        return citiesIndex[section].type.description != nil ? 30 : 0
    }

    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView?
    {
        let headerTitle = citiesIndex[section].type.description
        
        if headerTitle == nil { return nil }
        
        let
        header = tableView.dequeueReusableCellWithIdentifier("CitiesListHeader") as! UITableViewCell
        header.textLabel?.text = headerTitle
        
        return header
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)
    {
        if citiesIndex[indexPath.section].type != .NotFound
        {
            selectedCity = citiesIndex[indexPath.section].cities[indexPath.row]
            performSegueWithIdentifier(MMTSegue.DisplayMeteorogram, sender: self)
        }
        else
        {
            performSegueWithIdentifier(MMTSegue.DisplayMapScreen, sender: self)
        }
    }
    
    // MARK: UIScrollViewDelegate methods
    
    func scrollViewDidScroll(scrollView: UIScrollView)
    {
        let scrolled = scrollView.contentOffset.y > 0
        let offset: CGFloat = scrolled ? max(-44, -scrollView.contentOffset.y) : 0
        
        self.animateInfoBarScrollWithOffset(offset)
    }
    
    func scrollViewDidEndDragging(scrollView: UIScrollView, willDecelerate decelerate: Bool)
    {
        let offset: CGFloat = scrollView.contentOffset.y > 0 ? -44 : 0
        
        self.animateInfoBarScrollWithOffset(offset)
        
        if scrollView.contentOffset.y < self.searchBar.bounds.height {
            self.tableView.adjustContentOffsetForHeaderOfHeight(self.searchBar.bounds.height)
        }
    }
    
    private func animateInfoBarScrollWithOffset(offset: CGFloat)
    {
        let alpha: CGFloat = offset < 0 ? 0 : 1
        
        if topSpacing.constant != offset
        {
            let animations = { () -> Void in
                self.topSpacing.constant = offset
                self.infoBar.alpha = alpha
                self.view.layoutIfNeeded()
            }
            
            UIView.animateWithDuration(0.2, delay: 0, usingSpringWithDamping: 0.9, initialSpringVelocity: 5, options: nil, animations: animations, completion: nil)
        }
    }    
    
    // MARK: UISearchBarDelegate methods
    
    func searchBarTextDidBeginEditing(searchBar: UISearchBar)
    {
        searchBar.setShowsCancelButton(true, animated: true)
    }
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String)
    {
//        searchBar.text = searchBar.text.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())

        if isSearching
        {
            updateIndexWithCitiesMatchingCriteria(searchText) { self.tableView.reloadData() }
        }
        else
        {
            updateIndexWithAllCities() { self.tableView.reloadData() }
        }
    }
    
    func searchBarCancelButtonClicked(searchBar: UISearchBar)
    {
        searchBar.setShowsCancelButton(false, animated: true)
        searchBar.resignFirstResponder()
        searchBar.text = ""
        
        updateIndexWithAllCities() { self.tableView.reloadData() }
    }
    
    func searchBarTextDidEndEditing(searchBar: UISearchBar)
    {
        updateIndexWithAllCities() { self.tableView.reloadData() }
    }
    
    // MARK: Helper methods
    
    private func updateIndexWithAllCities(completion: MMTCompletion)
    {
        citiesStore.getAllCities()
        {
            var index = self.getIndexForCities($0)
            var location = self.citiesStore.currentLocation
            
            if location == nil
            {
                self.citiesIndex = index
                completion()
                return
            }
            
            self.citiesStore.findCityForLocation(location!)
            {
                if let currentCity = $0
                {
                    let group = MMTCitiesGroup(type: .CurrentLocation, cities: [currentCity])
                    index.insert(group, atIndex: 0)
                }
                
                self.citiesIndex = index
                completion()
            }
        }
    }
    
    private func updateIndexWithCitiesMatchingCriteria(criteria: String, completion: MMTCompletion)
    {
        citiesStore.getCitiesMatchingCriteria(criteria)
        {
            if $0.count > 0
            {
                self.citiesIndex = self.getIndexForCities($0)
                completion()
            }
            else
            {
                self.citiesStore.findCitiesMatchingCriteria(criteria)
                {
                    let searchResults = $0.filter(){ !$0.isCapital && !$0.isFavourite }
                    
                    self.citiesIndex = [
                        MMTCitiesGroup(type: .SearchResults, cities: searchResults),
                        MMTCitiesGroup(type: .NotFound, cities: []),
                    ]                    
                    completion()
                }
            }
        }
    }
    
    private func getIndexForCities(cities: [MMTCity]) -> [MMTCitiesGroup]
    {
        var index = [MMTCitiesGroup]()
        
        let favourites = cities.filter(){ $0.isFavourite }
        let capitals = cities.filter(){ $0.isCapital && !$0.isFavourite }
        
        if favourites.count > 0 {
            index.append(MMTCitiesGroup(type: .Favourites, cities: favourites))
        }
        
        if capitals.count > 0 {
            index.append(MMTCitiesGroup(type: .Capitals, cities: capitals))
        }
        
        return index
    }
}