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

@objc(MMTCityProt)
protocol MMTCityProt
{
    var name: String { get set }
    var region: String { get set }
    var location: CLLocation { get set }
    var isFavourite: Bool { get set }
    var isCapital: Bool { get set }
}

extension MMTCity: MMTCityProt
{
    var location: CLLocation
    {
        get { return CLLocation(latitude: lat.doubleValue, longitude: lng.doubleValue) }
        set
        {
            lat = newValue.coordinate.latitude
            lng = newValue.coordinate.longitude
        }
    }
    
    var isFavourite: Bool
    {
        get { return favourite.boolValue }
        set { favourite = newValue }
    }
    
    var isCapital: Bool
    {
        get { return capital.boolValue }
        set { capital = newValue }
    }
    
    // MARK: Initializers
    
    convenience init(name: String, region: String, location: CLLocation)
    {
        self.init(entity: MMTCity.entityDescription, insertIntoManagedObjectContext: nil)
        
        self.name = name
        self.region = region
        self.location = location
        self.isCapital = false
        self.isFavourite = false
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