//
//  MMTLocationService.swift
//  MeteoModel
//
//  Created by szostakowskik on 08.06.2018.
//  Copyright © 2018 Kamil Szostakowski. All rights reserved.
//

import Foundation
import CoreLocation

public extension Notification.Name
{
    public static let locationChangedNotification = Notification.Name(rawValue: "MMTLocationChangedNotification")
}

public protocol MMTLocationService
{
    var currentLocation: CLLocation? { get }    
}
