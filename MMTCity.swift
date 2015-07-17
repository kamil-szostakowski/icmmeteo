//
//  MMTCity.swift
//  Created by Kamil Szostakowski on 15.07.2015.
//

import Foundation
import CoreLocation
import CoreData

@objc(MMTCity)
class MMTCity: NSManagedObject
{
    // MARK: Properties
    
    @NSManaged var name: String
    @NSManaged var region: String
    @NSManaged var lat: NSNumber
    @NSManaged var lng: NSNumber
    
    var location: CLLocation {
        return CLLocation(latitude: lat.doubleValue, longitude: lng.doubleValue)
    }
    
    // MARK: Initializers
    
    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }
    
    init(name: String, region: String, location: CLLocation)
    {
        super.init(entity: MMTCity.entityDescription, insertIntoManagedObjectContext: nil)
                
        self.name = name
        self.region = region
        self.lat = location.coordinate.latitude
        self.lng = location.coordinate.longitude
    }
    
    convenience init(name: String, location: CLLocation)
    {
        self.init(name: name, region: "", location: location)
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
