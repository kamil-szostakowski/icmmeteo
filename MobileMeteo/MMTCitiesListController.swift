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
import MeteoModel

class MMTCitiesListController: UIViewController
{        
    // MARK: Outlets
    
    @IBOutlet var searchBar: UISearchBar!
    @IBOutlet var tableView: UITableView!    
        
    // MARK: Properties
    var selectedCity: MMTCityProt?
    
    fileprivate var lastUpdate: Date?
    fileprivate var citiesStore: MMTCitiesStore!
    fileprivate var service: MMTLocationService!
    fileprivate var dataSource: MMTCitiesListDataSource!
    fileprivate var searchBarDelegate: MMTCitiesSearchBarDelegate!
    
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
        
        citiesStore = MMTCoreDataCitiesStore()
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
        searchBarDelegate = MMTCitiesSearchBarDelegate(handler: self.onSearchStateChange)
        
        searchBar.delegate = searchBarDelegate
        searchBar.accessibilityIdentifier = "cities-search"
        searchBar.reset()
    }
    
    fileprivate func setupTableView()
    {
        let headerNib = UINib(nibName: "MMTCitiesListSectionHeader", bundle: nil)
        dataSource = MMTCitiesListDataSource(selectionHandler: onRowSelection)
        
        tableView.dataSource = dataSource
        tableView.delegate = dataSource
        tableView.register(headerNib, forHeaderFooterViewReuseIdentifier: dataSource.sectionHeaderIdentifier)
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
    fileprivate func updateIndex(completion: () -> Void)
    {
        citiesStore.all {
            self.dataSource.update(cities: $0)
            completion()
        }
    }
    
    fileprivate func updateIndex(criteria: String, completion: @escaping () -> Void)
    {
        citiesStore.cities(maching: criteria) {
            self.dataSource.update(searchResults: $0)
            completion()
        }
    }
    
    fileprivate func updateIndexWithCurrentLocation(next completion: @escaping () -> Void)
    {        
        guard let location = service.currentLocation else {
            return
        }
        
        citiesStore.city(for: location) { (city: MMTCityProt?, error: MMTError?) in
            
            guard let currentCity = city, error == nil else { return }
            guard currentCity.name.count > 0 else { return }
            
            self.dataSource.update(currentLocation: currentCity)
            completion()
        }
    }
    
    fileprivate func updateCurrentLocationRow()
    {        
        guard searchBarDelegate.searchInput.isValid == false else { return }
        tableView.reloadData()
    }
}

// Table view extension
extension MMTCitiesListController
{
    func onRowSelection(segue: MMTSegue, city: MMTCityProt?)
    {
        selectedCity = city
        perform(segue: segue, sender: self)
    }
    
    func onSearchStateChange(phrase: String?)
    {
        guard let searchText = phrase else {
            updateIndex() { self.tableView.reloadData() }
            return
        }
        
        updateIndex(criteria: searchText) { self.tableView.reloadData() }
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
            dataSource.update(currentLocation: nil)
            updateIndex() { self.tableView.reloadData() }
        }
    }
}
