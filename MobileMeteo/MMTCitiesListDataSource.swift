//
//  MMTCitiesListDataSource.swift
//  MobileMeteo
//
//  Created by szostakowskik on 06.06.2018.
//  Copyright © 2018 Kamil Szostakowski. All rights reserved.
//

import Foundation
import MeteoModel

class MMTCitiesListDataSource : NSObject, UITableViewDataSource, UITableViewDelegate
{
    // MARK: Properties
    private var citiesIndex: MMTCitiesIndex
    private var onSelection: (MMTSegue, MMTCityProt?) -> Void
    
    let sectionHeaderIdentifier = "CitiesListHeader"
    
    // MARK: Initializers
    init(selectionHandler: @escaping (MMTSegue, MMTCityProt?) -> Void)
    {
        citiesIndex = MMTCitiesIndex()
        onSelection = selectionHandler
        super.init()
    }
    
    // MARK: Interface methods
    func update(cities: [MMTCityProt])
    {
        let currentLocation = citiesIndex[[.CurrentLocation]].first
        citiesIndex = MMTCitiesIndex(cities, currentCity: currentLocation)
    }
    
    func update(currentLocation: MMTCityProt?)
    {
        let allCities = citiesIndex[[.Favourites, .Capitals]]
        citiesIndex = MMTCitiesIndex(allCities, currentCity: currentLocation)
    }
    
    func update(searchResults: [MMTCityProt])
    {
        citiesIndex = MMTCitiesIndex(searchResult: searchResults)
    }
    
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
        if citiesIndex[indexPath.section].type == .NotFound {
            onSelection(.DisplayMapScreen, nil)
            return
        }
        
        let city = citiesIndex[indexPath.section].cities[indexPath.row]
        onSelection(.DisplayMeteorogram, city)
        
        guard let action = MMTAnalyticsAction(group: citiesIndex[indexPath.section].type) else {
            return
        }
        
        analytics?.sendUserActionReport(.Locations, action: action, actionLabel: city.name)
    }
}
