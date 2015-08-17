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
    
    init(db: MMTDatabase)
    {
        geocoder = CLGeocoder()
        database = db
        
        super.init()
    }
    
    // MARK: Methods
    
    func getAllCities() -> [MMTCity]
    {
        let request = database.managedObjectModel.fetchRequestTemplateForName("FetchPopular")!
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
                
                result.append(MMTCity(name: name, location: CLLocation(latitude: lat, longitude: lng)))
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