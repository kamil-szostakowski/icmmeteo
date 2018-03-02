//
//  NSTimeInterval.swift
//  MobileMeteo
//
//  Created by Kamil Szostakowski on 04.02.2016.
//  Copyright © 2016 Kamil Szostakowski. All rights reserved.
//

import Foundation

extension TimeInterval
{
    init(minutes: Int)
    {
        self = TimeInterval(60*minutes)
    }
    
    init(hours: Int)
    {
        self = TimeInterval(3600*hours)
    }
}
