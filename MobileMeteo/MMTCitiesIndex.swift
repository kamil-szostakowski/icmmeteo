//
//  MMTCitiesIndex.swift
//  MobileMeteo
//
//  Created by Kamil Szostakowski on 27.01.2016.
//  Copyright © 2016 Kamil Szostakowski. All rights reserved.
//

import Foundation

enum MMTCityGroup: String
{
    case NotFound
    case Capitals
    case Favourites
    case SearchResults
    case CurrentLocation
    
    var description: String?
    {
        switch self
        {
            case .Capitals: return "Miasta wojewódzkie"
            case .Favourites: return "Ulubione"
            default: return nil
        }
    }
}

typealias MMTCitiesGroup = (type: MMTCityGroup, cities: [MMTCityProt])
typealias MMTCitiesIndex = [MMTCitiesGroup]

extension CollectionType where Generator.Element == MMTCitiesGroup
{
    // MARK: Init methods
    
    static func indexForCities(cities: [MMTCityProt]) -> MMTCitiesIndex
    {
        return indexForCities(cities, currentCity: nil)
    }
    
    static func indexForCities(cities: [MMTCityProt], currentCity: MMTCityProt?) -> MMTCitiesIndex
    {
        var index = MMTCitiesIndex()
        
        let favourites = cities.filter(){ $0.isFavourite }
        let capitals = cities.filter(){ $0.isCapital && !$0.isFavourite }
        
        if favourites.count > 0 {
            index.append(MMTCitiesGroup(type: .Favourites, cities: favourites))
        }
        
        if capitals.count > 0 {
            index.append(MMTCitiesGroup(type: .Capitals, cities: capitals))
        }
        
        if currentCity != nil {
            index.insert(MMTCitiesGroup(type: .CurrentLocation, cities: [currentCity!]), atIndex: 0)
        }
        
        return index
    }
    
    static func indexForSearchResult(cities: [MMTCityProt]) -> MMTCitiesIndex
    {
        return [
            MMTCitiesGroup(type: .SearchResults, cities: cities),
            MMTCitiesGroup(type: .NotFound, cities: []),
        ]
    }
    
    // MARK: Properties
    
    var allCities: [MMTCityProt]
    {
        return self.flatMap { $0.cities }
    }
}