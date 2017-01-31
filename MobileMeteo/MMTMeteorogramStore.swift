//
//  MMTUmMeteorogramStore.swift
//  MobileMeteo
//
//  Created by Kamil Szostakowski on 19.08.2015.
//  Copyright (c) 2015 Kamil Szostakowski. All rights reserved.
//

import Foundation
import CoreLocation
import CoreGraphics

class MMTMeteorogramStore: MMTForecastStore
{
    // MARK: Properties
    
    private var urlSession: MMTMeteorogramUrlSession
    
    // MARK: Initializers
    
    override init(model: MMTClimateModel, date: Date)
    {
        urlSession = MMTMeteorogramUrlSession(redirectionBaseUrl: try! URL.mmt_meteorogramDownloadBaseUrl(for: model.type), timeout: 60)        
        super.init(model: model, date: date)
    }
    
    // MARK: Methods
    
    func getMeteorogramForLocation(_ location: CLLocation, completion: @escaping MMTFetchMeteorogramCompletion)
    {
        urlSession.fetchMeteorogramImageForUrl(try! URL.mmt_meteorogramSearchUrl(for: climateModel.type, location: location), completion: completion)
    }
    
    func getMeteorogramLegend(_ completion: @escaping MMTFetchMeteorogramCompletion)
    {        
        urlSession.fetchImageFromUrl(try! URL.mmt_meteorogramLegendUrl(for: climateModel.type), completion: completion)
    }
}
