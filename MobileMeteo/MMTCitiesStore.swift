//
//  MMTCitiesStore.swift
//  MobileMeteo
//
//  Created by Kamil Szostakowski on 07.07.2015.
//  Copyright (c) 2015 Kamil Szostakowski. All rights reserved.
//

import Foundation
import CoreLocation
import AddressBook
import CoreData

typealias MMTCityQueryCompletion = (MMTCityProt?, MMTError?) -> Void
typealias MMTCitiesQueryCompletion = ([MMTCityProt]) -> Void

class MMTCitiesStore: NSObject
{
    private typealias MMTCurrentCityQueryCompletion = (MMTCityProt?) -> Void
    
    private let database: MMTDatabase
    private let geocoder: MMTCityGeocoder
    
    init(db: MMTDatabase, geocoder gcoder: MMTCityGeocoder)
    {
        geocoder = gcoder
        database = db
        
        super.init()
    }
    
    // MARK: Methods    
    
    func getAllCities(_ completion: MMTCitiesQueryCompletion)
    {
        completion(getAllCities())
    }
    
    func findCityForLocation(_ location: CLLocation, completion: @escaping MMTCityQueryCompletion)
    {
        if let city = getCityWithLocation(location) {
            completion(city, nil)
            return
        }
        
        geocoder.city(for: location, completion: completion)
    }
    
    func findCitiesMatchingCriteria(_ criteria: String, completion: @escaping MMTCitiesQueryCompletion)
    {
        let cities = getCitiesMatchingCriteria(criteria)
        
        if cities.count > 0 { completion(cities)
            return
        }
        
        geocoder.cities(matching: criteria, completion: completion)
    }
    
    func markCity(_ city: MMTCityProt, asFavourite favourite: Bool)
    {
        guard let aCity = city as? MMTCity else {
            return
        }
        
        city.isFavourite = favourite

        if favourite && aCity.managedObjectContext == nil {
            database.context.insert(aCity)
        }
        
        if !favourite && !city.isCapital {
            database.context.delete(aCity)
        }
        
        MMTDatabase.instance.saveContext()
    }        
    
    // MARK: Helper methods
    
    private func getAllCities() -> [MMTCityProt]
    {
        let
        request = database.model.fetchRequestFromTemplate(withName: MMTFetch.AllCities, substitutionVariables: [String: AnyObject]())!
        request.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        
        guard let objects = try? database.context.fetch(request) else { return [] }
        guard let cities = objects as? [MMTCity] else { return [] }

        return cities
    }
    
    private func getCitiesMatchingCriteria(_ criteria: String) -> [MMTCityProt]
    {
        let predicate = NSPredicate(format: "SELF.name CONTAINS[cd] %@", criteria)
        let cities = getAllCities().filter(){ predicate.evaluate(with: $0) }
        
        return cities
    }    

    private func getCityWithLocation(_ location: CLLocation) -> MMTCityProt?
    {
        let parameters = ["LAT": location.coordinate.latitude, "LNG": location.coordinate.longitude]
        let fetchRequest = database.model.fetchRequestFromTemplate(withName: MMTFetch.CityWithLocation, substitutionVariables: parameters)!
        
        return (try? database.context.fetch(fetchRequest))?.first as? MMTCity
    }
}
