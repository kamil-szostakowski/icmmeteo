//
//  MMTCity.swift
//  
//
//  Created by Kamil Szostakowski on 27.08.2015.
//
//

import Foundation
import CoreData

@objc(MMTCity)
open class MMTCity: NSManagedObject
{
    @NSManaged var lat: NSNumber
    @NSManaged var lng: NSNumber
    @NSManaged var name: String
    @NSManaged var region: String
    @NSManaged var favourite: NSNumber
    @NSManaged var capital: NSNumber
}
