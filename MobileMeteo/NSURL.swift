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
    
    static func mmt_baseUrl() -> URL
    {
        return URL(string: "http://www.meteo.pl")!
    }
    
    // MARK: Model UM related methods
    

    
    static func mmt_modelUmSearchUrl(_ location: CLLocation) -> URL
    {
        let lat = location.coordinate.latitude
        let lng = location.coordinate.longitude
        
        return URL(string: "/um/php/mgram_search.php?NALL=\(lat)&EALL=\(lng)&lang=\(mmt_modelLang())", relativeTo: mmt_baseUrl())!
    }
    
    static func mmt_modelUmDownloadBaseUrl() -> URL
    {
        return URL(string: "/um/metco/mgram_pict.php", relativeTo: mmt_baseUrl())!
    }
    
    static func mmt_modelUmLegendUrl() -> URL
    {
        return URL(string: "/um/metco/leg_um_\(mmt_modelLang())_cbase_256.png", relativeTo: mmt_baseUrl())!
    }
    
    static func mmt_modelUmForecastStartUrl() -> URL
    {
        return URL(string: "info_um.php", relativeTo: mmt_baseUrl())!
    }
    
    static func mmt_modelUmDownloadUrlForMap(_ map: MMTDetailedMap, tZero: Date, plus: Int) -> URL?
    {
        let tZeroString = tZeroStringForDate(tZero)
        let tZeroPlus = NSString(format: "%03ld", plus)
        
        let prefixes: [MMTDetailedMap: String] = [
            .MeanSeaLevelPressure: "SLPH",
            .TemperatureAndStreamLine: "T+WH",
            .TemperatureOfSurface: "GT_H",
            .Precipitation: "RS_H",
            .Storm: "FLSH",
            .Wind: "W__H",
            .MaximumGust: "WGSH",
            .Visibility: "VISH",
            .Fog: "F__H",
            .RelativeHumidityAboveIce: "RHiH",
            .RelativeHumidityAboveWater: "RHwH",
            .VeryLowClouds: "CV_H",
            .LowClouds: "CL_H",
            .MediumClouds: "CM_H",
            .HighClouds: "CH_H",
            .TotalCloudiness: "CT_H"
        ]
        
        guard let prefix = prefixes[map] else {
            return nil
        }
        
        return URL(string: "um/pict/\(tZeroString)/\(prefix)_0000.0_0U_\(tZeroString)_\(tZeroPlus)-00.png", relativeTo: mmt_baseUrl())!
    }
    
    // MARK: Model COAMPS related methods
    
    static func mmt_modelCoampsSearchUrl(_ location: CLLocation) -> URL
    {
        let lat = location.coordinate.latitude
        let lng = location.coordinate.longitude
        
        return URL(string: "/php/mgram_search.php?NALL=\(lat)&EALL=\(lng)&lang=pl", relativeTo: mmt_baseUrl())!
    }
    
    static func mmt_modelCoampsDownloadBaseUrl() -> URL
    {
        return URL(string: "/metco/mgram_pict.php", relativeTo: mmt_baseUrl())!
    }
    
    static func mmt_modelCoampsLegendUrl() -> URL
    {
        return URL(string: "/metco/leg4_\(mmt_modelLang()).png", relativeTo: mmt_baseUrl())!
    }
    
    static func mmt_modelCoampsForecastStartUrl() -> URL
    {
        return URL(string: "info_coamps.php", relativeTo: mmt_baseUrl())!
    }
    
    static func mmt_modelCoampsDownloadUrlForMap(_ map: MMTDetailedMap, tZero: Date, plus: Int) -> URL?
    {
        let tZeroString = tZeroStringForDate(tZero)
        let tZeroPlus = NSString(format: "%03ld", plus)
        
        let prefixes: [MMTDetailedMap: String] = [
            .MeanSeaLevelPressure: "SLPH_0000.0",
            .TemperatureAndStreamLine: "T+WH_0010.0",
            .TemperatureOfSurface: "GT_H_0000.0",
            .Precipitation: "TRSH_0000.0",
            .Wind: "W__H_0010.0",
            .Visibility: "VISH_0000.0",
            .RelativeHumidity: "RH_H_0002.0",
            .LowClouds: "CLCS_L",
            .MediumClouds: "CLCS_M",
            .HighClouds: "CLCS_H",
            .TotalCloudiness: "CLCS_T"
        ]
        
        guard let prefix = prefixes[map] else {
            return nil
        }
        
        return URL(string: "/pict/\(tZeroString)/\(prefix)_2X_\(tZeroString)_\(tZeroPlus)-00.png", relativeTo: mmt_baseUrl())
    }
    
    // MARK: Model WAM related methods
    
    static func mmt_modelWamTideHeightThumbnailUrl(_ tZero: Date, plus: Int) -> URL
    {
        return mmt_modelWamThumbnailUrl("wavehgt", tZero: tZero, plus: plus)
    }
    
    static func mmt_modelWamAvgTidePeriodThumbnailUrl(_ tZero: Date, plus: Int) -> URL
    {
        return mmt_modelWamThumbnailUrl("m_period", tZero: tZero, plus: plus)
    }
    
    static func mmt_modelWamSpectrumPeakPeriodThumbnailUrl(_ tZero: Date, plus: Int) -> URL
    {
        return mmt_modelWamThumbnailUrl("p_period", tZero: tZero, plus: plus)
    }
    
    static func mmt_modelWamTideHeightDownloadUrl(_ tZero: Date, plus: Int) -> URL
    {
        return mmt_modelWamDownloadUrl("wavehgt", tZero: tZero, plus: plus)
    }
    
    static func mmt_modelWamAvgTidePeriodDownloadUrl(_ tZero: Date, plus: Int) -> URL
    {
        return mmt_modelWamDownloadUrl("m_period", tZero: tZero, plus: plus)
    }
    
    static func mmt_modelWamSpectrumPeakPeriodDownloadUrl(_ tZero: Date, plus: Int) -> URL
    {
        return mmt_modelWamDownloadUrl("p_period", tZero: tZero, plus: plus)
    }
    
    static func mmt_modelWamForecastStartUrl() -> URL
    {
        return URL(string: "info_wamcoamps.php", relativeTo: mmt_baseUrl())!
    }
    
    // MARK: Helper methods
    
    fileprivate static func mmt_modelWamDownloadUrl(_ infix: String, tZero: Date, plus: Int) -> URL
    {
        let tZeroString = tZeroStringForDate(tZero)
        let tZeroPlus = NSString(format: "%03ld", plus)
        
        return URL(string: "/wamcoamps/pict/\(tZeroString)/\(infix)_0W_\(tZeroString)_\(tZeroPlus)-00.png", relativeTo: mmt_baseUrl())!
    }
    
    fileprivate static func mmt_modelWamThumbnailUrl(_ infix: String, tZero: Date, plus: Int) -> URL
    {
        let tZeroString = tZeroStringForDate(tZero)
        let tZeroPlus = NSString(format: "%03ld", plus)
        
        return URL(string: "/wamcoamps/pict/\(tZeroString)/small-crop-\(infix)_0W_\(tZeroString)_\(tZeroPlus)-00.gif", relativeTo: mmt_baseUrl())!
    }
    
    fileprivate static func tZeroStringForDate(_ date: Date) -> String
    {
        let components = (Calendar.utcCalendar as NSCalendar).components([.year, .month, .day, .hour], from: date)
        
        return String(format: MMTFormat.TZero, components.year!, components.month!, components.day!, components.hour!)
    }
    
    fileprivate static func mmt_modelLang() -> String
    {
        return Bundle.main.preferredLocalizations.first ?? "en"
    }
}
