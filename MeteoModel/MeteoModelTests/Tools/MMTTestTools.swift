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
    static func getDate(_ year: Int, _ month: Int, _ day: Int, _ hour: Int) -> Date
    {
        var
        components = DateComponents()
        components.timeZone = TimeZone(identifier: "UTC")
        components.year = year
        components.month = month
        components.day = day
        components.hour = hour
        
        return Calendar.current.date(from: components)!
    }
    
    static var localFormatter: DateFormatter
    {
        let
        localFormatter = DateFormatter()
        localFormatter.dateFormat = "YYYY-MM-dd'T'HH:mm"
        localFormatter.timeZone = TimeZone(secondsFromGMT:7200)
        
        return localFormatter
    }
    
    static var utcFormatter: DateFormatter
    {
        let
        utcFormatter = DateFormatter()
        utcFormatter.dateFormat = "YYYY-MM-dd'T'HH:mm"
        utcFormatter.timeZone = TimeZone(identifier: "UTC")
            
        return utcFormatter
    }
}
