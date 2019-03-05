//
//  MMTTestTools.swift
//  MobileMeteo
//
//  Created by Kamil Szostakowski on 31.07.2015.
//  Copyright (c) 2015 Kamil Szostakowski. All rights reserved.
//

import UIKit
import Foundation
import CoreLocation
@testable import MeteoModel

typealias TT = MMTTestTools

class MMTTestTools
{
    static func getDate(_ year: Int, _ month: Int, _ day: Int, _ hour: Int) -> Date
    {
        var
        components = DateComponents()
        components.timeZone = TimeZone(identifier: "UTC")
        components.year = year
        components.month = month
        components.day = day
        components.hour = hour
        
        return Calendar.current.date(from: components)!
    }
    
    static var localFormatter: DateFormatter
    {
        let
        localFormatter = DateFormatter()
        localFormatter.dateFormat = "YYYY-MM-dd'T'HH:mm"
        localFormatter.timeZone = TimeZone(secondsFromGMT:7200)
        
        return localFormatter
    }
    
    static var utcFormatter: DateFormatter
    {
        let
        utcFormatter = DateFormatter()
        utcFormatter.dateFormat = "YYYY-MM-dd'T'HH:mm"
        utcFormatter.timeZone = TimeZone(identifier: "UTC")
            
        return utcFormatter
    }
    
    static var cachesUrl: URL
    {
        let fm = FileManager.default
        let url = fm.urls(for: .documentDirectory, in: .allDomainsMask).first!
        
        if fm.fileExists(atPath: url.path) == false {
            try! fm.createDirectory(at: url, withIntermediateDirectories: true, attributes: nil)
        }
        
        return url
    }
}

extension UIImage
{
    static func from(color: UIColor, _ size: CGSize = CGSize(width: 1, height: 1)) -> UIImage
    {
        UIGraphicsBeginImageContext(size)
        guard let context = UIGraphicsGetCurrentContext() else {
            fatalError("Failed to obtain CGContext")
        }
        
        context.setFillColor(color.cgColor)
        context.fill(CGRect(origin: .zero, size: size))
        
        guard let image = UIGraphicsGetImageFromCurrentImageContext() else {
            fatalError("Failed to obtain image from CGContext")
        }
        
        UIGraphicsEndImageContext()        
        return image
    }
    
    convenience init(thisBundle named: String)
    {
        self.init(named: named, in: Bundle(for: MMTTestTools.self), compatibleWith: nil)!
    }
}

extension MMTMeteorogram
{
    static func meteorogram(city: String, startDate: Date) -> MMTMeteorogram
    {
        let location = CLLocation(latitude: 1.0, longitude: 2.0)
        let city = MMTCityProt(name: city, region: "xyz", location: location)
        
        var
        meteorogram = MMTMeteorogram(model: MMTUmClimateModel(), city: city)
        meteorogram.prediction = MMTMeteorogram.Prediction([.snow, .strongWind])
        meteorogram.image = UIImage(thisBundle: "2018092900-381-199-full")
        meteorogram.startDate = startDate
        
        return meteorogram
    }
    
    static var loremCity: MMTMeteorogram {
        return meteorogram(city: "Lorem", startDate: Date.from(2019, 3, 20, 10, 15, 20))
    }
}
