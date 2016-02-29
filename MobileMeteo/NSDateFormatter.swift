//
//  NSDateFormatter.swift
//  MobileMeteo
//
//  Created by Kamil Szostakowski on 31.07.2015.
//  Copyright (c) 2015 Kamil Szostakowski. All rights reserved.
//

import Foundation

extension NSDateFormatter
{
    static var shortDateOnlyStyle: NSDateFormatter
    {
        let
        formatter = NSDateFormatter()
        formatter.timeZone = NSTimeZone(name: "UTC")
        formatter.dateFormat = "YYYY.MM.dd"

        return formatter
    }    
    
    static var utcFormatter: NSDateFormatter
    {
        let
        formatter = NSDateFormatter()
        formatter.timeZone = NSTimeZone(name: "UTC")
        formatter.dateFormat = "YYYY.MM.dd HH:mm 'UTC'"
        
        return formatter
    }
}