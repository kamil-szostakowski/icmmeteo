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

class MMTCitiesListController: UIViewController
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

    var climateModel: MMTClimateModel!
    var selectedCity: MMTCityProt?
    
    fileprivate var lastUpdate: Date?
    fileprivate var locationManager: CLLocationManager!
    fileprivate var searchInput: MMTSearchInput!
    fileprivate var citiesIndex: MMTCitiesIndex!
    fileprivate var citiesStore: MMTCitiesStore!
    fileprivate var cityOfCurrentLocation: MMTCityProt?
    fileprivate var shouldDisplayMeteorogram = false
    fileprivate var meteorogramStore: MMTMeteorogramStore!
    fileprivate let sectionHeaderIdentifier = "CitiesListHeader"
    
    // MARK: Actions
    
    @IBAction func unwindToListOfCities(_ unwindSegue: UIStoryboardSegue)
    {
        guard let mapController = unwindSegue.source as? MMTCityMapPickerController else { return }
        guard let city = mapController.selectedCity else { return }
        
        selectedCity = city
        analytics?.sendUserActionReport(.Locations, action: .LocationDidSelectOnMap, actionLabel: city.name)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        if let controller = segue.destination as? MMTCityMapPickerController
        {
            controller.climateModel = climateModel
        }
        
        if let controller = segue.destination as? MMTMeteorogramController
        {
            controller.climateModel = climateModel
        }
        
        if segue.identifier == MMTSegue.DisplayMeteorogram
        {
            let
            controller = segue.destination as! MMTMeteorogramController
            controller.city = selectedCity
            
            selectedCity = nil
        }
    }
}

// Lifecycle extension
extension MMTCitiesListController
{
    // Mark: Lifecycle methods
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        searchInput = MMTSearchInput("")
        citiesIndex = MMTCitiesIndex()
        citiesStore = MMTCitiesStore(db: MMTDatabase.instance, geocoder: MMTCityGeocoder(generalGeocoder: CLGeocoder()))
        meteorogramStore = MMTMeteorogramStore(model: climateModel, date: Date())
        
        setupTableView()
        setupLocationManager()
        setupInfoBar()
    }
    
    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)
        
        setupSearchBar()
        updateForecastStartDate()
        updateIndexWithAllCities() {
            
            self.tableView.reloadData()
            self.updateIndexWithCityOfCurrentLocation{
                
                self.setupNotificationHandler()
                guard self.searchInput.isValid == false else { return }
                self.tableView.reloadData()
            }
        }
        
        analytics?.sendScreenEntryReport(MMTAnalyticsCategory.Locations.rawValue)
        
        if selectedCity != nil {
            performSegue(withIdentifier: MMTSegue.DisplayMeteorogram, sender: self)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool)
    {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }
    
    func handleApplicationDidBecomeActiveNotification(_ notification: Notification)
    {
        updateForecastStartDate()
        updateIndexWithCityOfCurrentLocation() {
            
            guard self.searchInput.isValid == false else { return }
            self.tableView.reloadData()
        }
    }
}

// Setup extensions
extension MMTCitiesListController
{
    // MARK: Setup methods
    
    fileprivate func setupSearchBar()
    {
        searchBar.accessibilityIdentifier = "cities-search"
        resetSearchBar()
    }
    
    fileprivate func setupTableView()
    {
        let headerNib = UINib(nibName: "MMTCitiesListSectionHeader", bundle: nil)
        tableView.register(headerNib, forHeaderFooterViewReuseIdentifier: sectionHeaderIdentifier)
    }
    
    fileprivate func setupLocationManager()
    {
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
    }
    
    fileprivate func setupInfoBar()
    {
        let formatter = DateFormatter.utcFormatter
        let climateModel = meteorogramStore.climateModel
        
        lblForecastStart.text = MMTLocalizedStringWithFormat("forecast.start: %@", formatter.string(from: meteorogramStore.forecastStartDate))
        lblForecastLenght.text = MMTLocalizedStringWithFormat("forecast.length: %dh, forecast.grid: %dkm", climateModel.forecastLength, climateModel.gridNodeSize)
    }
    
    fileprivate func setupNotificationHandler()
    {
        let handler = #selector(handleApplicationDidBecomeActiveNotification(_:))
        let notification = NSNotification.Name.UIApplicationDidBecomeActive
        
        NotificationCenter.default.addObserver(self, selector: handler, name: notification, object: nil)
    }
}

// Data update extension
extension MMTCitiesListController
{
    // MARK: Data update methods
    
    fileprivate func updateIndexWithAllCities(_ completion: MMTCompletion)
    {
        citiesStore.getAllCities()
            {
                if self.cityOfCurrentLocation?.name.characters.count == 0 {
                    self.cityOfCurrentLocation = nil
                }
                
                self.citiesIndex =  MMTCitiesIndex($0, currentCity: self.cityOfCurrentLocation)
                completion()
        }
    }
    
    fileprivate func updateIndexWithCitiesMatchingCriteria(_ criteria: String, completion: @escaping MMTCompletion)
    {
        citiesStore.findCitiesMatchingCriteria(criteria)
        {
            self.citiesIndex = MMTCitiesIndex(searchResult: $0)
            completion()
        }
    }
    
