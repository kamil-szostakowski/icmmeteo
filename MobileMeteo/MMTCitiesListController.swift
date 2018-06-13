//
//  MMTModelUmController.swift
//  MobileMeteo
//
//  Created by Kamil Szostakowski on 08.07.2015.
//  Copyright (c) 2015 Kamil Szostakowski. All rights reserved.
//

import Foundation
import MeteoModel
import CoreLocation

class MMTCitiesListController: UIViewController, MMTModelControllerDelegate
{        
    // MARK: Outlets
    
    @IBOutlet var searchBar: UISearchBar!
    @IBOutlet var tableView: UITableView!    
        
    // MARK: Properties
    var selectedCity: MMTCityProt?
    
    fileprivate var dataSource: MMTCitiesListDataSource!
    fileprivate var searchBarDelegate: MMTCitiesSearchBarDelegate!
    fileprivate var modelController: MMTCitiesListModelController!
    fileprivate var currentCityModelController: MMTCurrentCityModelController!
    
    fileprivate var currentLocation: CLLocation? {
        return UIApplication.shared.locationService?.currentLocation
    }
    
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
        
        setupTableView()
        setupSearchBar()
        setupModelController()
    }
    
    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)
        
        setupLocationService()
        modelController.activate()
        currentCityModelController.onLocationChange(location: currentLocation)
        analytics?.sendScreenEntryReport(MMTAnalyticsCategory.Locations.rawValue)
        
        if selectedCity != nil {
            perform(segue: .DisplayMeteorogram, sender: self)
        }
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
    
    fileprivate func setupModelController()
    {
        modelController = MMTCitiesListModelController(store: MMTCoreDataCitiesStore())
        modelController.delegate = self
        
        currentCityModelController = MMTCurrentCityModelController(store: MMTCoreDataCitiesStore())
        currentCityModelController.delegate = self
        
        modelController.activate()
        currentCityModelController.activate()
    }
    
    fileprivate func setupLocationService()
    {
        let handler = #selector(handleLocationDidChange(notification:))
        NotificationCenter.default.addObserver(self, selector: handler, name: .locationChangedNotification, object: nil)
    }
}

extension MMTCitiesListController
{
    // MARK: Screen update methods
    func onRowSelection(segue: MMTSegue, city: MMTCityProt?)
    {
        selectedCity = city
        searchBar.reset()
        perform(segue: segue, sender: self)
    }
    
    func onModelUpdate(_ controller: MMTModelController)
    {
        // Accept only successfull updates of the current city
        guard currentCityModelController.requestPending == false, currentCityModelController.error == nil else {
            return
        }
        
        print("Model update")
        if modelController.searchInput.isValid {
            dataSource.update(searchResults: modelController.cities)
        } else if modelController.searchInput.isValid == false && currentCityModelController.requestPending == false {
            dataSource.update(cities: modelController.cities)
            dataSource.update(currentLocation: currentCityModelController.currentCity)
        }
        
        tableView.reloadData()
    }
    
    func onSearchStateChange(phrase: String?)
    {
        modelController.onSearchPhraseChange(phrase: phrase)
    }
    
    @objc func handleLocationDidChange(notification: Notification)
    {
        currentCityModelController.onLocationChange(location: currentLocation)
    }
}
