//
//  MMTGeocoder.swift
//  MobileMeteo
//
//  Created by Kamil on 18.02.2017.
//  Copyright © 2017 Kamil Szostakowski. All rights reserved.
//

import Contacts
import CoreLocation

public class MMTRemoteCityGeocoder: MMTCityGeocoder
{
    // MARK: Properties
    private let geocoder: MMTGeocoder
    
    // MARK: Initializers    
    public init(general: MMTGeocoder)
    {
        geocoder = general
    }
    
    // MARK: Interface methods
    public func city(for location: CLLocation, completion: @escaping (MMTResult<MMTCityProt>) -> Void)
    {
        geocoder.geocode(location: location) {
            
            if case .failure(_) = $0 {
                completion(.failure(.locationNotFound))
                return
            }
            
            #if DEBUG
            if MMTMeteorogramUrlSession.simulatedError != nil {
                completion(.failure(.locationNotFound))
                return
            }
            #endif
            
            if case let .success(placemarks) = $0
            {
                guard let placemark = placemarks.first else {
                    completion(.failure(.locationNotFound))
                    return
                }
                
                guard let city = MMTCityProt(placemark: placemark) else {
                    completion(.failure(.locationUnsupported))
                    return
                }
                
                completion(.success(city))
            }
        }
    }
    
    public func cities(matching criteria: String, completion: @escaping ([MMTCityProt]) -> Void)
    {
        var cities = [MMTCityProt]()
        
        let
        address = CNMutablePostalAddress()
        address.city = criteria
        address.country = "Poland"
        address.isoCountryCode = "PL"
        
        geocoder.cancelGeocode()
        geocoder.geocode(address: address) {
            
            if case .failure(_) = $0 {
                completion([])
            }
            
            if case let .success(placemarks) = $0 {
                let foundCities: [MMTCityProt] = placemarks
                    .map(){ MMTCityProt(placemark: $0) }
                    .filter(){ $0 != nil }
                    .map{ $0! }
                
                if foundCities.count > 0 {
                    cities.append(contentsOf: foundCities)
                }
                
                completion(cities)
            }
        }
    }
}
