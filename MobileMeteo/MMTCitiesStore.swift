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

class MMTCitiesStore: NSObject
{
    private typealias CitiesArray = [[String: AnyObject]]
    
    private let geocoder: CLGeocoder
    private let database: MMTDatabase
    private let locationManager: CLLocationManager
    
    init(db: MMTDatabase)
    {
        locationManager = CLLocationManager()
        geocoder = CLGeocoder()
        database = db
        
        super.init()
    }
    
    // MARK: Methods
    
    func getAllCities() -> [MMTCity]
    {
        let
        request = NSFetchRequest(entityName: "MMTCity")
        request.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        
        let cities = database.managedObjectContext.executeFetchRequest(request, error: nil)

        return cities as! [MMTCity]
    }
    
    func getPredefinedCitiesFromFile(file: String) -> [MMTCity]
    {
        var result = [MMTCity]()
        
        if let citiesList = getPredefinedCitiesFromFile(file)
        {
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
        }
        
        return result
    }
    
    func getCitiesMachingCriteria(criteria: String) -> [MMTCity]
    {
        let predicate = NSPredicate(format: "SELF.name CONTAINS[cd] %@", criteria)
        
        return getAllCities().filter(){ (city: MMTCity) in predicate.evaluateWithObject(city) }
    }
    
    func findCitiesMachingCriteris(criteria: String, completion: ([MMTCity]) -> Void)
    {
        locationManager.requestWhenInUseAuthorization()

        geocoder.geocodeAddressString("\(criteria), Poland", completionHandler:{
            (placemarks: [AnyObject]!, error: NSError!) in
            
            var cities = [MMTCity]()
            
            if error == nil
            {
                for placemark: CLPlacemark in placemarks as! [CLPlacemark] {
                    cities.append(MMTCity(placemark: placemark))
                }
            }
            
            completion(cities);
        })
    }
    
    func markCity(city: MMTCity, asFavourite favourite: Bool)
    {
        city.favourite = favourite
        
        if favourite && city.managedObjectContext == nil {
            database.managedObjectContext.insertObject(city)
        }
        
        if !favourite && !city.isCapital {
            database.managedObjectContext.deleteObject(city)
        }
        
        MMTDatabase.instance.saveContext()                
    }
    
    // MARK: Helper methods
    
    private func getPredefinedCitiesFromFile(path: String) -> CitiesArray?
    {
        if let data = NSData(contentsOfFile: path)
        {
            if let json: AnyObject = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableContainers, error: nil)
            {
                return json as? CitiesArray
            }
        }
        
        return nil
    }
}