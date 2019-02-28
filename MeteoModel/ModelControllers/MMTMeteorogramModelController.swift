//
//  MMTMeteorogramPreviewModelController.swift
//  MeteoModel
//
//  Created by szostakowskik on 11.06.2018.
//  Copyright © 2018 Kamil Szostakowski. All rights reserved.
//

import Foundation
import CoreSpotlight

public class MMTMeteorogramModelController: MMTModelController
{
    // MARK: Properties
    public var meteorogram: MMTMeteorogram?
    public var error: MMTError?
    public var requestPending: Bool
    public var city: MMTCityProt
    
    public var climateModel: MMTClimateModel {
        return dataStore.climateModel
    }
    
    private var dataStore: MMTMeteorogramDataStore
    private var citiesStore: MMTCitiesStore
    
    // MARK: Initializers    
    public init(city: MMTCityProt, meteorogramStore: MMTMeteorogramDataStore, citiesStore: MMTCitiesStore)
    {
        self.city = city
        self.dataStore = meteorogramStore
        self.citiesStore = citiesStore
        self.requestPending = false
    }
    
    // MARK: Lifecycle methods
    public override func activate()
    {
        downloadMeteorogram()
    }
    
    public override func deactivate()
    {
        citiesStore.save(city: city)
    }
}

extension MMTMeteorogramModelController
{
    // MARK: Interface methods
    public func onToggleFavorite()
    {
        city.isFavourite = !city.isFavourite
        delegate?.onModelUpdate(self)
    }
}

extension MMTMeteorogramModelController
{
    // MARK: Data update methods
    fileprivate func downloadMeteorogram()
    {
        requestPending = true
        delegate?.onModelUpdate(self)
        
        dataStore.meteorogram(for: city) {
            
            self.requestPending = false
            
            if case let .success(meteorogram) = $0 {
                self.meteorogram = meteorogram
                self.error = nil
            }
            
            if case let .failure(error) = $0 {
                self.error = error
                self.meteorogram = nil
            }            
            
            self.delegate?.onModelUpdate(self)
        }
    }
}
