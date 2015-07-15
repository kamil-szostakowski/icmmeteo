//
//  MMTCitiesStore.swift
//  MobileMeteo
//
//  Created by Kamil Szostakowski on 07.07.2015.
//  Copyright (c) 2015 Kamil Szostakowski. All rights reserved.
//

import Foundation
import CoreLocation

class MMTCity: NSObject
{
    var name: String
    var region: String
    var location: CLLocation?
    
    init(name: String, region: String, location: CLLocation?)
    {
        self.name = name
        self.region = region
        self.location = location
    }
    
    convenience init(name: String)
    {
        self.init(name: name, region: "", location: nil)
    }
    
    convenience init(placemark: CLPlacemark)
    {
        self.init(name: placemark.name, region: placemark.administrativeArea, location: placemark.location)
    }
}

class MMTCitiesStore: NSObject
{
    private let geocoder: CLGeocoder
    
    override init()
    {
        geocoder = CLGeocoder()
        super.init()
    }
    
    // MARK: Methods
    
    func getAllCities() -> [MMTCity]
    {
        let names = [
            "Białystok", "Bydgoszcz", "Gdańsk", "Gorzów Wielkopolski", "Katowice", "Kielce",
            "Kraków", "Lublin", "Łódź", "Olsztyn", "Opole", "Poznań", "Rzeszów", "Szczecin",
            "Toruń", "Warszawa", "Wrocław", "Zielona Góra"
        ]
     
        var cities = [MMTCity]()
        
        for name in names {
            cities.append(MMTCity(name: name))
        }
        
        return cities
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
            
            for placemark: CLPlacemark in placemarks as! [CLPlacemark] {
                cities.append(MMTCity(placemark: placemark))
            }
            
            completion(cities);
        })
    }
}