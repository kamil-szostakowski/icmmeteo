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
    
    // MARK: Setup methods
    override func setUp()
    {
        super.setUp()
        detailedMap = MMTUmClimateModel().detailedMaps.first!
        
        meteorogramStore = MMTMockMeteorogramStore()
        meteorogramStore.mapMeteorogram = MMTMapMeteorogram(model: detailedMap.climateModel)
        meteorogramStore.mapMeteorogram?.images = [UIImage(), UIImage(), UIImage(), UIImage()]
        meteorogramStore.mapMeteorogram?.moments = [
            Date(timeIntervalSince1970: 10),
            Date(timeIntervalSince1970: 20),
            Date(timeIntervalSince1970: 30),
            Date(timeIntervalSince1970: 40)
        ]
        
        meteorogramStore.mapMeteorogram?.images.forEach {
            let index = meteorogramStore.mapMeteorogram?.images.index(of: $0)
            $0?.accessibilityIdentifier = String(format: "%d", arguments: [index!])
        }
        
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
        meteorogramStore.mapMeteorogram = nil
        meteorogramStore.error = .meteorogramFetchFailure
        
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
        self.meteorogramStore.mapMeteorogram?.images[0] = nil
        
        let expectations = modelControllerDelegate.awaitModelUpdate(completions: [{
            // Request failre
            XCTAssertTrue($0.requestPending)
            XCTAssertNil($0.error)
            self.meteorogramStore.mapMeteorogram?.images[0] = nil
        },{
            // Retry
            XCTAssertTrue($0.requestPending)
            XCTAssertNil($0.error)
            self.meteorogramStore.mapMeteorogram?.images[0] = UIImage()
            self.meteorogramStore.mapMeteorogram?.images[0]?.accessibilityIdentifier = "0"
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
        meteorogramStore.mapMeteorogram?.images[0] = nil
        
        let expectations = modelControllerDelegate.awaitModelUpdate(completions: [{
            // Request failure
            XCTAssertTrue($0.requestPending)
            XCTAssertNil($0.error)
            self.meteorogramStore.mapMeteorogram?.images[0] = nil
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
        meteorogramStore.mapMeteorogram?.images[2] = nil
        
        let expectations = modelControllerDelegate.awaitModelUpdate(completions: [{
            XCTAssertTrue($0.requestPending)
            XCTAssertNil($0.error)
            self.meteorogramStore.mapMeteorogram?.images[2] = UIImage()
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
