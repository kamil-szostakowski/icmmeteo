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
    func indexSearchableCity(_ city: MMTCityProt, completion:((NSError?) -> Void)?)
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
        searchableItem.expirationDate = Date(timeIntervalSinceNow: 2592000.0)
        
        indexSearchableItems([searchableItem], completionHandler: completion as! ((Error?) -> Void)?)
    }
    
    func deleteSearchableCity(_ city: MMTCityProt, completion:((NSError?) -> Void)?)
    {
        let uniqueId = CSSearchableIndex.uniqueIdForSearchableCity(city)
        deleteSearchableItems(withIdentifiers: [uniqueId], completionHandler: completion as! ((Error?) -> Void)?)
    }
    
    static func uniqueIdForSearchableCity(_ city: MMTCityProt) -> String
    {        
        return "\(MMTActivityTypeDisplayModelUm).\(city.location.coordinate.latitude):\(city.location.coordinate.longitude)"
    }    
    
    static func locationForSearchableCityUniqueId(_ uniqueId: String) -> CLLocation?
    {
        let uid = uniqueId.replacingOccurrences(of: "\(MMTActivityTypeDisplayModelUm).", with: "")
        let components = uid.components(separatedBy: ":")
        
        guard components.count == 2 else { return nil }        
        guard let lat = CLLocationDegrees(components.first!) else { return nil }
        guard let lng = CLLocationDegrees(components.last!) else { return nil }
        
        return CLLocation(latitude: lat, longitude: lng)
    }    
}
