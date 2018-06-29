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

    public private(set) var updateResult: MMTResult<MMTMeteorogram>?
    public private(set) var locationServicesEnabled: Bool = false

    // MARK: Initializers
    public init(forecastService: MMTForecastService)
    {
        self.forecastService = forecastService
    }

    // MARK: Interface methods
    public func onUpdate(location: CLLocation?, completion: @escaping (MMTUpdateResult) -> Void)
    {        
        forecastService.update(for: location) { status in
            defer { completion(status) }
            
            guard let meteorogram = self.forecastService.currentMeteorogram else {
                return
            }
            
            if status == .newData
            {
                self.updateResult = .success(meteorogram)
                self.delegate?.onModelUpdate(self)
            }
        }
    }
}
