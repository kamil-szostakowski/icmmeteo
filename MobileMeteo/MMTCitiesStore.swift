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
    fileprivate typealias MMTCitiesArray = [[String: AnyObject]]
    fileprivate typealias MMTCurrentCityQueryCompletion = (MMTCityProt?) -> Void
    
    fileprivate let database: MMTDatabase
    fileprivate let geocoder: CLGeocoder
    
    init(db: MMTDatabase)
    {
        geocoder = CLGeocoder()
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
        
        geocoder.reverseGeocodeLocation(location) { (placemarks, geocodeError) in
            
            var translationError = geocodeError
            
            #if DEBUG
            translationError = MMTMeteorogramUrlSession.simulatedError ?? translationError
            #endif
            
            var city: MMTCityProt? = nil
            var error: MMTError? = nil
            
            defer { completion(city, error) }
            guard translationError == nil else { error = .locationNotFound; return }
            guard let placemark = placemarks?.first else { error = .locationNotFound; return }
            
            city = self.getCityForPlacemark(placemark)
            
            if city == nil {
                error = .locationUnsupported
            }
        }
    }
    
    func findCitiesMatchingCriteria(_ criteria: String, completion: @escaping MMTCitiesQueryCompletion)
    {
        var cities = getCitiesMatchingCriteria(criteria)
        
        if cities.count>0 { completion(cities)
            return
        }
        
        let address: [NSObject:NSObject] =
        [
            kABPersonAddressCityKey: criteria as NSObject,
            kABPersonAddressCountryKey: "Poland" as NSObject,
            kABPersonAddressCountryCodeKey: "PL" as NSObject,
        ]
        
        geocoder.cancelGeocode()
        geocoder.geocodeAddressDictionary(address){ (placemarks, error) in
            
            defer { completion(cities) }
            guard let markers = placemarks, error == nil else { return }
            
            let foundCities = markers
                .map(){ self.getCityForPlacemark($0) }
                .filter(){ $0 != nil }
                .map{ $0! }

            if foundCities.count > 0 {
                cities.append(contentsOf: foundCities)
            }
        }
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
    
    func getPredefinedCitiesFromFile(_ file: String) -> [MMTCityProt]
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
    
    fileprivate func getAllCities() -> [MMTCityProt]
    {
        let
        request = database.model.fetchRequestFromTemplate(withName: MMTFetch.AllCities, substitutionVariables: [String: AnyObject]())!
        request.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        
        guard let objects = try? database.context.fetch(request) else { return [] }
        guard let cities = objects as? [MMTCity] else { return [] }

        return cities
    }
    
    fileprivate func getCitiesMatchingCriteria(_ criteria: String) -> [MMTCityProt]
    {
        let predicate = NSPredicate(format: "SELF.name CONTAINS[cd] %@", criteria)
        let cities = getAllCities().filter(){ predicate.evaluate(with: $0) }
        
        return cities
    }
    
    fileprivate func getPredefinedCitiesFromJsonFile(_ path: String) -> MMTCitiesArray?
    {
        guard let data = try? Data(contentsOf: URL(fileURLWithPath: path)) else { return nil }
        guard let json = try? JSONSerialization.jsonObject(with: data, options: .mutableContainers) else {
            return nil
        }
        
        return json as? MMTCitiesArray
    }
    
    fileprivate func getCityForPlacemark(_ placemark: MMTPlacemark) -> MMTCityProt?
    {
        guard let city = MMTCity(placemark: placemark) else { return nil }
        
        let fetchRequest = database.model.fetchRequestFromTemplate(withName: MMTFetch.CityWithName, substitutionVariables: ["NAME": city.name])!
        let fetchedCity = (try? database.context.fetch(fetchRequest))?.first as? MMTCity
        
        return fetchedCity ?? city
    }
    
    fileprivate func getCityWithLocation(_ location: CLLocation) -> MMTCityProt?
    {
        let parameters = ["LAT": location.coordinate.latitude, "LNG": location.coordinate.longitude]
        let fetchRequest = database.model.fetchRequestFromTemplate(withName: MMTFetch.CityWithLocation, substitutionVariables: parameters)!
        
        return (try? database.context.fetch(fetchRequest))?.first as? MMTCity
    }
}
