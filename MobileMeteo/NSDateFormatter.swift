//
//  NSDateFormatter.swift
//  MobileMeteo
//
//  Created by Kamil Szostakowski on 31.07.2015.
//  Copyright (c) 2015 Kamil Szostakowski. All rights reserved.
//

import Foundation

public extension NSDateFormatter
{
    public static var shortStyle: NSDateFormatter
    {
        var
        formatter = NSDateFormatter()
        formatter.timeZone = NSTimeZone(name: "UTC")
        formatter.dateStyle = .ShortStyle
        formatter.timeStyle = .NoStyle

        return formatter
    }
    
    public static var shortTimeStyle: NSDateFormatter
    {
        var
        formatter = NSDateFormatter()
        formatter.timeZone = NSTimeZone(name: "UTC")
        formatter.dateStyle = .NoStyle
        formatter.timeStyle = .ShortStyle
        
        return formatter
    }
    
    public static func shortStyleUtcDatetime(date: NSDate) -> String
    {
        let datePart = shortStyle.stringFromDate(date)
        let timePart = shortTimeStyle.stringFromDate(date)
        
        return "\(datePart) \(timePart) UTC"
    }
}