//
//  MMTCityCategory.swift
//  MobileMeteo
//
//  Created by Kamil Szostakowski on 27.08.2015.
//  Copyright (c) 2015 Kamil Szostakowski. All rights reserved.
//

import Foundation
import CoreLocation
import CoreData

extension MMTCity
{
    func update(with city: MMTCityProt)
    {
        name = city.name
        region = city.region
        lat = NSNumber(floatLiteral: city.location.coordinate.latitude)
        lng = NSNumber(floatLiteral: city.location.coordinate.longitude)
        capital = NSNumber(booleanLiteral: city.isCapital)
        favourite = NSNumber(booleanLiteral: city.isFavourite)        
    }
    
    var value: MMTCityProt
    {
        let location = CLLocation(latitude: lat.doubleValue, longitude: lng.doubleValue)
        
        var
        city = MMTCityProt(name: name, region: region, location: location)
        city.isFavourite = favourite.boolValue
        city.isCapital = capital.boolValue
        
        return city
    }
}

extension NSManagedObjectContext
{
    func save(entity: MMTCityProt)
    {
        var city = (try? fetch(.city(named: entity.name)))?.first
        
        if city == nil {
            let description = NSEntityDescription.entity(forEntityName: "MMTCity", in: self)
            city = MMTCity(entity: description!, insertInto: self)
        }
        
        city?.update(with: entity)
    }
    
    func delete(entity: MMTCityProt)
    {
        guard let city = (try? fetch(.city(named: entity.name)))?.first else {
            return
        }
        
        delete(city)
    }
    
    func fetch(request: NSFetchRequest<MMTCity>) -> [MMTCityProt]
    {
        return (try? fetch(request).map { $0.value }) ?? []
    }
}

extension NSFetchRequest where ResultType == MMTCity
{
    static func allCities() -> NSFetchRequest<ResultType>
    {
        return cities(maching: nil)
    }
    
    static func city(named: String) -> NSFetchRequest<ResultType>
    {
        return cities(maching: NSPredicate(format: "SELF.name LIKE[cd] %@", named), limit: 1)
    }
    
    static func cities(maching criteria: String) -> NSFetchRequest<ResultType>
    {
        return cities(maching: NSPredicate(format: "SELF.name CONTAINS[cd] %@", criteria))
    }
    
    private static func cities(maching predicate: NSPredicate?, limit: Int = Int.max) -> NSFetchRequest<MMTCity>
    {
        let
        fetchRequest = NSFetchRequest<MMTCity>(entityName: "MMTCity")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        fetchRequest.predicate = predicate
        fetchRequest.fetchLimit = limit
        
        return fetchRequest
    }
}
