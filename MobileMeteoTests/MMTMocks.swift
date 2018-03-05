//
//  MMTStubs.swift
//  MobileMeteoTests
//
//  Created by szostakowskik on 15.02.2018.
//  Copyright © 2018 Kamil Szostakowski. All rights reserved.
//

import Foundation
import CoreLocation
import MeteoModel

@testable import MobileMeteo

class MMTStubLocationService : MMTLocationService {
    var currentLocation: CLLocation?
}

class MMTUnsupportedShortcut: MMTShortcut
{
    var identifier: String = ""
    
    func execute(using tabbar: MMTTabBarController, completion: MMTCompletion?) { }
}

class StubMigrator : MMTVersionMigrator
{
    private(set) var sequenceNumber: UInt
    private(set) var migrated = false
    
    init(sequenceNumber: UInt)
    {
        self.sequenceNumber = sequenceNumber
        self.migrated = false
    }
    
    func migrate()
    {
        migrated = true
    }
}
