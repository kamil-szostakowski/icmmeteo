//
//  MMTMeteorogramStore.swift
//  MobileMeteo
//
//  Created by Kamil Szostakowski on 08.07.2015.
//  Copyright (c) 2015 Kamil Szostakowski. All rights reserved.
//

import Foundation

public class MMTMeteorogramStore: NSObject
{
    var meteorogramTitle: String { fatalError("") }
    
    var forecastLength: Int { fatalError("") }
    
    func forecastStartDateForDate(date: NSDate) -> NSDate { fatalError("") }
    
    func getMeteorogramWithQuery(query: MMTMeteorogramQuery, completion: MMTFetchMeteorogramCompletion) { fatalError("") }
}