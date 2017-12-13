//
//  MMTServiceProvider.swift
//  MobileMeteo
//
//  Created by szostakowskik on 11.12.2017.
//  Copyright © 2017 Kamil Szostakowski. All rights reserved.
//

import Foundation
import CoreLocation

protocol MMTService
{
    func start()
    
    func stop()
    
    func update()
}

class MMTServiceProvider : NSObject
{
    static let locationService = {
        return MMTLocationService(manager: CLLocationManager())
    }()
}
