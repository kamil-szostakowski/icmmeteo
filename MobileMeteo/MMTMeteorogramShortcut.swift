//
//  MMTMeteorogramPreviewShortcut.swift
//  MobileMeteo
//
//  Created by szostakowskik on 15.12.2017.
//  Copyright © 2017 Kamil Szostakowski. All rights reserved.
//

import CoreLocation
import MeteoModel

struct MMTMeteorogramShortcut : MMTShortcut
{
    // MARK: Properties
    let city: MMTCityProt
    let climateModel: MMTClimateModel
    
    var identifier: String
    {
        let type = climateModel.type.rawValue
        let coords = city.location.coordinate
        
        return "meteorogram/\(type)/\(city.name)/\(city.region)/\(coords.latitude):\(coords.longitude)"
    }
    
    var destination: MMTNavigator.MMTDestination {
        return .meteorogram(climateModel, city)
    }
    
    // MARK: Initializers
    init(model: MMTClimateModel, city: MMTCityProt)
    {
        self.city = city
        self.climateModel = model
    }
}
