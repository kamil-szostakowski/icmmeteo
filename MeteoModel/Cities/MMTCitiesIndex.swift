//
//  MMTCitiesIndex.swift
//  MobileMeteo
//
//  Created by Kamil Szostakowski on 27.01.2016.
//  Copyright © 2016 Kamil Szostakowski. All rights reserved.
//

import Foundation

public enum MMTCitiesIndexSectionType: String
{
    case NotFound
    case Capitals
    case Favourites
    case SearchResults
    case CurrentLocation
}

public typealias MMTCitiesIndexSection = (type: MMTCitiesIndexSectionType, cities: [MMTCityProt])

public struct MMTCitiesIndex
{
    private var content: [MMTCitiesIndexSection] = []
    
    public var sectionCount: Int {
        return content.count
    }
    
    // MARK: Initializers
    public init() {}
    
    public init(_ cities: [MMTCityProt], currentCity: MMTCityProt?)
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
            content.insert(MMTCitiesIndexSection(type: .CurrentLocation, cities: [currentCity!]), at: 0)
        }                
    }
    
    public init(searchResult: [MMTCityProt])
    {
        content = [
            MMTCitiesIndexSection(type: .SearchResults, cities: searchResult),
            MMTCitiesIndexSection(type: .NotFound, cities: []),
        ]
    }
    
    // MARK: Subscripts
    public subscript(index: Int) -> MMTCitiesIndexSection
    {
        get { return content[index] }
    }
    
    public subscript(section: MMTCitiesIndexSectionType) -> [MMTCityProt]
    {
        get { return content.filter(){ section == $0.type }.flatMap() { $0.cities } }
    }
    
    public subscript(sections: [MMTCitiesIndexSectionType]) -> [MMTCityProt]
    {
        get { return content.filter(){ sections.index(of: $0.type) != nil }.flatMap() { $0.cities } }
    }    
}
