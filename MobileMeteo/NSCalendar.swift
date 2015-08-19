//
//  NSCalendar.swift
//  MobileMeteo
//
//  Created by Kamil Szostakowski on 19.08.2015.
//  Copyright (c) 2015 Kamil Szostakowski. All rights reserved.
//

import Foundation

extension NSCalendar
{
    static var utcCalendar: NSCalendar
    {
        let
        calendar = NSCalendar.currentCalendar().copy() as! NSCalendar
        calendar.timeZone = NSTimeZone(name: "UTC")!
        
        return calendar
    }
}