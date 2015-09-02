//
//  MMTCitiesIndex.swift
//  MobileMeteo
//
//  Created by Kamil Szostakowski on 01.09.2015.
//  Copyright (c) 2015 Kamil Szostakowski. All rights reserved.
//

import Foundation

enum MMTCityGroup
{
    case Others
    case Favourites
    case Capitals
    
    var description: String
    {
        switch self
        {
            case .Others: return "Pozostałe"
            case .Favourites: return "Ulubione"
            case .Capitals: return "Miasta wojewódzkie"
        }
    }
}

class MMTCitiesIndex: NSObject
{
    typealias MMTCitiesGroup = (type: MMTCityGroup, cities: [MMTCity])
    
    private let index: [MMTCitiesGroup]
    
    // MARK: Initializers
    
    init(cities: [MMTCity])
    {
        var groups = [MMTCitiesGroup]()
        
        let favourites = cities.filter(){ $0.isFavourite }
        let capitals = cities.filter(){ $0.isCapital && !$0.isFavourite }
        let others = cities.filter(){ !$0.isCapital && !$0.isFavourite }
        
        if others.count>0 {
            groups.append(MMTCitiesGroup(type: .Others, cities:others))
        }
        
        if favourites.count>0 {
            groups.append(MMTCitiesGroup(type: .Favourites, cities:favourites))
        }
        
        if capitals.count>0 {
            groups.append(MMTCitiesGroup(type: .Capitals, cities:capitals))
        }
        
        index = groups
        
        super.init()
    }
    
    convenience override init()
    {
        self.init(cities: [])
    }
    
    // MARK: Methods
    
    func getAllGroups() -> [MMTCityGroup]
    {
        return index.map() { $0.type }
    }
    
    func labelForGroupAtIndex(section: Int) -> String
    {
        return index[section].type.description
    }
    
    func citiesForGroupAtIndex(section: Int) -> [MMTCity]
    {
        return index[section].cities
    }
    
    func typeForGroupAtIndex(section: Int) -> MMTCityGroup
    {
        return index[section].type
    }
    
    func cityAtIndexPath(indexPath: NSIndexPath) -> MMTCity
    {
        return index[indexPath.section].cities[indexPath.row]
    }
}