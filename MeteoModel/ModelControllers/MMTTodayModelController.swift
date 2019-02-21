//
//  MMTTodayModelController.swift
//  MeteoModel
//
//  Created by szostakowskik on 27.06.2018.
//  Copyright © 2018 Kamil Szostakowski. All rights reserved.
//

import Foundation
import CoreLocation

public class MMTTodayModelController: MMTModelController
{
    // MARK: Properties
    private var forecastService: MMTForecastService
    private var locationService: MMTLocationService
    private var cache: MMTPredictionCache
    
    public private(set) var meteorogram: MMTMeteorogram?
    public private(set) var locationServicesEnabled: Bool = false

    // MARK: Initializers
    public init(_ forecastService: MMTForecastService, _ locationService: MMTLocationService)
    {
        self.cache = MMTPredictionCache()
        self.forecastService = forecastService
        self.locationService = locationService
    }

    // MARK: Interface methods
    public func onUpdate(completion: @escaping (MMTUpdateResult) -> Void)
    {
        locationService.requestLocation().observe {
            self.locationServicesEnabled = self.locationService.authorizationStatus != .unauthorized
            switch $0 {
            case let .success(city):
                self.updateForecast(for: city, completion: completion)
            case .failure(_):
                self.meteorogram = nil                
                self.notifyWatchers(.failed, completion: completion)
            }
        }
    }
}

extension MMTTodayModelController
{
    // MARK: Update methods
    fileprivate func updateForecast(for city: MMTCityProt?, completion: @escaping (MMTUpdateResult) -> Void)
    {
        forecastService.update(for: city) { status in
            
            defer { self.notifyWatchers(status, completion: completion) }
            guard status == .newData else { return }
            
            if let meteorogram = self.forecastService.currentMeteorogram {
                self.meteorogram = meteorogram
                self.meteorogram?.prediction = self.prediction(for: meteorogram)
            }
        }
    }
    
    fileprivate func notifyWatchers(_ status: MMTUpdateResult, completion:  @escaping (MMTUpdateResult) -> Void)
    {
        delegate?.onModelUpdate(self)
        completion(status)
    }
    
    fileprivate func prediction(for meteorogram: MMTMeteorogram) -> MMTMeteorogram.Prediction?
    {
        guard requiresMemoryOptimization() else {
            return cache.getPrediction(for: meteorogram)
        }
        
        var
        aMeteorogram = meteorogram
        aMeteorogram.prediction = try? MMTCoreMLPredictionModel.shared.predict(meteorogram)
        cache.storePrediction(for: aMeteorogram)
            
        return aMeteorogram.prediction
    }
    
    fileprivate func requiresMemoryOptimization() -> Bool
    {
        return Bundle.main.bundleIdentifier == "com.szostakowski.meteo"
    }
}
