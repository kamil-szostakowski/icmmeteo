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
        guard locationService.authorizationStatus == .always else {
            meteorogram = nil
            locationServicesEnabled = false
            delegate?.onModelUpdate(self)
            completion(.failed)
            return
        }
    
        locationServicesEnabled = true
        
        forecastService.update(for: locationService.currentLocation) { status in
            defer { completion(status) }
            
            guard let meteorogram = self.forecastService.currentMeteorogram else {
                return
            }
            
            if status == .newData
            {
                self.meteorogram = meteorogram
                self.delegate?.onModelUpdate(self)
            }
        }
    }
}
