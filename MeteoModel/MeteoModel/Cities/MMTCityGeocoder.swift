//
//  MMTGeocoder.swift
//  MobileMeteo
//
//  Created by Kamil on 18.02.2017.
//  Copyright © 2017 Kamil Szostakowski. All rights reserved.
//

import AddressBook
import CoreLocation

class MMTCityGeocoder
{
    // MARK: Properties
    private let geocoder: MMTGeocoder
    private let entityFactory: MMTEntityFactory
    
    // MARK: Initializers
    convenience init()
    {
        self.init(general: CLGeocoder(), factory: MMTDatabase.instance)
    }
    
    init(general: MMTGeocoder, factory: MMTEntityFactory)
    {
        geocoder = general
        entityFactory = factory
    }
    
    // MARK: Interface methods
    func city(for location: CLLocation, completion: @escaping MMTCityQueryCompletion)
    {
        geocoder.geocode(location: location) { (placemarks, geocodeError) in
            
            var translationError = geocodeError
            
            #if DEBUG
            translationError = MMTMeteorogramUrlSession.simulatedError ?? translationError
            #endif
            
            var city: MMTCityProt? = nil
            var error: MMTError? = nil
            
            defer { completion(city, error) }
            guard translationError == nil else { error = .locationNotFound; return }
            guard let placemark = placemarks?.first else { error = .locationNotFound; return }
            
            city = self.entityFactory.city(placemark: placemark)
            
            if city == nil {
                error = .locationUnsupported
            }
        }
    }
    
    func cities(matching criteria: String, completion: @escaping MMTCitiesQueryCompletion)
    {
        var cities = [MMTCityProt]()
        
        let address: [NSObject:NSObject] =
        [
            kABPersonAddressCityKey: criteria as NSObject,
            kABPersonAddressCountryKey: "Poland" as NSObject,
            kABPersonAddressCountryCodeKey: "PL" as NSObject,
        ]
        
        geocoder.cancelGeocode()
        geocoder.geocode(addressDictionary: address){ (placemarks, error) in
            
            defer { completion(cities) }
            guard error == nil else { return }
            guard let markers = placemarks else { return }
            
            let foundCities: [MMTCityProt] = markers
                .map(){ self.entityFactory.city(placemark: $0) }
                .filter(){ $0 != nil }
                .map{ $0! }
            
            if foundCities.count > 0 {
                cities.append(contentsOf: foundCities)
            }
        }
    }
}
