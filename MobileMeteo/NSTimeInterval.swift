//
//  NSTimeInterval.swift
//  MobileMeteo
//
//  Created by Kamil Szostakowski on 04.02.2016.
//  Copyright © 2016 Kamil Szostakowski. All rights reserved.
//

import Foundation

extension NSTimeInterval
{
    init(minutes: Int)
    {
        self = NSTimeInterval(60*minutes)
    }
    
    init(hours: Int)
    {
        self = NSTimeInterval(3600*hours)
    }
}