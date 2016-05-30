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
    private typealias MMTCitiesArray = [[String: AnyObject]]
    private typealias MMTCurrentCityQueryCompletion = (MMTCityProt?) -> Void
    
    private let database: MMTDatabase
    private let geocoder: CLGeocoder
    
    init(db: MMTDatabase)
    {
        geocoder = CLGeocoder()
        database = db
        
        super.init()
    }
    
    // MARK: Methods    
    
    func getAllCities(completion: MMTCitiesQueryCompletion)
    {
        completion(getAllCities())
    }
    
    func findCityForLocation(location: CLLocation, completion: MMTCityQueryCompletion)
    {
        if let city = getCityWithLocation(location) {
            completion(city, nil)
            return
        }
        
        geocoder.reverseGeocodeLocation(location) { (placemarks, geocodeError) in
            
            var translationError = geocodeError
            
            #if DEBUG
            translationError = MMTMeteorogramUrlSession.simulatedError ?? translationError
            #endif
            
            var city: MMTCityProt? = nil
            var error: MMTError? = nil
            
            defer { completion(city, error) }
            guard translationError == nil else { error = .LocationNotFound; return }
            guard let placemark = placemarks?.first else { error = .LocationNotFound; return }
            
            city = self.getCityForPlacemark(placemark)
            
            if city == nil {
                error = .LocationUnsupported
            }
        }
    }
    
    func findCitiesMatchingCriteria(criteria: String, completion: MMTCitiesQueryCompletion)
    {
        var cities = getCitiesMatchingCriteria(criteria)
        
        if cities.count>0 { completion(cities)
            return
        }
        
        let address: [NSObject:NSObject] =
        [
            kABPersonAddressCityKey: criteria,
            kABPersonAddressCountryKey: "Poland",
            kABPersonAddressCountryCodeKey: "PL",
        ]
        
        geocoder.cancelGeocode()
        geocoder.geocodeAddressDictionary(address){ (placemarks, error) in
            
            defer { completion(cities) }
            
            guard error == nil else { return }
            guard let markers = placemarks else { return }
            
            let foundCities = markers
                .map(){ self.getCityForPlacemark($0) }
                .filter(){ $0 != nil }
                .map{ $0! }

            if foundCities.count > 0 {
                cities.appendContentsOf(foundCities)
            }
        }
    }
    
    func markCity(city: MMTCityProt, asFavourite favourite: Bool)
    {
        guard let aCity = city as? MMTCity else {
            return
        }
        
        city.isFavourite = favourite

        if favourite && aCity.managedObjectContext == nil {
            database.context.insertObject(aCity)
        }
        
        if !favourite && !city.isCapital {
            database.context.deleteObject(aCity)
        }
        
        MMTDatabase.instance.saveContext()
    }
    
    func getPredefinedCitiesFromFile(file: String) -> [MMTCityProt]
    {
        guard let citiesList = getPredefinedCitiesFromJsonFile(file) else {
            return []
        }
     
        var result = [MMTCityProt]()
        for city in citiesList
        {
            let name = city["name"] as! String
            let lat = city["latitude"] as! Double
            let lng = city["longitude"] as! Double
            let region = city["region"] as! String
                
            let
            city = MMTCity(name: name, region: region, location: CLLocation(latitude: lat, longitude: lng))
            city.capital = true
                
            result.append(city)
        }

        return result
    }    
    
    // MARK: Helper methods
    
    private func getAllCities() -> [MMTCityProt]
    {
        let
        request = database.model.fetchRequestFromTemplateWithName(MMTFetch.AllCities, substitutionVariables: [String: AnyObject]())!
        request.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        
        guard let objects = try? database.context.executeFetchRequest(request) else { return [] }
        guard let cities = objects as? [MMTCity] else { return [] }

        return cities
    }
    
    private func getCitiesMatchingCriteria(criteria: String) -> [MMTCityProt]
    {
        let predicate = NSPredicate(format: "SELF.name CONTAINS[cd] %@", criteria)
        let cities = getAllCities().filter(){ predicate.evaluateWithObject($0) }
        
        return cities
    }
    
    private func getPredefinedCitiesFromJsonFile(path: String) -> MMTCitiesArray?
    {
        guard let data = NSData(contentsOfFile: path) else { return nil }
        guard let json = try? NSJSONSerialization.JSONObjectWithData(data, options: .MutableContainers) else {
            return nil
        }
        
        return json as? MMTCitiesArray
    }
    
    private func getCityForPlacemark(placemark: MMTPlacemark) -> MMTCityProt?
    {
        guard let city = MMTCity(placemark: placemark) else { return nil }
        
        let fetchRequest = database.model.fetchRequestFromTemplateWithName(MMTFetch.CityWithName, substitutionVariables: ["NAME": city.name])!
        let fetchedCity = (try? database.context.executeFetchRequest(fetchRequest))?.first as? MMTCity
        
        return fetchedCity ?? city
    }
    
    private func getCityWithLocation(location: CLLocation) -> MMTCityProt?
    {
        let parameters = ["LAT": location.coordinate.latitude, "LNG": location.coordinate.longitude]
        let fetchRequest = database.model.fetchRequestFromTemplateWithName(MMTFetch.CityWithLocation, substitutionVariables: parameters)!
        
        return (try? database.context.executeFetchRequest(fetchRequest))?.first as? MMTCity
    }
}