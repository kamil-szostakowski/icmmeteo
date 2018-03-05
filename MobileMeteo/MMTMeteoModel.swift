//
//  MMTMeteoModel.swift
//  MobileMeteo
//
//  Created by szostakowskik on 03.03.2018.
//  Copyright © 2018 Kamil Szostakowski. All rights reserved.
//

import Foundation
import MeteoModel
import CoreLocation

extension MMTCityGeocoder
{
    convenience init()
    {
        self.init(general: CLGeocoder())
    }
}

extension MMTCitiesStore
{
    public convenience init()
    {
        self.init(context: MMTCoreData.instance.context, geocoder: MMTCityGeocoder())
    }
}
