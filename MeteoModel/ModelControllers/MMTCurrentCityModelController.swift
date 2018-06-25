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
            onCurrentCityUpdate(city: nil)
            return
        }
        
        updateCurrentCity(for: newLocation)
    }
    
    func onCurrentCityUpdate(city: MMTCityProt?)
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

extension MMTCurrentCityModelController
{
    fileprivate func updateCurrentCity(for location: CLLocation)
    {
        error = nil
        requestPending = true
        delegate?.onModelUpdate(self)
        
        citiesStore.city(for: location) {
            self.requestPending = false
            
            if case let .failure(error) = $0 {
                print("Updated model because geolocation failure")
                self.error = error
                self.delegate?.onModelUpdate(self)
            }
            
            if case let .success(city) = $0 {
                self.onCurrentCityUpdate(city: city)
            }
        }
    }
}
