//
//  MMTMeteorogramQuery.swift
//  MobileMeteo
//
//  Created by Kamil Szostakowski on 01.07.2015.
//  Copyright (c) 2015 Kamil Szostakowski. All rights reserved.
//

import Foundation
import CoreLocation

public class MMTGridModelMeteorogramQuery: NSObject
{
    // MARK: properties
    
    public let date: NSDate
    public let location: CLLocation
    public let locationName: String?
    
    // MARK: initializers
    
    public init(location: CLLocation, date: NSDate, name: String?)
    {
        self.location = location
        self.date = date
        self.locationName = name

        super.init()
    }    
    
    public convenience init(location: CLLocation, name: String)
    {
        self.init(location: location, date: NSDate(), name: name)
    }

    public convenience init(location: CLLocation)
    {
        self.init(location: location, date: NSDate(), name: nil)
    }
}
