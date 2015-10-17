//
//  MMTTestTools.swift
//  MobileMeteo
//
//  Created by Kamil Szostakowski on 31.07.2015.
//  Copyright (c) 2015 Kamil Szostakowski. All rights reserved.
//

import Foundation

typealias TT = MMTTestTools

class MMTTestTools
{
    static func getDate(year: Int, _ month: Int, _ day: Int, _ hour: Int) -> NSDate
    {
        let components = NSDateComponents()
        components.timeZone = NSTimeZone(name: "UTC")
        components.year = year
        components.month = month
        components.day = day
        components.hour = hour
        
        return NSCalendar.currentCalendar().dateFromComponents(components)!
    }
    
    static var localFormatter: NSDateFormatter
    {
        let
        localFormatter = NSDateFormatter()
        localFormatter.dateFormat = "YYYY-MM-dd'T'HH:mm"
        localFormatter.timeZone = NSTimeZone(forSecondsFromGMT:7200)
        
        return localFormatter
    }
    
    static var utcFormatter: NSDateFormatter
    {
        let
        utcFormatter = NSDateFormatter()
        utcFormatter.dateFormat = "YYYY-MM-dd'T'HH:mm"
        utcFormatter.timeZone = NSTimeZone(name: "UTC")
            
        return utcFormatter
    }
}