    fileprivate func updateIndexWithCityOfCurrentLocation(_ completion: @escaping MMTCompletion)
    {
        guard let location = self.locationManager.location else {
            return
        }
        
        citiesStore.findCityForLocation(location) { (city: MMTCityProt?, error: MMTError?) in
            
            guard let currentCity = city, error == nil else { return }
            
            self.cityOfCurrentLocation = currentCity
            self.citiesStore.getAllCities() {
                self.citiesIndex = MMTCitiesIndex($0, currentCity: currentCity)
                completion()
            }
        }
    }
    
    fileprivate func updateForecastStartDate()
    {
        if lastUpdate != nil && Date().timeIntervalSince(lastUpdate!) < TimeInterval(minutes: 5) {
            return
        }
        
        lastUpdate = Date()
        meteorogramStore.getForecastStartDate(){ (date: Date?, error: MMTError?) in
            self.setupInfoBar()
        }
    }
}

// Search bar extension
extension MMTCitiesListController: UISearchBarDelegate
{
    // MARK: UISearchBarDelegate methods
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar)
    {
        searchBar.setShowsCancelButton(true, animated: true)
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String)
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
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar)
    {
        resetSearchBar()
        updateIndexWithAllCities() { self.tableView.reloadData() }
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar)
    {
        updateIndexWithAllCities() { self.tableView.reloadData() }
    }
    
    // MARK: Search bar helper methods
    
    fileprivate func resetSearchBar()
    {
        searchBar.resignFirstResponder()
        searchBar.setShowsCancelButton(false, animated: true)
        searchBar.text = ""
        
        searchInput = MMTSearchInput("")
    }
}

// Table view extension
extension MMTCitiesListController: UITableViewDelegate, UITableViewDataSource
{
    // MARK: UITableViewDelegate methods
    
    func numberOfSections(in tableView: UITableView) -> Int
    {
        return citiesIndex.sectionCount
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        let isSpecialItem = citiesIndex[section].type == .NotFound
        return !isSpecialItem ? citiesIndex[section].cities.count : 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let sectionType = citiesIndex[indexPath.section].type
        
        guard sectionType != .NotFound else {
            
            let
            cell = tableView.dequeueReusableCell(withIdentifier: "FindLocationCell", for: indexPath)
            cell.accessibilityIdentifier = "find-city-on-map"
            
            return cell
        }
        
        let isCurrentLocation = sectionType == .CurrentLocation
        let city = citiesIndex[indexPath.section].cities[indexPath.row]
        let regionName = isCurrentLocation ? MMTTranslationCityCategory[sectionType] : MMTLocalizedString(city.region)
        
        let
        cell = tableView.dequeueReusableCell(withIdentifier: "CitiesListCell", for: indexPath)
        cell.detailTextLabel?.text = regionName
        cell.textLabel!.text = city.name
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat
    {
        let sectionType = citiesIndex[section].type
        let shouldDisplayHeader = sectionType == .Favourites || sectionType == .Capitals
        
        return shouldDisplayHeader ? 30 : 0
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView?
    {
        let translationKey = citiesIndex[section].type
        
        guard let headerTitle = MMTTranslationCityCategory[translationKey] else {
            return nil
        }
        
        let
        header = tableView.dequeueReusableHeaderFooterView(withIdentifier: sectionHeaderIdentifier)!
        header.accessibilityIdentifier = translationKey.rawValue
        header.accessibilityLabel = headerTitle
        header.textLabel?.text = headerTitle
        
        return header
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        guard citiesIndex[indexPath.section].type != .NotFound else {
            performSegue(withIdentifier: MMTSegue.DisplayMapScreen, sender: self)
            return
        }
        
        let city = citiesIndex[indexPath.section].cities[indexPath.row]
        
        selectedCity = city
        performSegue(withIdentifier: MMTSegue.DisplayMeteorogram, sender: self)
        
        guard let action = MMTAnalyticsAction(group: citiesIndex[indexPath.section].type) else { return }
        
        analytics?.sendUserActionReport(.Locations, action: action, actionLabel: city.name)
    }
}

// Location manager extension
extension MMTCitiesListController: CLLocationManagerDelegate
{
    // MARK: CLLocationManagerDelegate
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus)
    {
        let authorized = status == .authorizedWhenInUse
        
        if authorized {
            locationManager.startMonitoringSignificantLocationChanges()
            updateIndexWithCityOfCurrentLocation() { self.tableView.reloadData() }
        }
        
        if !authorized {
            cityOfCurrentLocation = nil
            locationManager.stopMonitoringSignificantLocationChanges()
            updateIndexWithAllCities() { self.tableView.reloadData() }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation])
    {
        updateIndexWithCityOfCurrentLocation() {
            
            guard self.searchInput.isValid == false else { return }
            self.tableView.reloadData()
        }
    }
}

// Info bar animation extension
extension MMTCitiesListController
{
    // MARK: Info bar animation methods
    
    func scrollViewDidScroll(_ scrollView: UIScrollView)
    {
        guard scrollView.contentSize.height > scrollView.bounds.height else {
            return
        }
        
        let scrolled = scrollView.contentOffset.y > 0
        let offset: CGFloat = scrolled ? max(-44, -scrollView.contentOffset.y) : 0
        
        animateInfoBarScrollWithOffset(offset)
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool)
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
    
    fileprivate func animateInfoBarScrollWithOffset(_ offset: CGFloat)
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
        
        UIView.animate(withDuration: 0.2, delay: 0, usingSpringWithDamping: 0.9, initialSpringVelocity: 5, options: [], animations: animations, completion: nil)
    }
}
