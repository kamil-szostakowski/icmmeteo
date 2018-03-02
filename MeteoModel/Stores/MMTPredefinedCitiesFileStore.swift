//
//  MMTPredefinedCitiesFileStore.swift
//  MobileMeteo
//
//  Created by Kamil on 07.03.2017.
//  Copyright © 2017 Kamil Szostakowski. All rights reserved.
//

import Foundation
import CoreLocation

public class MMTPredefinedCitiesFileStore
{
    // MARK: Properties
    private typealias MMTCitiesArray = [[String: AnyObject]]
    private var entityFactory: MMTEntityFactory
    
    // MARK: Initializers
    public init(factory: MMTEntityFactory)
    {
        entityFactory = factory
    }
    
    // MARK: Interface methods
    public func getPredefinedCitiesFromFile(_ file: String) -> [MMTCityProt]
    {
        guard let citiesList = getPredefinedCitiesFromJsonFile(file) else {
            return []
        }
        
        var result = [MMTCityProt]()
        for city in citiesList
        {
            let name = city["name"] as! String
            let lat = city["latitude"] as! Double
            let lng = city["longitude"] as! Double
            let region = city["region"] as! String
                        let
            city = entityFactory.city(name: name, region: region, location: CLLocation(latitude: lat, longitude: lng))
            city.isCapital = true
            
            result.append(city)
        }
        
        return result
    }
    
    // MARK: Helper methods
    private func getPredefinedCitiesFromJsonFile(_ path: String) -> MMTCitiesArray?
    {
        guard let data = try? Data(contentsOf: URL(fileURLWithPath: path)) else { return nil }
        guard let json = try? JSONSerialization.jsonObject(with: data, options: .mutableContainers) else {
            return nil
        }
        
        return json as? MMTCitiesArray
    }
}
