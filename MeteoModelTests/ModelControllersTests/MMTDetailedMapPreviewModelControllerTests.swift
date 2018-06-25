//
//  MMTDetailedMapPreviewModelControllerTests.swift
//  MeteoModelTests
//
//  Created by szostakowskik on 15.06.2018.
//  Copyright © 2018 Kamil Szostakowski. All rights reserved.
//

import XCTest
@testable import MeteoModel

class MMTDetailedMapPreviewModelControllerTests: XCTestCase
{
    // MARK: Properties
    var modelController: MMTDetailedMapPreviewModelController!
    var modelControllerDelegate: MMTMockModelControllerDelegate<MMTDetailedMapPreviewModelController>!
    var meteorogramStore: MMTMockMeteorogramStore!
    var detailedMap: MMTDetailedMap!
    var mapMeteorogram: MMTMapMeteorogram!
    
    // MARK: Setup methods
    override func setUp()
    {
        super.setUp()
        detailedMap = MMTUmClimateModel().detailedMaps.first!
        
        mapMeteorogram = MMTMapMeteorogram(model: detailedMap.climateModel)
        mapMeteorogram.images = [UIImage(), UIImage(), UIImage(), UIImage()]
        mapMeteorogram.moments = [
            Date(timeIntervalSince1970: 10),
            Date(timeIntervalSince1970: 20),
            Date(timeIntervalSince1970: 30),
            Date(timeIntervalSince1970: 40)
        ]
        mapMeteorogram.images.forEach {
            let index = mapMeteorogram.images.index(of: $0)
            $0?.accessibilityIdentifier = String(format: "%d", arguments: [index!])
        }
        
        meteorogramStore = MMTMockMeteorogramStore()
        meteorogramStore.mapMeteorogram = .success(mapMeteorogram)
        
        modelControllerDelegate = MMTMockModelControllerDelegate<MMTDetailedMapPreviewModelController>()
        modelController = MMTDetailedMapPreviewModelController(map: detailedMap, dataStore: meteorogramStore)
        modelController.delegate = modelControllerDelegate
    }
    
    // MARK: Test methods
    func testInitialization()
    {
        XCTAssertNil(modelController.error)
        XCTAssertNil(modelController.moment)
        XCTAssertNil(modelController.momentImage)
        XCTAssertFalse(modelController.requestPending)
        XCTAssertEqual(modelController.momentsCount, 0)
        XCTAssertEqual(modelController.map.type, detailedMap.type)
    }
    
    func testFetchMeteorogram()
    {        
        let expectations = modelControllerDelegate.awaitModelUpdate(completions: [{
            XCTAssertTrue($0.requestPending)
        },{
            XCTAssertFalse($0.requestPending)
            XCTAssertEqual($0.momentImage?.accessibilityIdentifier, "0")
            XCTAssertEqual($0.moment, Date(timeIntervalSince1970: 10))
            XCTAssertNil($0.error)
        }])
        
        modelController.activate()
        wait(for: expectations, timeout: 2)
    }
    
    func testFetchMeteorogramFailure()
    {
        meteorogramStore.mapMeteorogram = .failure(.meteorogramFetchFailure)
        
        let expectations = modelControllerDelegate.awaitModelUpdate(completions: [{
            XCTAssertTrue($0.requestPending)
        },{
            XCTAssertFalse($0.requestPending)
            XCTAssertNil($0.momentImage)
            XCTAssertNil($0.moment)
            XCTAssertEqual($0.error, .meteorogramFetchFailure)
        }])
        
        modelController.activate()
        wait(for: expectations, timeout: 2)
    }
    
