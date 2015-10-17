//
//  MMTModelUmController.swift
//  MobileMeteo
//
//  Created by Kamil Szostakowski on 08.07.2015.
//  Copyright (c) 2015 Kamil Szostakowski. All rights reserved.
//

import UIKit
import Foundation
import CoreLocation

class MMTCitiesListController: UIViewController, UITableViewDelegate, UISearchBarDelegate, CLLocationManagerDelegate
{        
    // MARK: Outlets

    @IBOutlet var tableViewHeader: UIView!
    @IBOutlet var topSpacing: NSLayoutConstraint!    
    @IBOutlet var infoBar: UIView!
    @IBOutlet var searchBar: UISearchBar!
    @IBOutlet var tableView: UITableView!
    @IBOutlet var lblForecastLenght: UILabel!
    @IBOutlet var lblForecastStart: UILabel!
        
    // MARK: Properties
    
    var meteorogramStore: MMTGridClimateModelStore!
    
    private var locationManager: CLLocationManager!
    private var searchInput: MMTSearchInput!
    private var citiesIndex: [MMTCitiesGroup]!
    private var citiesStore: MMTCitiesStore!
    private var selectedCity: MMTCity?
    private var shouldDisplayMeteorogram = false
    
    private let kCurrentLocationKey = "location"
    
    // MARK: Controller methods
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        searchInput = MMTSearchInput("")
        citiesIndex = [MMTCitiesGroup]()
        citiesStore = MMTCitiesStore(db: MMTDatabase.instance)
        
        setupLocationManager()
        setupHeader()
    }
    
    override func viewWillAppear(animated: Bool)
    {
        super.viewWillAppear(animated)
        
        let handler = Selector("handleApplicationDidBecomeActiveNotification:")
        let notification = UIApplicationDidBecomeActiveNotification
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: handler, name: notification, object: nil)
        
        searchBarCancelButtonClicked(searchBar)
    }
    
    override func viewWillDisappear(animated: Bool)
    {
        super.viewWillDisappear(animated)
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?)
    {
        searchBarCancelButtonClicked(searchBar)
        
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
    
    // MARK: Setup methods
    
    private func setupLocationManager()
    {
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
    }
    
    private func setupHeader()
    {
        lblForecastStart.text = "Start prognozy t0: \(NSDateFormatter.shortStyleUtcDatetime(meteorogramStore.forecastStartDate))"
        lblForecastLenght.text = "Długość prognozy: \(meteorogramStore.forecastLength)h, siatka \(meteorogramStore.gridNodeSize)km"
        
        tableViewHeader.frame = CGRectMake(0, 0, view.frame.size.width, searchBar.bounds.height)
    }
    
    // MARK: CLLocationManagerDelegate
    
    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus)
    {
        let authorized = status == .AuthorizedWhenInUse
    
        if authorized {
            locationManager.startMonitoringSignificantLocationChanges()
        }
        
        if !authorized {
            locationManager.stopMonitoringSignificantLocationChanges()
        }

        tableView.tableHeaderView = authorized ? tableViewHeader : nil
        updateIndexWithAllCities() { self.tableView.reloadData() }
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation])
    {
        if !searchInput.isValid {
            updateIndexWithAllCities() { self.tableView.reloadData() }
        }
    }
    
    // MARK: Actions
    
    @IBAction func unwindToListOfCities(unwindSegue: UIStoryboardSegue)
    {
    }
    
    func handleApplicationDidBecomeActiveNotification(notification: NSNotification)
    {
        if !searchInput.isValid {
            updateIndexWithAllCities() { self.tableView.reloadData() }
        }
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
            return tableView.dequeueReusableCellWithIdentifier("SpecialListCell", forIndexPath: indexPath) 
        }
        else
        {
            let city = citiesIndex[indexPath.section].cities[indexPath.row]
      
            let
            cell = tableView.dequeueReusableCellWithIdentifier("CitiesListCell", forIndexPath: indexPath) 
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
        header = tableView.dequeueReusableCellWithIdentifier("CitiesListHeader")!
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
        if scrollView.contentSize.height > scrollView.bounds.height
        {
            let scrolled = scrollView.contentOffset.y > 0
            let offset: CGFloat = scrolled ? max(-44, -scrollView.contentOffset.y) : 0
        
            animateInfoBarScrollWithOffset(offset)
        }
    }
    
    func scrollViewDidEndDragging(scrollView: UIScrollView, willDecelerate decelerate: Bool)
    {
        if scrollView.contentSize.height > scrollView.bounds.height
        {
            let offset: CGFloat = scrollView.contentOffset.y > 0 ? -44 : 0
        
            animateInfoBarScrollWithOffset(offset)
        
            if scrollView.contentOffset.y < searchBar.bounds.height {
                tableView.adjustContentOffsetForHeaderOfHeight(searchBar.bounds.height)
            }
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
            
            UIView.animateWithDuration(0.2, delay: 0, usingSpringWithDamping: 0.9, initialSpringVelocity: 5, options: [], animations: animations, completion: nil)
        }
    }    
    
    // MARK: UISearchBarDelegate methods
    
    func searchBarTextDidBeginEditing(searchBar: UISearchBar)
    {
        searchBar.setShowsCancelButton(true, animated: true)
    }
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String)
    {
        searchInput = MMTSearchInput(searchBar.text!)
        searchBar.text = searchInput.stringValue

        if searchInput.isValid
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
        searchBar.resignFirstResponder()
        searchBar.setShowsCancelButton(false, animated: true)
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
            
            if self.locationManager.location == nil
            {
                self.citiesIndex = index
                completion()
                return
            }
            
            self.citiesStore.findCityForLocation(self.locationManager.location!) {
                (city: MMTCity?, error: NSError?) in

                if let currentCity = city
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
        let queryCompletion: MMTCitiesQueryCompletion =
        {
            self.citiesIndex = [
                MMTCitiesGroup(type: .SearchResults, cities: $0),
                MMTCitiesGroup(type: .NotFound, cities: []),
            ]
            
            completion()
        }
        
        citiesStore.getCitiesMatchingCriteria(criteria)
        {
            if $0.count > 0 { queryCompletion($0) }
                
            else { self.citiesStore.findCitiesMatchingCriteria(criteria){ queryCompletion($0) }}
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