//
//  MMTMeteorogramChate.swift
//  MeteoModel
//
//  Created by szostakowskik on 05/03/2019.
//  Copyright © 2019 Kamil Szostakowski. All rights reserved.
//

import Foundation

public protocol MMTMeteorogramCache
{
    @discardableResult
    func store(_ meteorogram: MMTMeteorogram) -> Bool
    
    func restore() -> MMTMeteorogram?
    
    @discardableResult
    func cleanup() -> Bool
}
