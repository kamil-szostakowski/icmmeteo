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
    
    private static var currentCityPriv: MMTCity?
    
    static var currentCity: MMTCity
    {
        if currentCityPriv == nil {
            currentCityPriv = MMTCity(name: "Obecna lokalizacja", region: "", location: CLLocation())
        }
        
        return currentCityPriv!
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
        let name = placemark.locality ?? placemark.name!
        let region = placemark.administrativeArea ?? ""
        
        self.init(name: name, region: region, location: placemark.location!)
    }
    
    // MARK: Helper methods
    
    private class var entityDescription: NSEntityDescription
    {
        return NSEntityDescription.entityForName("MMTCity", inManagedObjectContext: MMTDatabase.instance.context)!
    }
}