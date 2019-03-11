//
//  MMTPredictingForecastService.swift
//  MeteoModel
//
//  Created by szostakowskik on 11/03/2019.
//  Copyright © 2019 Kamil Szostakowski. All rights reserved.
//

import Foundation

class MMTPredictingForecastService: MMTForecastService
{
    // MARK: Properties
    private var forecastService: MMTForecastService
    private var predictionService: MMTPredictionModel?
    
    var currentMeteorogram: MMTMeteorogram?
    
    // MARK: Initializers
    init(_ service: MMTForecastService, _ predictor: MMTPredictionModel? = nil)
    {
        self.forecastService = service
        self.predictionService = predictor
    }
    
    // MARK: Interface methods
    func update(for location: MMTCityProt, completion: @escaping (MMTUpdateResult) -> Void)
    {
        forecastService.update(for: location) { status in
            defer { completion(status) }
            
            guard var meteorogram = self.forecastService.currentMeteorogram else {
                self.currentMeteorogram = nil
                return
            }
            
            guard meteorogram.prediction == nil, let predictor = self.predictionService else {
                self.currentMeteorogram = meteorogram
                return
            }
            
            meteorogram.prediction = try? predictor.predict(meteorogram)
            self.currentMeteorogram = meteorogram
        }
    }
}
