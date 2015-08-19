//
//  NSURL.swift
//  MobileMeteo
//
//  Created by Kamil Szostakowski on 19.08.2015.
//  Copyright (c) 2015 Kamil Szostakowski. All rights reserved.
//

import Foundation
import CoreLocation

public extension NSURL
{
    // MARK: Public methods
    
    public static func mmt_baseUrl() -> NSURL
    {
        return NSURL(string: "http://www.meteo.pl")!
    }
    
    public static func mmt_modelUmSearchUrl(location: CLLocation, tZero: NSDate) -> NSURL
    {
        let lat = location.coordinate.latitude
        let lng = location.coordinate.longitude
        let tZero = tZeroStringForDate(tZero)
        
        return NSURL(string: "/um/php/mgram_search.php?NALL=\(lat)&EALL=\(lng)&lang=pl&fdate=\(tZero)", relativeToURL: mmt_baseUrl())!
    }
    
    public static func mmt_modelUmDownloadBaseUrl() -> NSURL
    {
        return NSURL(string: "/um/metco/mgram_pict.php", relativeToURL: mmt_baseUrl())!
    }
    
    public static func mmt_modelCoampsSearchUrl(location: CLLocation, tZero: NSDate) -> NSURL
    {
        let lat = location.coordinate.latitude
        let lng = location.coordinate.longitude
        let tZero = tZeroStringForDate(tZero)
        
        return NSURL(string: "/php/mgram_search.php?NALL=\(lat)&EALL=\(lng)&lang=pl&fdate=\(tZero)", relativeToURL: mmt_baseUrl())!
    }
    
    public static func mmt_modelCoampsDownloadBaseUrl() -> NSURL
    {
        return NSURL(string: "/metco/mgram_pict.php", relativeToURL: mmt_baseUrl())!
    }
    
    // MARK: Helper methods
    
    private static func tZeroStringForDate(date: NSDate) -> String
    {
        let units: NSCalendarUnit = (.CalendarUnitYear)|(.CalendarUnitMonth)|(.CalendarUnitDay)|(.CalendarUnitHour)        
        let components = NSCalendar.utcCalendar.components(units, fromDate: date)
        
        return String(format: "%04ld%02ld%02ld%02ld", components.year, components.month, components.day, components.hour)
    }
}