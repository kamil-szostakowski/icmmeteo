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
    public func geocode(location: CLLocation, completion: @escaping (MMTResult<[MMTPlacemark]>) -> Void)
    {
        reverseGeocodeLocation(location){
            self.onCompletion($0, $1, completion: completion)
        }
    }
    
    public func geocode(address: CNPostalAddress, completion: @escaping (MMTResult<[MMTPlacemark]>) -> Void)
    {
        if #available(iOS 11.0, *) {
            geocodePostalAddress(address) {
                self.onCompletion($0, $1, completion: completion)
            }
        } else {
            geocodeAddressString("\(address.city), \(address.country)") {
                self.onCompletion($0, $1, completion: completion)
            }
        }
    }
    
    // MARK: Helper methods
    fileprivate func onCompletion(_ placemarks: [MMTPlacemark]?, _ error: Error?, completion: @escaping (MMTResult<[MMTPlacemark]>) -> Void)
    {
        guard let markers = placemarks else {
            completion(.failure(.locationNotFound))
            return
        }
        
        completion(.success(markers))
    }
}
