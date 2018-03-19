//
//  MMTPredefinedCitiesFileStore.swift
//  MobileMeteo
//
//  Created by Kamil on 07.03.2017.
//  Copyright © 2017 Kamil Szostakowski. All rights reserved.
//

import Foundation
import CoreLocation

public struct MMTPredefinedCitiesFileStore
{
    // MARK: Properties
    private typealias MMTCitiesArray = [[String: AnyObject]]
    
    // MARK: Initializer
    public init() {}
        
    // MARK: Interface methods
    public func getPredefinedCitiesFromFile(_ file: String) -> [MMTCityProt]
    {
        guard let citiesList = getPredefinedCitiesFromJsonFile(file) else {
            return []
        }
        
        var result = [MMTCityProt]()
        for cityDict in citiesList
        {
            let name = cityDict["name"] as! String
            let lat = cityDict["latitude"] as! Double
            let lng = cityDict["longitude"] as! Double
            let region = cityDict["region"] as! String
            let location = CLLocation(latitude: lat, longitude: lng)
            
            var
            city = MMTCityProt(name: name, region: region, location: location)
            city.isCapital = true
            city.isFavourite = false

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