    func testFetchMeteorogramWithSingleRetry()
    {
        mapMeteorogram.images[0] = nil
        meteorogramStore.mapMeteorogram = .success(mapMeteorogram)
        
        let expectations = modelControllerDelegate.awaitModelUpdate(completions: [{
            // Request failre
            XCTAssertTrue($0.requestPending)
            XCTAssertNil($0.error)
            
            self.mapMeteorogram.images[0] = nil
            self.meteorogramStore.mapMeteorogram = .success(self.mapMeteorogram)
        },{
            // Retry
            XCTAssertTrue($0.requestPending)
            XCTAssertNil($0.error)
            self.mapMeteorogram.images[0] = UIImage()
            self.mapMeteorogram.images[0]?.accessibilityIdentifier = "0"
            self.meteorogramStore.mapMeteorogram = .success(self.mapMeteorogram)
        },{
            // Request success
            XCTAssertFalse($0.requestPending)
            XCTAssertEqual($0.momentImage?.accessibilityIdentifier, "0")
            XCTAssertEqual($0.moment, Date(timeIntervalSince1970: 10))
            XCTAssertNil($0.error)
        }])
        
        modelController.activate()
        wait(for: expectations, timeout: 2)
    }
    
    func testFetchMeteorogramFailureWhenRetryCountExceeded()
    {
        mapMeteorogram.images[0] = nil
        meteorogramStore.mapMeteorogram = .success(mapMeteorogram)
        
        let expectations = modelControllerDelegate.awaitModelUpdate(completions: [{
            // Request failure
            XCTAssertTrue($0.requestPending)
            XCTAssertNil($0.error)
            self.mapMeteorogram.images[0] = nil
            self.meteorogramStore.mapMeteorogram = .success(self.mapMeteorogram)
        },{
            // Retry
            XCTAssertTrue($0.requestPending)
            XCTAssertNil($0.error)
        },{
            // Retry
            XCTAssertTrue($0.requestPending)
            XCTAssertNil($0.error)
        },{
            // Request error
            XCTAssertFalse($0.requestPending)
            XCTAssertNil($0.momentImage)
            XCTAssertNil($0.moment)
            XCTAssertEqual($0.error, .meteorogramFetchFailure)
        }])
        
        modelController.activate()
        wait(for: expectations, timeout: 2)
    }
    
    func testRetryFetchMeteorogramWhenMomentNotFound()
    {
        mapMeteorogram.images[2] = nil
        meteorogramStore.mapMeteorogram = .success(mapMeteorogram)
        
        let expectations = modelControllerDelegate.awaitModelUpdate(completions: [{
            XCTAssertTrue($0.requestPending)
            XCTAssertNil($0.error)
            self.mapMeteorogram.images[2] = UIImage()
            self.meteorogramStore.mapMeteorogram = .success(self.mapMeteorogram)
        },{
            // Request success
            XCTAssertFalse($0.requestPending)
            XCTAssertEqual($0.momentImage?.accessibilityIdentifier, "0")
            XCTAssertEqual($0.moment, Date(timeIntervalSince1970: 10))
            XCTAssertNil($0.error)
        }])
        
        modelController.activate()
        wait(for: expectations, timeout: 2)
    }
    
    func testRequestNextMeteorogramMoment()
    {
        let expectations = modelControllerDelegate.awaitModelUpdate(completions: [{ _ in },{ _ in }])
        
        modelController.activate()
        wait(for: expectations, timeout: 2)
        
        modelControllerDelegate.updatesCount = 0
        XCTAssertEqual(modelController.momentImage?.accessibilityIdentifier, "0")
        XCTAssertEqual(modelController.moment, Date(timeIntervalSince1970: 10))
        
        modelController.onMomentDisplayRequest(index: 1)
        XCTAssertEqual(modelController.momentImage?.accessibilityIdentifier, "1")
        XCTAssertEqual(modelController.moment, Date(timeIntervalSince1970: 20))
        
        modelController.onMomentDisplayRequest(index: 2)
        XCTAssertEqual(modelController.momentImage?.accessibilityIdentifier, "2")
        XCTAssertEqual(modelController.moment, Date(timeIntervalSince1970: 30))
    }
}
