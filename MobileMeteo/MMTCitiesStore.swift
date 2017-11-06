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

class MMTCitiesStore
{
    private typealias MMTCurrentCityQueryCompletion = (MMTCityProt?) -> Void
    
    private let database: MMTDatabase
    private let geocoder: MMTCityGeocoder
    
    init(db: MMTDatabase, geocoder gcoder: MMTCityGeocoder)
    {
        geocoder = gcoder
        database = db                
    }
    
    // MARK: Methods    
    
    func getAllCities(_ completion: MMTCitiesQueryCompletion)
    {
        completion(getAllCities())
    }
    
    func findCityForLocation(_ location: CLLocation, completion: @escaping MMTCityQueryCompletion)
    {
        geocoder.city(for: location) {
            (geocodedCity: MMTCityProt?, error: MMTError?) in
            
            var city = geocodedCity;
            defer { completion(city, error) }
            
            guard error == nil else { return }
            guard let localCity = self.getCity(with: city!.name) else { return; }
            
            city = localCity
        }
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
        
        if favourite == false && city.isCapital == false {
            database.context.delete(aCity)
        }
        
        database.saveContext()
    }        
    
    // MARK: Helper methods
    
    private func getAllCities() -> [MMTCityProt]
    {
        let fetchRequest = citiesFetchRequest(predicate: nil)
        return (try? database.context.fetch(fetchRequest)) ?? []
    }
    
    private func getCitiesMatchingCriteria(_ criteria: String) -> [MMTCityProt]
    {
        let fetchRequest = citiesFetchRequest(predicate: NSPredicate(format: "SELF.name CONTAINS[cd] %@", criteria))
        return (try? database.context.fetch(fetchRequest)) ?? []
    }
    
    private func getCity(with name: String) -> MMTCityProt?
    {
        let
        fetchRequest = citiesFetchRequest(predicate: NSPredicate(format: "SELF.name LIKE[cd] %@", name))
        fetchRequest.fetchLimit = 1
        
        return (try? database.context.fetch(fetchRequest))?.first
    }
    
    private func citiesFetchRequest(predicate: NSPredicate?) -> NSFetchRequest<MMTCity>
    {
        let
        fetchRequest = NSFetchRequest<MMTCity>(entityName: "MMTCity")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        fetchRequest.predicate = predicate
        
        return fetchRequest
    }
}
