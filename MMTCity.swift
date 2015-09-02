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

public class MMTCity: NSManagedObject
{
    @NSManaged public var lat: NSNumber
    @NSManaged public var lng: NSNumber
    @NSManaged public var name: String
    @NSManaged public var region: String
    @NSManaged public var favourite: NSNumber
    @NSManaged public var capital: NSNumber
}
