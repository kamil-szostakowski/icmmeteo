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

typealias MMTCityQueryCompletion = (MMTCity?, MMTError?) -> Void
typealias MMTCitiesQueryCompletion = ([MMTCity]) -> Void

class MMTCitiesStore: NSObject
{
    private typealias MMTCitiesArray = [[String: AnyObject]]
    private typealias MMTCurrentCityQueryCompletion = (MMTCity?) -> Void
    
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
        geocoder.reverseGeocodeLocation(location) { (placemarks, translationError) in
            
            var city: MMTCity? = nil
            var error: MMTError? = nil
            
            if translationError != nil {
                error = .LocationNotFound
            }
            
            else if placemarks != nil && placemarks!.count>0
            {
                city = self.getCityForPlacemark(placemarks!.first!)
                
                if city == nil {
                    error = .LocationUnsupported
                }
            }
            
            completion(city, error)
        }
    }
    
    func getCitiesMatchingCriteria(criteria: String, completion: MMTCitiesQueryCompletion)
    {
        let predicate = NSPredicate(format: "SELF.name CONTAINS[cd] %@", criteria)
        let cities = getAllCities().filter(){ predicate.evaluateWithObject($0) }
        
        completion(cities)
    }
    
    func findCitiesMatchingCriteria(criteria: String, completion: MMTCitiesQueryCompletion)
    {
        var cities = [MMTCity]()
        
        let address: [NSObject:NSObject] =
        [
            kABPersonAddressCityKey: criteria,
            kABPersonAddressCountryKey: "Poland",
            kABPersonAddressCountryCodeKey: "PL",
        ]
        
        geocoder.cancelGeocode()
        geocoder.geocodeAddressDictionary(address){ (placemarks: [CLPlacemark]?, error: NSError?) in
            
            defer { completion(cities) }
            
            guard error == nil else { return }
            guard let markers = placemarks else { return }
            
            for placemark: CLPlacemark in markers {
                if let city = self.getCityForPlacemark(placemark) {
                    cities.append(city)
                }
            }
        }
    }
    
    func markCity(city: MMTCity, asFavourite favourite: Bool)
    {
        city.favourite = favourite

        if favourite && city.managedObjectContext == nil {
            database.context.insertObject(city)
        }
        
        if !favourite && !city.isCapital {
            database.context.deleteObject(city)
        }
        
        MMTDatabase.instance.saveContext()
    }
    
    func getPredefinedCitiesFromFile(file: String) -> [MMTCity]
    {
        guard let citiesList = getPredefinedCitiesFromJsonFile(file) else {
            return []
        }
     
        var result = [MMTCity]()
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
    
    private func getAllCities() -> [MMTCity]
    {
        let
        request = database.model.fetchRequestFromTemplateWithName(MMTFetch.AllCities, substitutionVariables: [String: AnyObject]())!
        request.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        
        let cities = try? database.context.executeFetchRequest(request)
        
        return cities as! [MMTCity]
    }
    
    private func getPredefinedCitiesFromJsonFile(path: String) -> MMTCitiesArray?
    {
        guard let data = NSData(contentsOfFile: path) else { return nil }
        guard let json = try? NSJSONSerialization.JSONObjectWithData(data, options: .MutableContainers) else {
            return nil
        }
        
        return json as? MMTCitiesArray
    }
    
    private func getCityForPlacemark(placemark: CLPlacemark) -> MMTCity?
    {
        if placemark.ocean != nil {
            return nil
        }
        
        let name = placemark.locality ?? placemark.name!
        let fetchRequest = database.model.fetchRequestFromTemplateWithName(MMTFetch.CityWithName, substitutionVariables: ["NAME": name])!        
        let city = (try? database.context.executeFetchRequest(fetchRequest))?.first as? MMTCity
        
        return city != nil ? city! : MMTCity(placemark: placemark)
    }
}