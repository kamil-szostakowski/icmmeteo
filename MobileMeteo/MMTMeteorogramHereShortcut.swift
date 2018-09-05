//
//  MMTCurrentLocationMeteorogramPreviewShortcut.swift
//  MobileMeteo
//
//  Created by szostakowskik on 22.12.2017.
//  Copyright © 2017 Kamil Szostakowski. All rights reserved.
//

import CoreLocation
import MeteoModel

struct MMTMeteorogramHereShortcut: MMTShortcut
{
    // MARK: Properties
    let climateModel: MMTClimateModel
    
    var identifier: String {
        return "currentlocation"
    }
    
    var destination: MMTNavigator.MMTDestination {
        return .meteorogramHere(climateModel)
    }
    
    // MARK: initializers
    init(model: MMTClimateModel)
    {
        climateModel = model
    }
}
