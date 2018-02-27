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
    
    @IBOutlet var searchBar: UISearchBar!
    @IBOutlet var tableView: UITableView!    
        
    // MARK: Properties
    var selectedCity: MMTCityProt?
    
    fileprivate var lastUpdate: Date?
    fileprivate var searchInput: MMTSearchInput!
    fileprivate var citiesIndex: MMTCitiesIndex!
    fileprivate var citiesStore: MMTCitiesStore!
    fileprivate var currentLocation: MMTCityProt?
    fileprivate var service: MMTLocationService!
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
        if let controller = segue.destination as? MMTMeteorogramController {            
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
        citiesStore = MMTCitiesStore()
        
        setupTableView()
    }
    
    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)
        
        setupSearchBar()
        setupLocationService()
        
        updateIndex {
            self.tableView.reloadData()
            self.updateIndexWithCurrentLocation {
                self.updateCurrentLocationRow()
                self.setupNotificationHandler()
            }
        }
        
        analytics?.sendScreenEntryReport(MMTAnalyticsCategory.Locations.rawValue)
        
        if selectedCity != nil {
            perform(segue: .DisplayMeteorogram, sender: self)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool)
    {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc func handleApplicationDidBecomeActiveNotification(_ notification: Notification)
    {        
        updateIndexWithCurrentLocation(next: updateCurrentLocationRow)
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
    
    fileprivate func setupNotificationHandler()
    {
        let handler = #selector(handleApplicationDidBecomeActiveNotification(_:))
        NotificationCenter.default.addObserver(self, selector: handler, name: .UIApplicationDidBecomeActive, object: nil)
    }
    
    fileprivate func setupLocationService()
    {
        service = UIApplication.shared.locationService
        
        let handler = #selector(handleLocationDidChange(notification:))
        NotificationCenter.default.addObserver(self, selector: handler, name: MMTLocationChangedNotification, object: nil)
    }
}

// Data update extension
extension MMTCitiesListController
{
    // MARK: Data update methods
    fileprivate func updateIndex(completion: MMTCompletion)
    {
        citiesStore.getAllCities {
            self.citiesIndex =  MMTCitiesIndex($0, currentCity: self.currentLocation)
            completion()
        }
    }
    
    fileprivate func updateIndex(criteria: String, completion: @escaping MMTCompletion)
    {
        citiesStore.findCitiesMatchingCriteria(criteria) {
            self.citiesIndex = MMTCitiesIndex(searchResult: $0)
            completion()
        }
    }
    
    fileprivate func updateIndexWithCurrentLocation(next completion: @escaping MMTCompletion)
    {        
        guard let location = service.currentLocation else {
            return
        }
        
        citiesStore.findCityForLocation(location) { (city: MMTCityProt?, error: MMTError?) in
            
            // Maybe we should update the current location if failed
            guard let currentCity = city, error == nil else { return }
            guard currentCity.name.count > 0 else { return }
            
            let allCities = self.citiesIndex[[.Favourites, .Capitals]]
            self.currentLocation = currentCity
            self.citiesIndex = MMTCitiesIndex(allCities, currentCity: currentCity)
            
            completion()
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
        searchInput = MMTSearchInput(searchText)
        searchBar.text = searchInput.stringValue
        
        if searchInput.isValid {
            updateIndex(criteria: searchText) { self.tableView.reloadData() }
        }
        else {
            updateIndex() { self.tableView.reloadData() }
        }
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar)
    {
        resetSearchBar()
        updateIndex() { self.tableView.reloadData() }
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar)
    {
        updateIndex() { self.tableView.reloadData() }
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
            perform(segue: .DisplayMapScreen, sender: self)
            return
        }
        
        let city = citiesIndex[indexPath.section].cities[indexPath.row]
        
        selectedCity = city
        perform(segue: .DisplayMeteorogram, sender: self)
        
        guard let action = MMTAnalyticsAction(group: citiesIndex[indexPath.section].type) else {
            return
        }
        
        analytics?.sendUserActionReport(.Locations, action: action, actionLabel: city.name)
    }
    
    // MARK: Table view helper methods
    fileprivate func updateCurrentLocationRow()
    {
        guard searchInput.isValid == false else { return }
        tableView.reloadData()
    }
}

// Location service extension
extension MMTCitiesListController
{
    // MARK: Location service methods
    @objc func handleLocationDidChange(notification: Notification)
    {
        if service.currentLocation != nil {
            updateIndexWithCurrentLocation(next: self.updateCurrentLocationRow)
        } else {
            currentLocation = nil
            updateIndex() { self.tableView.reloadData() }
        }
    }
}
