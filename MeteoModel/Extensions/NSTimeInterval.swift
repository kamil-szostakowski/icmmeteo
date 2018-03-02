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
    public init(minutes: Int)
    {
        self = TimeInterval(60*minutes)
    }
    
    public init(hours: Int)
    {
        self = TimeInterval(3600*hours)
    }
}
