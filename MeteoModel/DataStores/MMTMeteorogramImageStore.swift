//
//  MMTUmMeteorogramStore.swift
//  MobileMeteo
//
//  Created by Kamil Szostakowski on 19.08.2015.
//  Copyright (c) 2015 Kamil Szostakowski. All rights reserved.
//

import UIKit
import Foundation
import CoreLocation

struct MMTMeteorogramImageStore
{
    // MARK: Properties
    private let urlSession: MMTMeteorogramUrlSession
    let climateModel: MMTClimateModel
    
    // MARK: Initializers
    init(model: MMTClimateModel, session: MMTMeteorogramUrlSession)
    {
        self.urlSession = session
        self.climateModel = model
    }
        
    // MARK: Methods
    func getMeteorogram(for city: MMTCityProt, completion: @escaping MMTFetchMeteorogramCompletion)
    {
        let url = try! URL.mmt_meteorogramSearchUrl(for: climateModel.type, location: city.location)
        urlSession.fetchMeteorogramImageForUrl(url, completion: completion)    }
    
    func getLegend(_ completion: @escaping MMTFetchMeteorogramCompletion)
    {
        let url = try! URL.mmt_meteorogramLegendUrl(for: climateModel.type)
        urlSession.fetchImageFromUrl(url, completion: completion)
    }
}
