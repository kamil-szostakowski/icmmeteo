//
//  MMTCityCategory.swift
//  MobileMeteo
//
//  Created by Kamil Szostakowski on 27.08.2015.
//  Copyright (c) 2015 Kamil Szostakowski. All rights reserved.
//

import Foundation
import CoreLocation
import CoreData

extension MMTCity
{
    var location: CLLocation {
        return CLLocation(latitude: lat.doubleValue, longitude: lng.doubleValue)
    }
    
    var isFavourite: Bool {
        return favourite.boolValue
    }
    
    var isCapital: Bool {
        return capital.boolValue
    }
    
    // MARK: Initializers
    
    convenience init(name: String, region: String, location: CLLocation)
    {
        self.init(entity: MMTCity.entityDescription, insertIntoManagedObjectContext: nil)
        
        self.name = name
        self.region = region
        self.lat = location.coordinate.latitude
        self.lng = location.coordinate.longitude
        self.capital = false
        self.favourite = false
    }    
    
    convenience init(placemark: CLPlacemark)
    {
        self.init(name: placemark.name, region: placemark.administrativeArea, location: placemark.location)        
    }
    
    // MARK: Helper methods
    
    private class var entityDescription: NSEntityDescription
    {
        return NSEntityDescription.entityForName("MMTCity", inManagedObjectContext: MMTDatabase.instance.managedObjectContext)!
    }
}