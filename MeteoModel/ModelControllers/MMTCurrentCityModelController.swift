//
//  MMTCurrentCityModelController.swift
//  MeteoModel
//
//  Created by szostakowskik on 13.06.2018.
//  Copyright © 2018 Kamil Szostakowski. All rights reserved.
//

import Foundation
import CoreLocation

public class MMTCurrentCityModelController: MMTModelController
{
    // MARK: Properties
    private var citiesStore: MMTCitiesStore
    public var currentCity: MMTCityProt?
    public var requestPending: Bool
    public var error: MMTError?
    
    // MARK: Initializers
    public init(store: MMTCitiesStore)
    {
        requestPending = false
        citiesStore = store
    }    
    
    // MARK: Interface methods
    public func onLocationChange(location: CLLocation?)
    {
        guard let newLocation = location else
        {
            requestPending = false
            currentCity = nil
            error = nil
            delegate?.onModelUpdate(self)
            return
        }
        
        updateCurrentCity(for: newLocation)
    }
}

extension MMTCurrentCityModelController
{
    fileprivate func updateCurrentCity(for location: CLLocation)
    {
        error = nil
        requestPending = true
        delegate?.onModelUpdate(self)
        
        citiesStore.city(for: location) { (city: MMTCityProt?, error: MMTError?) in
            self.requestPending = false
            self.error = error
            
            guard let aCity = city, error == nil else {
                self.delegate?.onModelUpdate(self)
                return
            }
            
            guard self.currentCity != aCity else {
                return
            }
            
            self.currentCity = city
            self.delegate?.onModelUpdate(self)
        }
    }
}
