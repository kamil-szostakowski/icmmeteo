//
//  MMTGeocoder.swift
//  MobileMeteo
//
//  Created by Kamil on 02.03.2017.
//  Copyright © 2017 Kamil Szostakowski. All rights reserved.
//

import Foundation
import CoreLocation

typealias MMTGeocodeCompletion = ([MMTPlacemark]?, Error?) -> Void

protocol MMTPlacemark
{
    var name: String? { get }
    var locality: String? { get }
    var ocean: String? { get }
    var location: CLLocation? { get }
    var administrativeArea: String? { get }
}

protocol MMTGeocoder
{
    func geocode(location: CLLocation, completion: @escaping MMTGeocodeCompletion)
    
    func geocode(addressDictionary: [AnyHashable : Any], completion: @escaping MMTGeocodeCompletion)
    
    func cancelGeocode()
}
