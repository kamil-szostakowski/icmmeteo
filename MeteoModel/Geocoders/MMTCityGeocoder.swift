//
//  MMTCityGeocoder.swift
//  MeteoModel
//
//  Created by szostakowskik on 03.07.2018.
//  Copyright © 2018 Kamil Szostakowski. All rights reserved.
//

import Foundation
import CoreLocation

public protocol MMTCityGeocoder
{
    func city(for location: CLLocation, completion: @escaping (MMTResult<MMTCityProt>) -> Void)
    
    func cities(matching criteria: String, completion: @escaping ([MMTCityProt]) -> Void)
}
