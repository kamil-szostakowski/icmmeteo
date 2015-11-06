//
//  MMTGridBasedClimateModelStore.swift
//  MobileMeteo
//
//  Created by Kamil Szostakowski on 20.08.2015.
//  Copyright (c) 2015 Kamil Szostakowski. All rights reserved.
//

import Foundation
import CoreLocation
import CoreGraphics

protocol MMTGridClimateModelStore: MMTClimateModelStore
{    
    var gridNodeSize: Int { get }
    
    var legendSize: CGSize { get }
    
    func getMeteorogramForLocation(location: CLLocation, completion: MMTFetchMeteorogramCompletion)
    
    func getMeteorogramLegend(completion: MMTFetchMeteorogramCompletion)
}