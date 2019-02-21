//
//  MMTPredictionCache.swift
//  MeteoModel
//
//  Created by szostakowskik on 20/02/2019.
//  Copyright © 2019 Kamil Szostakowski. All rights reserved.
//

import Foundation

class MMTPredictionCache
{
    // MARK: Structures
    private struct Key
    {
        static let name = "current-city-name"
        static let prediction = "current-city-prediction"
        static let startDate = "current-city-start-date"
    }
    
    // MARK: Properties
    let appGroup = UserDefaults(suiteName: "group.com.szostakowski.meteo")
    
    // MARK: Interface methods
    func storePrediction(for meteorogram: MMTMeteorogram)
    {
        appGroup?.set(meteorogram.city.name, forKey: Key.name)
        appGroup?.set(meteorogram.prediction?.rawValue, forKey: Key.prediction)
        appGroup?.set(meteorogram.startDate.timeIntervalSince1970, forKey: Key.startDate)
        appGroup?.synchronize()
    }
    
    func getPrediction(for meteorogram: MMTMeteorogram) -> MMTMeteorogram.Prediction?
    {
        guard value(for: Key.name) == meteorogram.city.name else {
            return nil
        }
        
        guard value(for: Key.startDate) == meteorogram.startDate.timeIntervalSince1970 else {
            return nil
        }
        
        return MMTMeteorogram.Prediction(rawValue: value(for: Key.prediction) ?? 0)
    }
    
    // MARK: Helper methods
    private func value<T>(for key: String) -> T?
    {
        return appGroup?.value(forKey: key) as? T
    }
}
