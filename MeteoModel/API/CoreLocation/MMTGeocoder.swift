//
//  MMTGeocoder.swift
//  MobileMeteo
//
//  Created by Kamil on 02.03.2017.
//  Copyright © 2017 Kamil Szostakowski. All rights reserved.
//

import Foundation
import CoreLocation
import Contacts

public typealias MMTGeocodeCompletion = ([MMTPlacemark]?, Error?) -> Void

public protocol MMTPlacemark
{
    var name: String? { get }
    var locality: String? { get }
    var ocean: String? { get }
    var location: CLLocation? { get }
    var administrativeArea: String? { get }
}

public protocol MMTGeocoder
{
    func geocode(location: CLLocation, completion: @escaping MMTGeocodeCompletion)
    
    func geocode(address: CNPostalAddress, completion: @escaping MMTGeocodeCompletion)
    
    func cancelGeocode()
}
