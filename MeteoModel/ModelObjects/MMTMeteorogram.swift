//
//  MMTMeteorogram.swift
//  MeteoModel
//
//  Created by szostakowskik on 19.03.2018.
//  Copyright © 2018 Kamil Szostakowski. All rights reserved.
//

import UIKit

public struct MMTMeteorogram
{
    public struct Prediction: OptionSet
    {
        public let rawValue: Int
        public static var snow = Prediction(rawValue: 1 << 0)
        public static var rain = Prediction(rawValue: 1 << 1)
        public static var storm = Prediction(rawValue: 1 << 2)
        public static var strongWind = Prediction(rawValue: 1 << 3)
        public static var clouds = Prediction(rawValue: 1 << 4)
        
        public init(rawValue: Int) {
            self.rawValue = rawValue
        }
    }
    
    public let model: MMTClimateModel
    public let city: MMTCityProt
    public internal(set) var image: UIImage
    public internal(set) var legend: UIImage?
    public internal(set) var startDate: Date
    public internal(set) var prediction: Prediction?
    
    init(model: MMTClimateModel, city: MMTCityProt)
    {
        self.city = city
        self.model = model
        self.startDate = model.startDate(for: Date())
        self.image = UIImage()
        self.legend = nil
    }
}

public struct MMTMapMeteorogram
{
    public let model: MMTClimateModel
    public var startDate: Date
    public var images: [UIImage?]
    public var moments: [Date]
    
    init(model: MMTClimateModel)
    {
        self.model = model
        self.startDate = model.startDate(for: Date())
        self.images = []
        self.moments = []
    }
}
