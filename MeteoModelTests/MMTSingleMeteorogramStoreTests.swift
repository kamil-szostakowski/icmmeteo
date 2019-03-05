//
//  MMTPredictionCache.swift
//  MeteoModelTests
//
//  Created by szostakowskik on 20/02/2019.
//  Copyright © 2019 Kamil Szostakowski. All rights reserved.
//

import XCTest
import CoreLocation
@testable import MeteoModel

class MMTSingleMeteorogramStoreTests: XCTestCase
{
    // MARK: Properties
    var meteorogramCache: MMTSingleMeteorogramStore!
    var appGroup = UserDefaults(suiteName: "group.com.szostakowski.meteo")!
    let meteorogramImage = UIImage(thisBundle: "2018092900-381-199-full")
    let expectedDate = Date.from(2019, 3, 20, 10, 15, 20)

    // MARK: Setup methods
    override func setUp()
    {
        super.setUp()
        meteorogramCache = MMTSingleMeteorogramStore(MMTTestTools.cachesUrl.appendingPathComponent("meteorogram.png"))
        
        var
        meteorogram = MMTMeteorogram.loremCity
        meteorogram.image = meteorogramImage
        meteorogramCache.store(meteorogram)
    }
    
    // MARK: Test methods
    func testStoringPrediction()
    {
        let interval = expectedDate.timeIntervalSince1970
        
        XCTAssertEqual(self.appGroup.object(forKey: "city-name") as? String, "Lorem")
        XCTAssertEqual(self.appGroup.object(forKey: "city-region") as? String, "xyz")
        XCTAssertEqual(self.appGroup.object(forKey: "city-lat") as? Double, 1.0)
        XCTAssertEqual(self.appGroup.object(forKey: "city-lng") as? Double, 2.0)
        XCTAssertEqual(self.appGroup.object(forKey: "met-start-date") as? Double, interval)
        XCTAssertEqual(self.appGroup.object(forKey: "met-prediction") as? Int, 9)
        XCTAssertEqual(self.appGroup.object(forKey: "met-model") as? String, "UM")
    }
    
    func testRestoreMeteorogram()
    {
        let meteorogram = meteorogramCache.restore()
        
        XCTAssertEqual(meteorogram?.city.name, "Lorem")
        XCTAssertEqual(meteorogram?.city.region, "xyz")
        XCTAssertEqual(meteorogram?.city.location.coordinate.latitude, 1.0)
        XCTAssertEqual(meteorogram?.city.location.coordinate.longitude, 2.0)
        XCTAssertEqual(meteorogram?.model.type.rawValue, "UM")
        XCTAssertEqual(meteorogram?.startDate, self.expectedDate)
        XCTAssertEqual(meteorogram?.prediction?.rawValue, 9)
        XCTAssertEqual(meteorogram?.image.pngData(), meteorogramImage.pngData())
    }
    
    func testCleanupCache()
    {
        meteorogramCache.cleanup()
        _ = meteorogramCache.restore()
        
        XCTAssertTrue(meteorogramCache.isEmpty)
    }
    
    func testIsNotEmpty()
    {
        XCTAssertFalse(meteorogramCache.isEmpty)
    }
}
