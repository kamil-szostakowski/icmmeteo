//
//  MMTCityProt.swift
//  MeteoModel
//
//  Created by szostakowskik on 05.03.2018.
//  Copyright © 2018 Kamil Szostakowski. All rights reserved.
//

import Foundation
import CoreLocation

public struct MMTCityProt
{
    public var name: String
    public var region: String
    public var location: CLLocation
    public var isFavourite: Bool
    public var isCapital: Bool
    
    public init(name: String, region: String, location: CLLocation)
    {
        self.name = name
        self.region = region
        self.location = location
        self.isCapital = false
        self.isFavourite = false
    }
    
    public init?(placemark: MMTPlacemark)
    {
        guard let name = placemark.locality ?? placemark.name else { return nil }
        guard let region = placemark.administrativeArea else { return nil }
        guard let location = placemark.location else { return nil }
        guard placemark.ocean == nil else { return nil }
        
        self.init(name: name, region: region, location: location)
    }
}
