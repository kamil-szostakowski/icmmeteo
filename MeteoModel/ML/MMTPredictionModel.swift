//
//  MMTPredictionModel.swift
//  MeteoModel
//
//  Created by szostakowskik on 20/02/2019.
//  Copyright © 2019 Kamil Szostakowski. All rights reserved.
//

import Foundation

// MARK: Protocol definition
public protocol MMTPredictionModel
{
    func predict(_ image: MMTMeteorogram) throws -> MMTMeteorogram.Prediction
}
