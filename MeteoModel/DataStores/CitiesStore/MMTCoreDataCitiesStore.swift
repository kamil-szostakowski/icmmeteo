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

public struct MMTCoreDataCitiesStore : MMTCitiesStore
{
    // MARK: Properties
    public private(set) var context: NSManagedObjectContext
    private let geocoder: MMTCityGeocoder
    
    // MARK: Initializers    
    init(_ context: NSManagedObjectContext, _ geocoder: MMTCityGeocoder)
    {
        self.geocoder = geocoder
        self.context = context
    }
    
    // MARK: Methods
    public func all(_ completion: ([MMTCityProt]) -> Void)
    {
        completion(context.fetch(request: .allCities()))
    }
    
    public func city(for location: CLLocation, completion: @escaping (MMTResult<MMTCityProt>) -> Void)
    {
        geocoder.city(for: location) {
            
            if case let .failure(error) = $0 {
                completion(.failure(error))
            }
            
            if case let .success(city) = $0 {
                guard let localCity = self.context.fetch(request: .city(named: city.name)).first else {
                    completion(.success(city))
                    return
                }
                completion(.success(localCity))
            }                        
        }
    }
    
    public func cities(matching criteria: String, completion: @escaping ([MMTCityProt]) -> Void)
    {
        let cities = context.fetch(request: .cities(maching: criteria))
        
        if cities.count > 0 { completion(cities)
            return
        }
        
        geocoder.cities(matching: criteria) {
            completion($0.sorted { $0.name < $1.name } )
        }
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
