//
//  MMTLocationService.swift
//  MobileMeteo
//
//  Created by szostakowskik on 11.12.2017.
//  Copyright © 2017 Kamil Szostakowski. All rights reserved.
//

import Foundation
import CoreLocation

protocol MMTLocationService
{
    var currentLocation: CLLocation? { get }
}

extension UIApplication
{
    var locationService: MMTLocationService? {
        return delegate as? MMTLocationService
    }
}
