//
//  MMTCitiesIndex.swift
//  MobileMeteo
//
//  Created by Kamil Szostakowski on 27.01.2016.
//  Copyright © 2016 Kamil Szostakowski. All rights reserved.
//

import Foundation

enum MMTCitiesIndexSectionType: String
{
    case NotFound
    case Capitals
    case Favourites
    case SearchResults
    case CurrentLocation
//    
//    var localizedDescription: String?
//    {
//        var key: String?
//        
//        switch self
//        {
//            case .Capitals: key = "locations.district-capitals"
//            case .Favourites: key = "locations.favourites"
//            default: key = nil
//        }
//        
//        guard let translationKey = key else { return nil }
//        return NSLocalizedString(translationKey, comment: "")
//    }
}

typealias MMTCitiesIndexSection = (type: MMTCitiesIndexSectionType, cities: [MMTCityProt])

struct MMTCitiesIndex
{
    private var content: [MMTCitiesIndexSection]
    
    var sectionCount: Int {
        return content.count
    }
    
    // MARK: Initializers
    
    init()
    {
        content = []
    }
    
    init(_ cities: [MMTCityProt], currentCity: MMTCityProt?)
    {
        content = []

        let favourites = cities.filter(){ $0.isFavourite }
        let capitals = cities.filter(){ $0.isCapital && !$0.isFavourite }
        
        if favourites.count > 0 {
            content.append(MMTCitiesIndexSection(type: .Favourites, cities: favourites))
        }
        
        if capitals.count > 0 {
            content.append(MMTCitiesIndexSection(type: .Capitals, cities: capitals))
        }
        
        if currentCity != nil {
            content.insert(MMTCitiesIndexSection(type: .CurrentLocation, cities: [currentCity!]), atIndex: 0)
        }
    }
    
    init(searchResult: [MMTCityProt])
    {
        content = [
            MMTCitiesIndexSection(type: .SearchResults, cities: searchResult),
            MMTCitiesIndexSection(type: .NotFound, cities: []),
        ]
    }
    
    // MARK: Subscripts
    
    subscript(index: Int) -> MMTCitiesIndexSection
    {
        get { return content[index] }
    }
    
    subscript(section: MMTCitiesIndexSectionType) -> [MMTCityProt]
    {
        get { return content.filter(){ section == $0.type }.flatMap() { $0.cities } }
    }
    
    subscript(sections: [MMTCitiesIndexSectionType]) -> [MMTCityProt]
    {
        get { return content.filter(){ sections.indexOf($0.type) != nil }.flatMap() { $0.cities } }
    }    
}