//
//  MMTMeteorogramQuery.swift
//  MobileMeteo
//
//  Created by Kamil Szostakowski on 01.07.2015.
//  Copyright (c) 2015 Kamil Szostakowski. All rights reserved.
//

import Foundation
import CoreLocation

public class MMTMeteorogramQuery: NSObject
{
    // MARK: properties
    
    private let storedLocation: CLLocation
    private let storedDate: NSDate
    
    public var location: CLLocation { return storedLocation }
    public var date: String { return generateDateString(storedDate) }
    
    // MARK: initializers
    
    public init(location: CLLocation, date: NSDate)
    {
        storedLocation = location
        storedDate = date
        
        super.init()
    }
    
    public convenience init(location: CLLocation)
    {
        self.init(location: location, date: NSDate())
    }
    
    // MARK: Helper methods
    
    private func generateDateString(date: NSDate) -> String
    {
        let units: NSCalendarUnit = (.CalendarUnitYear)|(.CalendarUnitMonth)|(.CalendarUnitDay)|(.CalendarUnitHour)
        let calendar = NSCalendar.currentCalendar().copy() as! NSCalendar
        calendar.timeZone = NSTimeZone(name: "GMT")!
        
        let components = calendar.components(units, fromDate: date)
        let tZero = components.hour < 12 ? 0 : 12;
        
        return String(format: "%04ld%02ld%02ld%02ld", components.year, components.month, components.day, tZero)
    }
}