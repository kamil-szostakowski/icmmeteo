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

public protocol MMTCityProt: AnyObject
{
    var name: String { get set }
    var region: String { get set }
    var location: CLLocation { get set }
    var isFavourite: Bool { get set }
    var isCapital: Bool { get set }
}

extension MMTCity: MMTCityProt
{
    // MARK: Properties
    public var location: CLLocation
    {
        get { return CLLocation(latitude: lat.doubleValue, longitude: lng.doubleValue) }
        set {
            lat = NSNumber(floatLiteral: newValue.coordinate.latitude)
            lng = NSNumber(floatLiteral: newValue.coordinate.longitude)
        }
    }
    
    public var isFavourite: Bool
    {
        get { return favourite.boolValue }
        set { favourite = newValue as NSNumber }
    }
    
    public var isCapital: Bool
    {
        get { return capital.boolValue }
        set { capital = newValue as NSNumber }
    }
        
    // MARK: Helper methods
    class var entityDescription: NSEntityDescription
    {
        return NSEntityDescription.entity(forEntityName: "MMTCity", in: MMTDatabase.instance.context)!
    }
}
