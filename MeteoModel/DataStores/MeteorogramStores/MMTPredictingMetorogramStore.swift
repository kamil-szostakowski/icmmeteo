//
//  MMTPredictingForecastService.swift
//  MeteoModel
//
//  Created by szostakowskik on 11/03/2019.
//  Copyright © 2019 Kamil Szostakowski. All rights reserved.
//

import Foundation

class MMTPredictingMetorogramStore: MMTMeteorogramDataStore
{
    // MARK: Properties
    private var store: MMTMeteorogramDataStore
    private var predictionService: MMTPredictionModel?
    private(set) var climateModel: MMTClimateModel
    
    // MARK: Initializers
    init(_ store: MMTMeteorogramDataStore, _ predictor: MMTPredictionModel? = nil)
    {
        self.store = store
        self.predictionService = predictor
        self.climateModel = store.climateModel
    }
    
    // MARK: Interface methods
    func meteorogram(for city: MMTCityProt, completion: @escaping (MMTResult<MMTMeteorogram>) -> Void)
    {
        store.meteorogram(for: city) {
            guard case var .success(meteorogram) = $0 else {
                completion($0)
                return
            }
            
            guard meteorogram.prediction == nil, let predictor = self.predictionService else {
                completion($0)
                return
            }
            
            meteorogram.prediction = try? predictor.predict(meteorogram)
            completion(.success(meteorogram))
        }
    }
    
    func meteorogram(for map: MMTDetailedMap, completion: @escaping (MMTResult<MMTMapMeteorogram>) -> Void)
    {
        store.meteorogram(for: map, completion: completion)
    }
}
