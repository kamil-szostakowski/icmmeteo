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
import CoreSpotlight

typealias MMTCompletion = () -> Void

class MMTCitiesListController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate, CLLocationManagerDelegate
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
    var selectedCity: MMTCityProt?
    
    private var locationManager: CLLocationManager!
    private var searchInput: MMTSearchInput!
    private var citiesIndex: [MMTCitiesGroup]!
    private var citiesStore: MMTCitiesStore!
    private var cityOfCurrentLocation: MMTCityProt?
    private var shouldDisplayMeteorogram = false
    
    private let kCurrentLocationKey = "location"
    
    // MARK: Controller methods
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        searchInput = MMTSearchInput("")
        citiesIndex = MMTCitiesIndex()
        citiesStore = MMTCitiesStore(db: MMTDatabase.instance)
        
        setupLocationManager()
        setupHeader()
    }
    
    override func viewWillAppear(animated: Bool)
    {
        super.viewWillAppear(animated)
        
        resetSearchBar()
        updateIndexWithAllCities() {
        
            self.setupNotificationHandler()
            self.tableView.reloadData()
        }
        
        analytics?.sendScreenEntryReport(MMTAnalyticsCategory.Locations.rawValue)
        
        if selectedCity != nil {
            performSegueWithIdentifier(MMTSegue.DisplayMeteorogram, sender: self)
        }        
    }
    
    override func viewWillDisappear(animated: Bool)
    {
        super.viewWillDisappear(animated)
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?)
    {
        if segue.identifier == MMTSegue.DisplayMeteorogram
        {
            let
            controller = segue.destinationViewController as! MMTMeteorogramController
            controller.meteorogramStore = meteorogramStore
            controller.city = selectedCity
            
            selectedCity = nil
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
    }
    
    private func setupNotificationHandler()
    {
        let handler = Selector("handleApplicationDidBecomeActiveNotification:")
        let notification = UIApplicationDidBecomeActiveNotification
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: handler, name: notification, object: nil)
    }
    
    // MARK: CLLocationManagerDelegate
    
    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus)
    {
        let authorized = status == .AuthorizedWhenInUse
    
        if authorized {
            locationManager.startMonitoringSignificantLocationChanges()
            updateIndexWithCityOfCurrentLocation() { self.tableView.reloadData() }
        }
        
        if !authorized {
            locationManager.stopMonitoringSignificantLocationChanges()
        }

        updateIndexWithAllCities() { self.tableView.reloadData() }
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation])
    {
        if !searchInput.isValid {
            updateIndexWithCityOfCurrentLocation() { self.tableView.reloadData() }
        }
    }
    
    // MARK: Actions
    
    @IBAction func unwindToListOfCities(unwindSegue: UIStoryboardSegue)
    {
        guard let mapController = unwindSegue.sourceViewController as? MMTCityMapPickerController else { return }
        guard let city = mapController.selectedCity else { return }
        
        selectedCity = city
        analytics?.sendUserActionReport(.Locations, action: .LocationDidSelectOnMap, actionLabel: city.name)
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
        
        guard sectionType != .NotFound else {
            return tableView.dequeueReusableCellWithIdentifier("SpecialListCell", forIndexPath: indexPath) 
        }
        
        let city = citiesIndex[indexPath.section].cities[indexPath.row]
      
        let
        cell = tableView.dequeueReusableCellWithIdentifier("CitiesListCell", forIndexPath: indexPath)
        cell.detailTextLabel?.text = sectionType != .CurrentLocation ? city.region : "Obecna lokalizacja"
        cell.textLabel!.text = city.name
            
        return cell
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat
    {
        return citiesIndex[section].type.description != nil ? 30 : 0
    }

    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView?
    {
        guard let headerTitle = citiesIndex[section].type.description else {
            return nil
        }
        
        let
        header = tableView.dequeueReusableCellWithIdentifier("CitiesListHeader")!
        header.textLabel?.text = headerTitle
        
        return header
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)
    {
        guard citiesIndex[indexPath.section].type != .NotFound else {
            performSegueWithIdentifier(MMTSegue.DisplayMapScreen, sender: self)
            return
        }
        
        let city = citiesIndex[indexPath.section].cities[indexPath.row]
        
        selectedCity = city
        performSegueWithIdentifier(MMTSegue.DisplayMeteorogram, sender: self)
        
        guard let action = MMTAnalyticsAction(group: citiesIndex[indexPath.section].type) else { return }

        analytics?.sendUserActionReport(.Locations, action: action, actionLabel: city.name)
    }
    
    // MARK: UIScrollViewDelegate methods
    
    func scrollViewDidScroll(scrollView: UIScrollView)
    {
        guard scrollView.contentSize.height > scrollView.bounds.height else {
            return
        }

        let scrolled = scrollView.contentOffset.y > 0
        let offset: CGFloat = scrolled ? max(-44, -scrollView.contentOffset.y) : 0
        
        animateInfoBarScrollWithOffset(offset)
    }
    
    func scrollViewDidEndDragging(scrollView: UIScrollView, willDecelerate decelerate: Bool)
    {
        guard scrollView.contentSize.height > scrollView.bounds.height else {
            return
        }
        
        let offset: CGFloat = scrollView.contentOffset.y > 0 ? -44 : 0
        animateInfoBarScrollWithOffset(offset)
        
        if scrollView.contentOffset.y < searchBar.bounds.height {
            tableView.adjustContentOffsetForHeaderOfHeight(searchBar.bounds.height)
        }
    }
    
    private func animateInfoBarScrollWithOffset(offset: CGFloat)
    {
        let alpha: CGFloat = offset < 0 ? 0 : 1
        
        guard topSpacing.constant != offset else {
            return
        }        
        
        let animations = { () -> Void in
            self.topSpacing.constant = offset
            self.infoBar.alpha = alpha
            self.view.layoutIfNeeded()
        }
            
        UIView.animateWithDuration(0.2, delay: 0, usingSpringWithDamping: 0.9, initialSpringVelocity: 5, options: [], animations: animations, completion: nil)
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
        resetSearchBar()
        updateIndexWithAllCities() { self.tableView.reloadData() }
    }
    
    func searchBarTextDidEndEditing(searchBar: UISearchBar)
    {
        updateIndexWithAllCities() { self.tableView.reloadData() }
    }
    
    // MARK: Data update methods
    
    private func updateIndexWithAllCities(completion: MMTCompletion)
    {
        citiesStore.getAllCities()
        {
            self.citiesIndex =  MMTCitiesIndex.indexForCities($0, currentCity: self.cityOfCurrentLocation)
            completion()
        }
    }
    
    private func updateIndexWithCitiesMatchingCriteria(criteria: String, completion: MMTCompletion)
    {
        citiesStore.findCitiesMatchingCriteria(criteria)
        {
            self.citiesIndex = MMTCitiesIndex.indexForSearchResult($0)
            completion()
        }
    }
    
    private func updateIndexWithCityOfCurrentLocation(completion: MMTCompletion)
    {
        guard let location = self.locationManager.location else {
            return
        }
        
        citiesStore.findCityForLocation(location) { (city: MMTCityProt?, error: MMTError?) in
            
            guard let currentCity = city else { return }

            self.cityOfCurrentLocation = currentCity
            self.citiesIndex =  MMTCitiesIndex.indexForCities(self.citiesIndex.allCities, currentCity: currentCity)
            
            completion()
        }
    }    
    
    // MARK: Helper methods
    
    private func resetSearchBar()
    {
        searchBar.resignFirstResponder()
        searchBar.setShowsCancelButton(false, animated: true)
        searchBar.text = ""
    }
}