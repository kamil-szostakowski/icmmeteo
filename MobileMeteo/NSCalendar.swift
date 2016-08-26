//
//  NSCalendar.swift
//  MobileMeteo
//
//  Created by Kamil Szostakowski on 19.08.2015.
//  Copyright (c) 2015 Kamil Szostakowski. All rights reserved.
//

import Foundation

extension Calendar
{
    static var utcCalendar: Calendar
    {
        var
        calendar = (Calendar.current as NSCalendar).copy() as! Calendar
        calendar.timeZone = TimeZone(identifier: "UTC")!
        
        return calendar
    }
}
