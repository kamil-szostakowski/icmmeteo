//
//  MMTTodayModelController.swift
//  MeteoModel
//
//  Created by szostakowskik on 27.06.2018.
//  Copyright © 2018 Kamil Szostakowski. All rights reserved.
//

import Foundation
import CoreLocation

public protocol MMTTodayModelController: MMTModelController
{
    var updateResult: MMTResult<MMTMeteorogram> { get }
    
    func onUpdate(completion: @escaping (MMTUpdateResult) -> Void)
    
    func onUpdate(_ city: MMTCityProt, completion: @escaping (MMTUpdateResult) -> Void)
}

class MMTTodayModelControllerImpl: MMTBaseModelController, MMTTodayModelController
{    
    // MARK: Properties
    private var forecastService: MMTForecastService
    private var locationService: MMTLocationService
    private var environment: MMTEnvironment
    private(set) var updateResult: MMTResult<MMTMeteorogram>

    // MARK: Initializers
    init(_ forecastService: MMTForecastService, _ locationService: MMTLocationService, _ environment: MMTEnvironment = .normal)
    {
        self.forecastService = forecastService
        self.locationService = locationService
        self.environment = environment
        self.updateResult = .failure(.forecastUndetermined)
    }

    // MARK: Interface methods    
    func onUpdate(completion: @escaping (MMTUpdateResult) -> Void)
    {
        locationService.requestLocation().observe {
            guard self.locationService.authorizationStatus == .whenInUse else {
                self.updateResult = .failure(.locationServicesDisabled)
                self.notifyWatchers(.failed, completion: completion)
                return
            }
            
            self.update($0, completion)
        }
    }
    
    func onUpdate(_ city: MMTCityProt, completion: @escaping (MMTUpdateResult) -> Void)
    {
        forecastService.update(for: city) { status in
            defer { self.notifyWatchers(status, completion: completion) }
            
            if var meteorogram = self.forecastService.currentMeteorogram {
                if self.environment == .normal {
                    meteorogram.prediction = try? MMTCoreMLPredictionModel().predict(meteorogram)
                }
                self.updateResult = .success(meteorogram)
            }
        }
    }
}

extension MMTTodayModelControllerImpl
{
    // MARK: Update methods
    fileprivate func update(_ result: MMTResult<MMTCityProt>, _ completion: @escaping (MMTUpdateResult) -> Void)
    {
        switch result {
            case let .success(city):
                onUpdate(city, completion: completion)
            case .failure(_):
                updateResult = .failure(.meteorogramFetchFailure)
                notifyWatchers(.failed, completion: completion)
        }
    }
    
    fileprivate func notifyWatchers(_ status: MMTUpdateResult, completion:  @escaping (MMTUpdateResult) -> Void)
    {
        delegate?.onModelUpdate(self)
        completion(status)
    }
}
