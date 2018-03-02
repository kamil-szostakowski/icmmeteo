//
//  NSURL.swift
//  MobileMeteo
//
//  Created by Kamil Szostakowski on 19.08.2015.
//  Copyright (c) 2015 Kamil Szostakowski. All rights reserved.
//

import Foundation
import CoreLocation

extension URL
{
    // MARK: Public methods
    
    static func mmt_forecasterCommentUrl() -> URL
    {        
        return URL(string: "komentarze/index1.php", relativeTo: mmt_baseUrl())!
    }
    
    static func mmt_baseUrl() -> URL
    {
        return URL(string: "http://www.meteo.pl")!
    }

    static func mmt_meteorogramSearchUrl(for model: MMTClimateModelType, location: CLLocation) throws -> URL
    {
        let lat = location.coordinate.latitude
        let lng = location.coordinate.longitude

        switch model
        {
            case .UM:
            return URL(string: "/um/php/mgram_search.php?NALL=\(lat)&EALL=\(lng)&lang=\(mmt_modelLang())", relativeTo: mmt_baseUrl())!

            case .COAMPS:
            return URL(string: "/php/mgram_search.php?NALL=\(lat)&EALL=\(lng)&lang=pl", relativeTo: mmt_baseUrl())!

            default:
            throw MMTError.urlNotAvailable
        }
    }
    
    static func mmt_meteorogramDownloadBaseUrl(for model: MMTClimateModelType) throws -> URL
    {
        switch model
        {
            case .UM:
            return URL(string: "/um/metco/mgram_pict.php", relativeTo: mmt_baseUrl())!
            
            case .COAMPS:
            return URL(string: "/metco/mgram_pict.php", relativeTo: mmt_baseUrl())!
            
            default:
            throw MMTError.urlNotAvailable
        }
    }
    
    static func mmt_meteorogramLegendUrl(for model: MMTClimateModelType) throws -> URL
    {
        switch model
        {
            case .UM:
            return URL(string: "/um/metco/leg_um_\(mmt_modelLang())_cbase_256.png", relativeTo: mmt_baseUrl())!
            
            case .COAMPS:
            return URL(string: "/metco/leg4_\(mmt_modelLang()).png", relativeTo: mmt_baseUrl())!
            
            default:
            throw MMTError.urlNotAvailable
        }
    }
    
    static func mmt_forecastStartUrl(for model: MMTClimateModelType) throws -> URL
    {
        switch model
        {
            case .UM:
            return URL(string: "info_um.php", relativeTo: mmt_baseUrl())!
            
            case .COAMPS:
            return URL(string: "info_coamps.php", relativeTo: mmt_baseUrl())!
            
            default:
            return URL(string: "info_wamcoamps.php", relativeTo: mmt_baseUrl())!
        }
    }
    
    static func mmt_detailedMapDownloadUrl(for model: MMTClimateModelType, map: MMTDetailedMapType, tZero: Date, plus: Int) throws -> URL
    {
        switch model
        {
            case .UM:
            return try mmt_umDetailedMapDownloadUrl(for: map, tZero: tZero, plus: plus)
            
            case .COAMPS:
            return try mmt_coampsDetailedMapDownloadUrl(for: map, tZero: tZero, plus: plus)
            
            default:
            return try mmt_wamDetailedMapDownloadUrl(for: map, tZero: tZero, plus: plus)
        }
    }
    
    // MARK: Helper methods
    
    private static func mmt_umDetailedMapDownloadUrl(for map: MMTDetailedMapType, tZero: Date, plus: Int) throws -> URL
    {
        let tZeroString = tZeroStringForDate(tZero)
        let tZeroPlus = NSString(format: "%03ld", plus)
        var prefix: String?
        
        switch map
        {
            case .MeanSeaLevelPressure: prefix = "SLPH"
            case .TemperatureAndStreamLine: prefix = "T+WH"
            case .TemperatureOfSurface: prefix = "GT_H"
            case .Precipitation: prefix = "RS_H"
            case .Storm: prefix = "FLSH"
            case .Wind: prefix = "W__H"
            case .MaximumGust: prefix = "WGSH"
            case .Visibility: prefix = "VISH"
            case .Fog: prefix = "F__H"
            case .RelativeHumidityAboveIce: prefix = "RHiH"
            case .RelativeHumidityAboveWater: prefix = "RHwH"
            case .VeryLowClouds: prefix = "CV_H"
            case .LowClouds: prefix = "CL_H"
            case .MediumClouds: prefix = "CM_H"
            case .HighClouds: prefix = "CH_H"
            case .TotalCloudiness: prefix = "CT_H"
            
            default:
            throw MMTError.urlNotAvailable
        }
        
        return URL(string: "um/pict/\(tZeroString)/\(prefix!)_0000.0_0U_\(tZeroString)_\(tZeroPlus)-00.png", relativeTo: mmt_baseUrl())!
    }
    
    private static func mmt_coampsDetailedMapDownloadUrl(for map: MMTDetailedMapType, tZero: Date, plus: Int) throws -> URL
    {
        let tZeroString = tZeroStringForDate(tZero)
        let tZeroPlus = NSString(format: "%03ld", plus)
        var prefix: String?
        
        switch map
        {
            case .MeanSeaLevelPressure: prefix = "SLPH_0000.0"
            case .TemperatureAndStreamLine: prefix = "T+WH_0010.0"
            case .TemperatureOfSurface: prefix = "GT_H_0000.0"
            case .Precipitation: prefix = "TRSH_0000.0"
            case .Wind: prefix = "W__H_0010.0"
            case .Visibility: prefix = "VISH_0000.0"
            case .RelativeHumidity: prefix = "RH_H_0002.0"
            case .LowClouds: prefix = "CLCS_L"
            case .MediumClouds: prefix = "CLCS_M"
            case .HighClouds: prefix = "CLCS_H"
            case .TotalCloudiness: prefix = "CLCS_T"
            
            default:
            throw MMTError.urlNotAvailable
        }
        
        return URL(string: "/pict/\(tZeroString)/\(prefix!)_2X_\(tZeroString)_\(tZeroPlus)-00.png", relativeTo: mmt_baseUrl())!
    }

    private static func mmt_wamDetailedMapDownloadUrl(for map: MMTDetailedMapType, tZero: Date, plus: Int) throws -> URL
    {
        let tZeroString = tZeroStringForDate(tZero)
        let tZeroPlus = NSString(format: "%03ld", plus)
        var prefix: String?

        switch map
        {
            case .TideHeight: prefix = "wavehgt"
            case .AverageTidePeriod: prefix = "m_period"
            case .SpectrumPeakPeriod: prefix = "p_period"

            default:
            throw MMTError.urlNotAvailable
        }

        return URL(string: "/wamcoamps/pict/\(tZeroString)/\(prefix!)_0W_\(tZeroString)_\(tZeroPlus)-00.png", relativeTo: mmt_baseUrl())!
    }
    
    // MARK: Helper methods
    
    private static func tZeroStringForDate(_ date: Date) -> String
    {
        let components = (Calendar.utcCalendar as NSCalendar).components([.year, .month, .day, .hour], from: date)
        
        return String(format: MMTFormat.TZero, components.year!, components.month!, components.day!, components.hour!)
    }
    
    private static func mmt_modelLang() -> String
    {
        return Bundle(for: MMTForecastStore.self).preferredLocalizations.first ?? "en"
    }
}
