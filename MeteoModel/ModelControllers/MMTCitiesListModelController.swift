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
    public var cities = [MMTCityProt]()
    public var searchInput = MMTSearchInput("")
    
    // MARK: Initializers    
    public init(store: MMTCitiesStore)
    {
        self.citiesStore = store
    }
    
    // MARK: Lifecycle methods
    public override func activate()
    {
        print("Updated model with all cities")
        updateAllCities()
    }
    
    // MARK: Interface methods
    public func onSearchPhraseChange(phrase: String?)
    {
        let newSearchInput = MMTSearchInput(phrase ?? "")
        
        guard searchInput != newSearchInput else {
            return
        }
        
        searchInput = newSearchInput
        
        guard newSearchInput.stringValue.count > 0 else {
            print("Updated model because search was canceled")
            updateAllCities()
            return
        }
        
        guard newSearchInput.isValid else {
            return
        }
        
        updateCities(matching: searchInput)
    }    
}

extension MMTCitiesListModelController
{
    // MARK: Data update methods
    fileprivate func updateAllCities()
    {
        citiesStore.all {
            self.cities = $0
            self.delegate?.onModelUpdate(self)
        }
    }
    
    fileprivate func updateCities(matching criteria: MMTSearchInput)
    {
        citiesStore.cities(matching: criteria.stringValue) {
            
            guard self.cities != $0 else {
                print("Canceled update because search result didn't change")
                return
            }
            
            print("Updated model with search result")
            self.cities = $0
            self.delegate?.onModelUpdate(self)
        }
    }
}
