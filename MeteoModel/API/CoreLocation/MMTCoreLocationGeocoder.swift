//
//  MMTCoreLocationGeocoder.swift
//  MobileMeteo
//
//  Created by Kamil on 02.03.2017.
//  Copyright © 2017 Kamil Szostakowski. All rights reserved.
//

import Foundation
import CoreLocation
import Contacts

extension CLPlacemark : MMTPlacemark {}

extension CLGeocoder : MMTGeocoder
{
    public func geocode(location: CLLocation, completion: @escaping MMTGeocodeCompletion)
    {
        reverseGeocodeLocation(location){
            completion($0, $1)
        }
    }
    
    public func geocode(address: CNPostalAddress, completion: @escaping MMTGeocodeCompletion)
    {
        if #available(iOS 11.0, *) {
            geocodePostalAddress(address) {
                completion($0, $1)
            }
        } else {
            geocodeAddressString("\(address.city), \(address.country)") {
                completion($0, $1)
            }
        }
    }
}
