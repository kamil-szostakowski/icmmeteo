//
//  MMTExtensionNSURLTests.swift
//  MobileMeteo
//
//  Created by Kamil Szostakowski on 19.08.2015.
//  Copyright (c) 2015 Kamil Szostakowski. All rights reserved.
//

import XCTest
import Foundation
import CoreLocation
@testable import MobileMeteo

class MMTCategoryNSURLTests: XCTestCase
{
    // MARK: Test methods
    
    func testBaseUrl()
    {
        XCTAssertEqual("http://www.meteo.pl", URL.mmt_baseUrl().absoluteString)
    }
    
    // MARK: Model um related tests
    
    func testModelUmDownloadBaseUrl()
    {
        XCTAssertEqual("http://www.meteo.pl/um/metco/mgram_pict.php", URL.mmt_modelUmDownloadBaseUrl().absoluteString);
    }
    
    func testModelUmSearchUrl()
    {
        let expectedUrl = "http://www.meteo.pl/um/php/mgram_search.php?NALL=53.585869&EALL=19.570815&lang=pl"
        let location = CLLocation(latitude: 53.585869, longitude: 19.570815)
        
        XCTAssertEqual(expectedUrl, URL.mmt_modelUmSearchUrl(location).absoluteString);
    }
    
    func testModelUmLegendUrl()
    {
        let expectedUrl = "http://www.meteo.pl/um/metco/leg_um_pl_cbase_256.png"
        XCTAssertEqual(expectedUrl, URL.mmt_modelUmLegendUrl().absoluteString);
    }
    
    func testModelUmForecastStartUrl()
    {
        let expectedUrl = "http://www.meteo.pl/info_um.php"
        XCTAssertEqual(expectedUrl, URL.mmt_modelUmForecastStartUrl().absoluteString);
    }
    
    func testModelUmDetailedMapUrl()
    {
        let date = TT.utcFormatter.date(from: "2016-08-22T12:00")!
        let url = {(map: MMTDetailedMap, plus: Int) in
            URL.mmt_modelUmDownloadUrlForMap(map, tZero:date, plus:plus)!.absoluteString
        }
        
        XCTAssertEqual("http://www.meteo.pl/um/pict/2016082212/SLPH_0000.0_0U_2016082212_003-00.png", url(.MeanSeaLevelPressure, 3))
        XCTAssertEqual("http://www.meteo.pl/um/pict/2016082212/T+WH_0000.0_0U_2016082212_036-00.png", url(.TemperatureAndStreamLine, 36))
        XCTAssertEqual("http://www.meteo.pl/um/pict/2016082212/GT_H_0000.0_0U_2016082212_033-00.png", url(.TemperatureOfSurface, 33))
        XCTAssertEqual("http://www.meteo.pl/um/pict/2016082212/RS_H_0000.0_0U_2016082212_006-00.png", url(.Precipitation, 6))
        XCTAssertEqual("http://www.meteo.pl/um/pict/2016082212/FLSH_0000.0_0U_2016082212_012-00.png", url(.Storm, 12))
        XCTAssertEqual("http://www.meteo.pl/um/pict/2016082212/W__H_0000.0_0U_2016082212_060-00.png", url(.Wind, 60))
        
        XCTAssertEqual("http://www.meteo.pl/um/pict/2016082212/WGSH_0000.0_0U_2016082212_001-00.png", url(.MaximumGust, 1))
        XCTAssertEqual("http://www.meteo.pl/um/pict/2016082212/VISH_0000.0_0U_2016082212_003-00.png", url(.Visibility, 3))
        XCTAssertEqual("http://www.meteo.pl/um/pict/2016082212/F__H_0000.0_0U_2016082212_015-00.png", url(.Fog, 15))
        
        XCTAssertEqual("http://www.meteo.pl/um/pict/2016082212/RHiH_0000.0_0U_2016082212_021-00.png", url(.RelativeHumidityAboveIce, 21))
        XCTAssertEqual("http://www.meteo.pl/um/pict/2016082212/RHwH_0000.0_0U_2016082212_001-00.png", url(.RelativeHumidityAboveWater, 1))
        
        XCTAssertEqual("http://www.meteo.pl/um/pict/2016082212/CV_H_0000.0_0U_2016082212_004-00.png", url(.VeryLowClouds, 4))
        XCTAssertEqual("http://www.meteo.pl/um/pict/2016082212/CL_H_0000.0_0U_2016082212_054-00.png", url(.LowClouds, 54))
        XCTAssertEqual("http://www.meteo.pl/um/pict/2016082212/CM_H_0000.0_0U_2016082212_048-00.png", url(.MediumClouds, 48))
        XCTAssertEqual("http://www.meteo.pl/um/pict/2016082212/CH_H_0000.0_0U_2016082212_005-00.png", url(.HighClouds, 5))
        XCTAssertEqual("http://www.meteo.pl/um/pict/2016082212/CT_H_0000.0_0U_2016082212_006-00.png", url(.TotalCloudiness, 6))
    }
    
