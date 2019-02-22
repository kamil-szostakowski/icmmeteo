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
    private var cache: MMTSingleMeteorogramCache
    
    public private(set) var environment: MMTEnvironment
    public private(set) var meteorogram: MMTMeteorogram?
    public private(set) var locationServicesEnabled: Bool = false

    // MARK: Initializers
    public init(_ forecastService: MMTForecastService, _ locationService: MMTLocationService, _ environment: MMTEnvironment = .normal)
    {
        self.cache = MMTSingleMeteorogramCache()
        self.forecastService = forecastService
        self.locationService = locationService
        self.environment = environment
    }

    // MARK: Interface methods
    public func onUpdate(completion: @escaping (MMTUpdateResult) -> Void)
    {
        locationService.requestLocation().observe {
            self.locationServicesEnabled = self.locationService.authorizationStatus == .always
            
            guard self.locationServicesEnabled else {
                self.cache.cleanup { _ in }
                //self.meteorogram = nil
                self.notifyWatchers(.failed, completion: completion)
                return
            }
            
            switch self.environment {
                case .memoryConstrained: self.updateUnderMemoryPressure(completion)
                case .normal: self.updateNormally($0, completion)
            }
        }
    }
}

extension MMTTodayModelController
{
    // MARK: Update methods
    fileprivate func updateUnderMemoryPressure(_ completion: @escaping (MMTUpdateResult) -> Void)
    {
        cache.restore { meteorogram in
            DispatchQueue.main.async {
                self.meteorogram = meteorogram
                self.notifyWatchers(meteorogram != nil ? .newData : .failed, completion: completion)
            }
        }
    }
    
    fileprivate func updateNormally(_ result: MMTResult<MMTCityProt>, _ completion: @escaping (MMTUpdateResult) -> Void)
    {
        switch result {
            case let .success(city):
                updateForecast(for: city, completion: completion)
            case .failure(_):
                meteorogram = nil
                notifyWatchers(.failed, completion: completion)
        }
    }
    
    fileprivate func updateForecast(for city: MMTCityProt?, completion: @escaping (MMTUpdateResult) -> Void)
    {
        forecastService.update(for: city) { status in
            
            defer { self.notifyWatchers(status, completion: completion) }
            guard status == .newData else { return }
            
            if var meteorogram = self.forecastService.currentMeteorogram
            {
                meteorogram.prediction = try? MMTCoreMLPredictionModel.shared.predict(meteorogram)
                self.meteorogram = meteorogram
                self.cache.store(meteorogram: meteorogram) { _ in }
            }
        }
    }
    
    fileprivate func notifyWatchers(_ status: MMTUpdateResult, completion:  @escaping (MMTUpdateResult) -> Void)
    {
        delegate?.onModelUpdate(self)
        completion(status)
    }
}
