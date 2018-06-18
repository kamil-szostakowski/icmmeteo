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
        guard let newLocation = location else {
            error = nil
            requestPending = false
            tryUpdateCurrentCity(with: nil)            
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
                print("Updated model because geolocation failure")
                self.delegate?.onModelUpdate(self)
                return
            }
            
            self.tryUpdateCurrentCity(with: aCity)
        }
    }
    
    fileprivate func tryUpdateCurrentCity(with city: MMTCityProt?)
    {
        guard currentCity != city else {
            print("Canceleded model update because destination didn't change")
            return
        }
        
        print("Updated model with current location \(String(describing: city?.location.coordinate))")
        
        currentCity = city
        delegate?.onModelUpdate(self)
    }
}
