//
//  MMTCitiesListModelController.swift
//  MeteoModel
//
//  Created by szostakowskik on 01.06.2018.
//  Copyright © 2018 Kamil Szostakowski. All rights reserved.
//

import Foundation
import CoreLocation

public class MMTCitiesListModelController: MMTModelController
{
    // MARK: Properties
    private var citiesStore: MMTCitiesStore
    
    public weak var delegate: MMTModelControllerDelegate?
    public var currentCity: MMTCityProt?
    public var cities = [MMTCityProt]()
    public var searchInput = MMTSearchInput("")
    
    // MARK: Initializers    
    public init(store: MMTCitiesStore)
    {
        self.citiesStore = store
    }
    
    // MARK: Lifecycle methods
    public func activate()
    {
        updateAllCities()
    }
    
    public func deactivate()
    {
    }
    
    // MARK: Interface methods
    public func onSearchPhraseChange(phrase: String?)
    {
        // TODO: Cancel action when the input didn't change
        searchInput = MMTSearchInput(phrase ?? "")
        
        guard searchInput.isValid else {
            updateAllCities()
            return
        }
        
        updateCities(matching: searchInput.stringValue)
    }
    
    public func onLocationChange(location: CLLocation?)
    {
        guard let newLocation = location else {
            updateAllCities()
            return
        }
        
        updateCurrentCity(for: newLocation)
    }
}

extension MMTCitiesListModelController
{
    // MARK: Data update methods
    fileprivate func updateAllCities()
    {
        citiesStore.all {
            self.cities = $0
            self.delegate?.onModelUpdate()
        }
    }
    
    fileprivate func updateCities(matching criteria: String)
    {
        citiesStore.cities(maching: criteria) {
            self.cities = $0
            self.delegate?.onModelUpdate()
        }
    }
    
    fileprivate func updateCurrentCity(for location: CLLocation)
    {
        citiesStore.city(for: location) { (city: MMTCityProt?, error: MMTError?) in
            guard let aCity = city, error == nil else {
                return
            }
            
            guard self.currentCity != aCity else {
                return
            }
            
            self.currentCity = aCity
            self.delegate?.onModelUpdate()
        }
    }
}
