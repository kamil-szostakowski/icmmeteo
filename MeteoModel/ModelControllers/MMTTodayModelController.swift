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
    
    public private(set) var meteorogram: MMTMeteorogram?
    public private(set) var meteorogramDescription: MMTMeteorogramDescription?
    public private(set) var locationServicesEnabled: Bool = false

    // MARK: Initializers
    public init(_ forecastService: MMTForecastService, _ locationService: MMTLocationService)
    {
        self.forecastService = forecastService
        self.locationService = locationService
    }

    // MARK: Interface methods
    public func onUpdate(completion: @escaping (MMTUpdateResult) -> Void)
    {
        locationService.requestLocation().observe {
            switch $0 {
            case let .success(city):
                self.locationServicesEnabled = true
                self.updateForecast(for: city, completion: completion)
            case .failure(_):
                self.meteorogram = nil
                self.meteorogramDescription = nil
                self.locationServicesEnabled = false
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
            guard let meteorogram = self.forecastService.currentMeteorogram else { return }
            
            self.meteorogram = meteorogram
            self.meteorogramDescription = MMTMeteorogramDescription(meteorogram)
        }
    }
    
    fileprivate func notifyWatchers(_ status: MMTUpdateResult, completion:  @escaping (MMTUpdateResult) -> Void)
    {
        delegate?.onModelUpdate(self)
        completion(status)
    }
}