    func testModelUmDetailedMapUrlForUnsupportedMap()
    {
        let date = TT.utcFormatter.date(from: "2016-08-22T12:00")!
        
        XCTAssertNil(URL.mmt_modelUmDownloadUrlForMap(.RelativeHumidity, tZero:date, plus:1))
    }
    
    // MARK: Model coamps related tests
    
    func testModelCoampsDownloadBaseUrl()
    {        
        XCTAssertEqual("http://www.meteo.pl/metco/mgram_pict.php", URL.mmt_modelCoampsDownloadBaseUrl().absoluteString);
    }
    
    func testModelCoampsSearchUrl()
    {
        let expectedUrl = "http://www.meteo.pl/php/mgram_search.php?NALL=53.585869&EALL=19.570815&lang=pl"
        let location = CLLocation(latitude: 53.585869, longitude: 19.570815)
        
        XCTAssertEqual(expectedUrl, URL.mmt_modelCoampsSearchUrl(location).absoluteString);
    }
    
    func testModelCoampsLegendUrl()
    {
        let expectedUrl = "http://www.meteo.pl/metco/leg4_pl.png"
        XCTAssertEqual(expectedUrl, URL.mmt_modelCoampsLegendUrl().absoluteString);
    }
    
    func testModelCoampsForecastStartUrl()
    {
        let expectedUrl = "http://www.meteo.pl/info_coamps.php"
        XCTAssertEqual(expectedUrl, URL.mmt_modelCoampsForecastStartUrl().absoluteString);
    }
    
    func testModelCoampsDetailedMapUrl()
    {
        let date = TT.utcFormatter.date(from: "2016-09-02T12:00")!
        let url = {(map: MMTDetailedMap, plus: Int) in
            URL.mmt_modelCoampsDownloadUrlForMap(map, tZero:date, plus:plus)!.absoluteString
        }
        
        XCTAssertEqual("http://www.meteo.pl/pict/2016090212/SLPH_0000.0_2X_2016090212_003-00.png", url(.MeanSeaLevelPressure, 3))
        XCTAssertEqual("http://www.meteo.pl/pict/2016090212/T+WH_0010.0_2X_2016090212_036-00.png", url(.TemperatureAndStreamLine, 36))
        XCTAssertEqual("http://www.meteo.pl/pict/2016090212/GT_H_0000.0_2X_2016090212_033-00.png", url(.TemperatureOfSurface, 33))
        XCTAssertEqual("http://www.meteo.pl/pict/2016090212/TRSH_0000.0_2X_2016090212_006-00.png", url(.Precipitation, 6))
        XCTAssertEqual("http://www.meteo.pl/pict/2016090212/W__H_0010.0_2X_2016090212_012-00.png", url(.Wind, 12))
        XCTAssertEqual("http://www.meteo.pl/pict/2016090212/VISH_0000.0_2X_2016090212_060-00.png", url(.Visibility, 60))
        XCTAssertEqual("http://www.meteo.pl/pict/2016090212/RH_H_0002.0_2X_2016090212_001-00.png", url(.RelativeHumidity, 1))
        XCTAssertEqual("http://www.meteo.pl/pict/2016090212/CLCS_L_2X_2016090212_010-00.png" , url(.LowClouds, 10))
        XCTAssertEqual("http://www.meteo.pl/pict/2016090212/CLCS_M_2X_2016090212_050-00.png", url(.MediumClouds, 50))
        XCTAssertEqual("http://www.meteo.pl/pict/2016090212/CLCS_H_2X_2016090212_000-00.png", url(.HighClouds, 0))
        XCTAssertEqual("http://www.meteo.pl/pict/2016090212/CLCS_T_2X_2016090212_003-00.png", url(.TotalCloudiness, 3))
    }
    
