//
//  MMTGridBasedClimateModelStore.swift
//  MobileMeteo
//
//  Created by Kamil Szostakowski on 20.08.2015.
//  Copyright (c) 2015 Kamil Szostakowski. All rights reserved.
//

import Foundation
import CoreLocation

public typealias MMTGridModelMeteorogramQuery = (location: CLLocation, date: NSDate, locationName: String?)

public class MMTGridClimateModelStore: MMTClimateModelStore
{    
    func getMeteorogramForLocation(location: CLLocation, completion: MMTFetchMeteorogramCompletion) { fatalError("") }
}