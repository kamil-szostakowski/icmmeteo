//
//  MMTStubs.swift
//  MobileMeteoTests
//
//  Created by szostakowskik on 15.02.2018.
//  Copyright © 2018 Kamil Szostakowski. All rights reserved.
//

import Foundation
import CoreLocation
@testable import MobileMeteo

struct MMTStubLocationService : MMTLocationService
{
    var currentLocation: CLLocation? {
        return nil
    }
}

class MMTUnsupportedShortcut: MMTShortcut
{
    var identifier: String = ""
    
    func execute(using tabbar: MMTTabBarController, completion: MMTCompletion?) { }
}