    func testModelCoampsDetailedMapUrlForUnsupportedMap()
    {
        let date = TT.utcFormatter.date(from: "2016-08-22T12:00")!
        
        XCTAssertNil(URL.mmt_modelCoampsDownloadUrlForMap(.VeryLowClouds, tZero:date, plus:1))
    }
    
    // MARK: Model wam related tests
    
    func testModelWamTideHeightThumbnailUrl()
    {
        let expectedUrl = "http://www.meteo.pl/wamcoamps/pict/2015081900/small-crop-wavehgt_0W_2015081900_006-00.gif"
        let date = TT.utcFormatter.date(from: "2015-08-19T00:00")!
        
        XCTAssertEqual(expectedUrl, URL.mmt_modelWamTideHeightThumbnailUrl(date, plus: 6).absoluteString)
    }
    
    func testModelWamAvgTidePeriodThumbnailUrl()
    {
        let expectedUrl = "http://www.meteo.pl/wamcoamps/pict/2015081900/small-crop-m_period_0W_2015081900_003-00.gif"
        let date = TT.utcFormatter.date(from: "2015-08-19T00:00")!
        
        XCTAssertEqual(expectedUrl, URL.mmt_modelWamAvgTidePeriodThumbnailUrl(date, plus: 3).absoluteString)
    }
    
    func testModelWamSpectrumPeakPeriodThumbnailUrl()
    {
        let expectedUrl = "http://www.meteo.pl/wamcoamps/pict/2015081900/small-crop-p_period_0W_2015081900_003-00.gif"
        let date = TT.utcFormatter.date(from: "2015-08-19T00:00")!
        
        XCTAssertEqual(expectedUrl, URL.mmt_modelWamSpectrumPeakPeriodThumbnailUrl(date, plus: 3).absoluteString)
    }
    
    func testModelWamTideHeightDownloadUrl()
    {
        let expectedUrl = "http://www.meteo.pl/wamcoamps/pict/2015081900/wavehgt_0W_2015081900_003-00.png"
        let date = TT.utcFormatter.date(from: "2015-08-19T00:00")!
        
        XCTAssertEqual(expectedUrl, URL.mmt_modelWamTideHeightDownloadUrl(date, plus: 3).absoluteString)
    }
    
    func testModelWamAvgTidePeriodDownloadUrl()
    {
        let expectedUrl = "http://www.meteo.pl/wamcoamps/pict/2015081900/m_period_0W_2015081900_006-00.png"
        let date = TT.utcFormatter.date(from: "2015-08-19T00:00")!
        
        XCTAssertEqual(expectedUrl, URL.mmt_modelWamAvgTidePeriodDownloadUrl(date, plus: 6).absoluteString)
    }
    
    func testModelWamSpectrumPeakPeriodDownloadUrl()
    {
        let expectedUrl = "http://www.meteo.pl/wamcoamps/pict/2015081900/p_period_0W_2015081900_003-00.png"
        let date = TT.utcFormatter.date(from: "2015-08-19T00:00")!
        
        XCTAssertEqual(expectedUrl, URL.mmt_modelWamSpectrumPeakPeriodDownloadUrl(date, plus: 3).absoluteString)
    }
    
    func testModelWamForecastStartUrl()
    {
        let expectedUrl = "http://www.meteo.pl/info_wamcoamps.php"
        XCTAssertEqual(expectedUrl, URL.mmt_modelWamForecastStartUrl().absoluteString);
    }
}
