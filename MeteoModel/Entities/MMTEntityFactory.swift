//
//  MMTEntityFactory.swift
//  MeteoModel
//
//  Created by szostakowskik on 02.03.2018.
//  Copyright © 2018 Kamil Szostakowski. All rights reserved.
//

import UIKit
import CoreLocation

public protocol MMTEntityFactory
{
    func createCity() -> MMTCityProt
    
    func city(name: String, region: String, location: CLLocation) -> MMTCityProt
    
    func city(placemark: MMTPlacemark) -> MMTCityProt?
}

extension MMTEntityFactory
{
    public func city(name: String, region: String, location: CLLocation) -> MMTCityProt
    {
        let cityProt = createCity()
        
        cityProt.name = name
        cityProt.region = region
        cityProt.location = location
        cityProt.isCapital = false
        cityProt.isFavourite = false
        
        return cityProt
    }
    
    public func city(placemark: MMTPlacemark) -> MMTCityProt?
    {
        guard let name = placemark.locality ?? placemark.name else { return nil }
        guard let region = placemark.administrativeArea else { return nil }
        guard let location = placemark.location else { return nil }
        guard placemark.ocean == nil else { return nil }
        
        return city(name: name, region: region, location: location)
    }
}
