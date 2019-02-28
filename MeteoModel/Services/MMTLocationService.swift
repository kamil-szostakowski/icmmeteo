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
    public static let locationAuthChangedNotification = Notification.Name(rawValue: "MMTLocationAuthChangedNotification")
}

public enum MMTLocationAuthStatus: CustomStringConvertible
{
    case always
    case whenInUse
    case unauthorized
    case undetermined
    
    public var description: String {
        switch self {
            case .always: return "always"
            case .whenInUse: return "whenInUse"
            case .unauthorized: return "unauthorized"
            case .undetermined: return "undetermined"
        }
    }
}

extension MMTLocationAuthStatus
{
    init(_ status: CLAuthorizationStatus)
    {
        switch status {
            case .authorizedWhenInUse: self = .whenInUse
            case .authorizedAlways: self = .always
            case .notDetermined: self = .undetermined
            default: self = .unauthorized
        }
    }
}

public protocol MMTLocationService
{
    var location: MMTCityProt? { get }
    
    var authorizationStatus: MMTLocationAuthStatus { get }
    
    func requestLocation() -> MMTPromise<MMTCityProt>
}
