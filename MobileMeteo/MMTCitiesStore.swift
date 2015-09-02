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

typealias MMTCititesQueryCompletion = ([MMTCity]) -> Void

class MMTCitiesStore: NSObject, CLLocationManagerDelegate
{
    private typealias MMTCitiesArray = [[String: AnyObject]]
    private typealias MMTCurrentCityQueryCompletion = (MMTCity?) -> Void
    
    private let geocoder: CLGeocoder
    private let database: MMTDatabase
    private let locationManager: CLLocationManager
    
    dynamic var currentLocation: CLLocation?
    
    init(db: MMTDatabase)
    {
        locationManager = CLLocationManager()
        geocoder = CLGeocoder()
        database = db
        
        super.init()        
        
        locationManager.requestWhenInUseAuthorization()
        locationManager.delegate = self
    }
    
    // MARK: Methods    
    
    func getAllCities(completion: MMTCititesQueryCompletion)
    {
        var cities = getAllCities()
        
        if CLLocationManager.authorizationStatus() != .AuthorizedWhenInUse {
            completion(cities)
            return
        }
        
        getCityForCurrentLocation() {
            
            if let currentCity = $0 {
                completion(cities+[currentCity])
            }
        }
    }
    
    func getCitiesMatchingCriteria(criteria: String, completion: MMTCititesQueryCompletion)
    {
        let predicate = NSPredicate(format: "SELF.name CONTAINS[cd] %@", criteria)
        var cities = getAllCities().filter(){ predicate.evaluateWithObject($0) }
        
        if cities.count > 0 {
            completion(cities)
            return
        }
        
        geocoder.geocodeAddressString("\(criteria), Poland", completionHandler:{
            (placemarks: [AnyObject]!, error: NSError!) in
            
            if error == nil {
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
    
    // MARK: CLLocationManagerDelegate
    
    func locationManager(manager: CLLocationManager!, didChangeAuthorizationStatus status: CLAuthorizationStatus)
    {
        let authorized = status == .AuthorizedWhenInUse
        
        if status == .AuthorizedWhenInUse {
            locationManager.startMonitoringSignificantLocationChanges()
        }
        
        currentLocation = !authorized ? nil : locationManager.location
    }
    
    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!)
    {
        currentLocation = locationManager.location        
    }
    
    // MARK: Helper methods
    
    private func getAllCities() -> [MMTCity]
    {
        let
        request = NSFetchRequest(entityName: "MMTCity")
        request.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        
        let cities = database.managedObjectContext.executeFetchRequest(request, error: nil)
        
        return cities as! [MMTCity]
    }
    
    private func getCityForCurrentLocation(completion: MMTCurrentCityQueryCompletion)
    {
        geocoder.reverseGeocodeLocation(locationManager.location) {
            (placemarks, error) in
            
            if error == nil && placemarks.count>0
            {
                let markers = placemarks as! [CLPlacemark]
                completion(MMTCity(placemark: markers.first!))
            }
            else
            {
                completion(nil)
            }
        }
    }
    
    private func getPredefinedCitiesFromFile(path: String) -> MMTCitiesArray?
    {
        if let data = NSData(contentsOfFile: path)
        {
            if let json: AnyObject = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableContainers, error: nil)
            {
                return json as? MMTCitiesArray
            }
        }
        
        return nil
    }
}