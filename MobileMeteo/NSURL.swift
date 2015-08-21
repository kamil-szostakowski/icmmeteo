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
    
    // MARK: Model UM related methods
    
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
    
    // MARK: Model COAMPS related methods
    
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
    
    // MARK: Model WAM related methods
    
    public static func mmt_modelWamTideHeightThumbnailUrl(tZero: NSDate, plus: Int) -> NSURL
    {
        return mmt_modelWamThumbnailUrl("wavehgt", tZero: tZero, plus: plus)
    }
    
    public static func mmt_modelWamAvgTidePeriodThumbnailUrl(tZero: NSDate, plus: Int) -> NSURL
    {
        return mmt_modelWamThumbnailUrl("m_period", tZero: tZero, plus: plus)
    }
    
    public static func mmt_modelWamSpectrumPeakPeriodThumbnailUrl(tZero: NSDate, plus: Int) -> NSURL
    {
        return mmt_modelWamThumbnailUrl("p_period", tZero: tZero, plus: plus)
    }
    
    public static func mmt_modelWamTideHeightDownloadUrl(tZero: NSDate, plus: Int) -> NSURL
    {
        return mmt_modelWamDownloadUrl("wavehgt", tZero: tZero, plus: plus)
    }
    
    public static func mmt_modelWamAvgTidePeriodDownloadUrl(tZero: NSDate, plus: Int) -> NSURL
    {
        return mmt_modelWamDownloadUrl("m_period", tZero: tZero, plus: plus)
    }
    
    public static func mmt_modelWamSpectrumPeakPeriodDownloadUrl(tZero: NSDate, plus: Int) -> NSURL
    {
        return mmt_modelWamDownloadUrl("p_period", tZero: tZero, plus: plus)
    }
    
    // MARK: Helper methods
    
    private static func mmt_modelWamDownloadUrl(infix: String, tZero: NSDate, plus: Int) -> NSURL
    {
        let tZeroString = tZeroStringForDate(tZero)
        let tZeroPlus = NSString(format: "%03ld", plus)
        
        return NSURL(string: "/wamcoamps/pict/\(tZeroString)/\(infix)_0W_\(tZeroString)_\(tZeroPlus)-00.png", relativeToURL: mmt_baseUrl())!
    }
    
    private static func mmt_modelWamThumbnailUrl(infix: String, tZero: NSDate, plus: Int) -> NSURL
    {
        let tZeroString = tZeroStringForDate(tZero)
        let tZeroPlus = NSString(format: "%03ld", plus)
        
        return NSURL(string: "/wamcoamps/pict/\(tZeroString)/small-crop-\(infix)_0W_\(tZeroString)_\(tZeroPlus)-00.gif", relativeToURL: mmt_baseUrl())!
    }
    
    private static func tZeroStringForDate(date: NSDate) -> String
    {
        let units: NSCalendarUnit = (.CalendarUnitYear)|(.CalendarUnitMonth)|(.CalendarUnitDay)|(.CalendarUnitHour)        
        let components = NSCalendar.utcCalendar.components(units, fromDate: date)
        
        return String(format: MMTFormat.TZero, components.year, components.month, components.day, components.hour)
    }
}