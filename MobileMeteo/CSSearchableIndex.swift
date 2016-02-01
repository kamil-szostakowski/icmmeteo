//
//  CSSearchableIndex.swift
//  MobileMeteo
//
//  Created by Kamil Szostakowski on 26.01.2016.
//  Copyright © 2016 Kamil Szostakowski. All rights reserved.
//

import Foundation
import CoreSpotlight
import CoreLocation

@available(iOS 9.0, *)
extension CSSearchableIndex
{    
    func indexSearchableCity(city: MMTCityProt, completion:((NSError?) -> Void)?)
    {
        let domainId = MMTActivityTypeDisplayModelUm
        let uniqueId = CSSearchableIndex.uniqueIdForSearchableCity(city)
        
        let
        attributes = CSSearchableItemAttributeSet(itemContentType: MMTActivityTypeDisplayModelUm)
        attributes.contentDescription = "Prognoza pogody w modelu UM\nSiatka: 4km. Długość prognozy 60h"
        attributes.keywords = ["Pogoda", "Model UM", city.name]
        attributes.displayName = "\(city.name), \(city.region)"
        
        let
        searchableItem = CSSearchableItem(uniqueIdentifier: uniqueId, domainIdentifier: domainId, attributeSet: attributes)
        searchableItem.expirationDate = NSDate(timeIntervalSinceNow: 2592000.0)
        
        indexSearchableItems([searchableItem], completionHandler: completion)
    }
    
    func deleteSearchableCity(city: MMTCityProt, completion:((NSError?) -> Void)?)
    {
        let uniqueId = CSSearchableIndex.uniqueIdForSearchableCity(city)
        deleteSearchableItemsWithIdentifiers([uniqueId], completionHandler: completion)
    }
    
    static func uniqueIdForSearchableCity(city: MMTCityProt) -> String
    {        
        return "\(MMTActivityTypeDisplayModelUm).\(city.location.coordinate.latitude):\(city.location.coordinate.longitude)"
    }    
    
    static func locationForSearchableCityUniqueId(uniqueId: String) -> CLLocation?
    {
        let uid = uniqueId.stringByReplacingOccurrencesOfString("\(MMTActivityTypeDisplayModelUm).", withString: "")
        let components = uid.componentsSeparatedByString(":")
        
        guard components.count == 2 else { return nil }        
        guard let lat = CLLocationDegrees(components.first!) else { return nil }
        guard let lng = CLLocationDegrees(components.last!) else { return nil }
        
        return CLLocation(latitude: lat, longitude: lng)
    }    
}
