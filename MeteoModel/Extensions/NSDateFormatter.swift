//
//  NSDateFormatter.swift
//  MobileMeteo
//
//  Created by Kamil Szostakowski on 31.07.2015.
//  Copyright (c) 2015 Kamil Szostakowski. All rights reserved.
//

import Foundation

extension DateFormatter
{
    static var shortDateOnlyStyle: DateFormatter
    {
        let
        formatter = DateFormatter()
        formatter.timeZone = TimeZone(identifier: "UTC")
        formatter.dateFormat = "YYYY.MM.dd"

        return formatter
    }    
    
    public static var utcFormatter: DateFormatter
    {
        let
        formatter = DateFormatter()
        formatter.timeZone = TimeZone(identifier: "UTC")
        formatter.dateFormat = "YYYY.MM.dd HH:mm 'UTC'"
        
        return formatter
    }
}
