//
//  MMTCoreLocationGeocoder.swift
//  MobileMeteo
//
//  Created by Kamil on 02.03.2017.
//  Copyright © 2017 Kamil Szostakowski. All rights reserved.
//

import Foundation
import CoreLocation

extension CLPlacemark: MMTPlacemark {}

extension CLGeocoder: MMTGeocoder
{
    func geocode(location: CLLocation, completion: @escaping MMTGeocodeCompletion)
    {
        reverseGeocodeLocation(location){
            completion($0, $1)
        }
    }
    
    func geocode(addressDictionary: [AnyHashable : Any], completion: @escaping MMTGeocodeCompletion)
    {
        geocodeAddressDictionary(addressDictionary) {
            completion($0, $1)
        }
    }
}
