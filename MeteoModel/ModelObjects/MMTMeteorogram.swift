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
    public let model: MMTClimateModel
    public var image: UIImage
    public var legend: UIImage?
    public var startDate: Date
    
    init(model: MMTClimateModel) {
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
    
    init(model: MMTClimateModel) {
        self.model = model
        self.startDate = model.startDate(for: Date())
        self.images = []
        self.moments = []
    }
}
