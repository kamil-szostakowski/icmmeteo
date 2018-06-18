//
//  MMTCityAnnotation.swift
//  MobileMeteo
//
//  Created by szostakowskik on 13.06.2018.
//  Copyright © 2018 Kamil Szostakowski. All rights reserved.
//

import MapKit
import Foundation

class MMTCityAnnotation: NSObject, MKAnnotation
{
    let coordinate: CLLocationCoordinate2D
    
    init(coordinate: CLLocationCoordinate2D)
    {
        self.coordinate = coordinate
        super.init()
    }
}
