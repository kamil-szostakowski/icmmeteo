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
    // MARK: Inner types
    public enum UpdateError
    {
        case locationServicesUnavailable
        case meteorogramUpdateFailure        
        case undetermined
    }
    
    public enum UpdateResult
    {
        case success(MMTMeteorogram)
        case failure(UpdateError)
    }
    
    // MARK: Properties
    private var forecastService: MMTForecastService
    private var locationService: MMTLocationService
    
    public private(set) var environment: MMTEnvironment
    public private(set) var updateResult: UpdateResult

    // MARK: Initializers
    public init(_ forecastService: MMTForecastService, _ locationService: MMTLocationService, _ environment: MMTEnvironment = .normal)
    {
        self.forecastService = forecastService
        self.locationService = locationService
        self.environment = environment
        self.updateResult = .failure(.undetermined)
    }

    // MARK: Interface methods
    public func onUpdate(completion: @escaping (MMTUpdateResult) -> Void)
    {
        locationService.requestLocation().observe {
            guard self.locationService.authorizationStatus == .always else {
                self.updateResult = .failure(.locationServicesUnavailable)
                self.notifyWatchers(.failed, completion: completion)
                return
            }
            
            self.update($0, completion)
        }
    }
}

extension MMTTodayModelController
{
    // MARK: Update methods
    fileprivate func update(_ result: MMTResult<MMTCityProt>, _ completion: @escaping (MMTUpdateResult) -> Void)
    {
        switch result {
            case let .success(city):
                updateForecast(for: city, completion: completion)
            case .failure(_):
                updateResult = .failure(.meteorogramUpdateFailure)
                notifyWatchers(.failed, completion: completion)
        }
    }
    
    fileprivate func updateForecast(for city: MMTCityProt, completion: @escaping (MMTUpdateResult) -> Void)
    {
        forecastService.update(for: city) { status in
            
            defer { self.notifyWatchers(status, completion: completion) }
            
            if var meteorogram = self.forecastService.currentMeteorogram
            {
                if self.environment == .normal {
                    meteorogram.prediction = try? MMTCoreMLPredictionModel().predict(meteorogram)
                }
                self.updateResult = .success(meteorogram)
            }
        }
    }
    
    fileprivate func notifyWatchers(_ status: MMTUpdateResult, completion:  @escaping (MMTUpdateResult) -> Void)
    {
        delegate?.onModelUpdate(self)
        completion(status)
    }
}
