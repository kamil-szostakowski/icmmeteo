//
//  MMTDetailedMapPreviewShortcut.swift
//  MobileMeteo
//
//  Created by szostakowskik on 15.12.2017.
//  Copyright © 2017 Kamil Szostakowski. All rights reserved.
//

import MeteoModel

struct MMTDetailedMapShortcut : MMTShortcut
{
    // MARK: Properties
    let climateModel: MMTClimateModel
    let detailedMap: MMTDetailedMapType
    
    var identifier: String {
        return "map/\(climateModel.type.rawValue)/\(detailedMap.rawValue)"
    }
    
    var destination: MMTNavigator.MMTDestination {
        return .detailedMap(climateModel, detailedMap)
    }
    
    // MARK: Initializer
    init(model: MMTClimateModel, map: MMTDetailedMapType)
    {
        self.climateModel = model
        self.detailedMap = map
    }
}
