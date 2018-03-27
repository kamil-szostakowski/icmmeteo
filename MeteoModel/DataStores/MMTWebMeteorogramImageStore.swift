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

protocol MMTMeteorogramImageStore
{
    var climateModel: MMTClimateModel { get }
    
    func getMeteorogram(for city: MMTCityProt, startDate: Date, completion: @escaping (UIImage?, MMTError?) -> Void)
    
    func getLegend(_ completion: @escaping (UIImage?, MMTError?) -> Void)
    
    func getMeteorogram(for map: MMTDetailedMap, moment: Date, startDate: Date, completion: @escaping (UIImage?, MMTError?) -> Void)
}

struct MMTWebMeteorogramImageStore : MMTMeteorogramImageStore
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
    func getMeteorogram(for city: MMTCityProt, startDate: Date, completion: @escaping (UIImage?, MMTError?) -> Void)
    {
        let url = try! URL.mmt_meteorogramSearchUrl(for: climateModel.type, location: city.location)
        urlSession.meteorogramImage(from: url, completion: completion)    }
    
    func getLegend(_ completion: @escaping (UIImage?, MMTError?) -> Void)
    {
        let url = try! URL.mmt_meteorogramLegendUrl(for: climateModel.type)
        urlSession.image(from: url, completion: completion)
    }
    
    func getMeteorogram(for map: MMTDetailedMap, moment: Date, startDate: Date, completion: @escaping (UIImage?, MMTError?) -> Void)
    {
        let tZeroPlus = Int(moment.timeIntervalSince(startDate)/3600)
        
        guard let downloadUrl = try? URL.mmt_detailedMapDownloadUrl(for: map.climateModel.type, map: map.type, tZero: startDate, plus: tZeroPlus) else {
            completion(nil, .detailedMapNotSupported)
            return
        }
        
        urlSession.image(from: downloadUrl, completion: completion)
    }
}
