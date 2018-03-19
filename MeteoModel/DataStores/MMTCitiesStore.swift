//
//  MMTCitiesStore.swift
//  MobileMeteo
//
//  Created by Kamil Szostakowski on 07.07.2015.
//  Copyright (c) 2015 Kamil Szostakowski. All rights reserved.
//

import Foundation
import CoreLocation
import CoreData

public typealias MMTCityQueryCompletion = (MMTCityProt?, MMTError?) -> Void
public typealias MMTCitiesQueryCompletion = ([MMTCityProt]) -> Void
public typealias MMTCurrentCityQueryCompletion = (MMTCityProt?) -> Void

open class MMTCitiesStore
{
    // MARK: Properties
    private let context: NSManagedObjectContext
    private let geocoder: MMTCityGeocoder
    
    // MARK: Initializers    
    public init(context: NSManagedObjectContext, geocoder gcoder: MMTCityGeocoder)
    {
        self.geocoder = gcoder
        self.context = context
    }
    
    // MARK: Methods
    open func getAllCities(_ completion: MMTCitiesQueryCompletion)
    {
        completion(context.fetch(request: .allCities()))
    }
    
    public func findCityForLocation(_ location: CLLocation, completion: @escaping MMTCityQueryCompletion)
    {
        geocoder.city(for: location) { (geocodedCity, error) in
            
            var city = geocodedCity;
            defer { completion(city, error) }
            
            guard error == nil else { return }
            guard let localCity = self.context.fetch(request: .city(named: city!.name)).first else { return; }
            
            city = localCity
        }
    }
    
    public func findCitiesMatchingCriteria(_ criteria: String, completion: @escaping MMTCitiesQueryCompletion)
    {
        let cities = context.fetch(request: .cities(maching: criteria))
        
        if cities.count > 0 { completion(cities)
            return
        }
        
        geocoder.cities(matching: criteria, completion: completion)
    }
    
    public func save(city: MMTCityProt)
    {
        if city.isFavourite || city.isCapital {
            context.save(entity: city)
        } else {
            context.delete(entity: city)
        }        
    }
}
