//
//  MMTForecasterCommentModelControllerTests.swift
//  MeteoModelTests
//
//  Created by szostakowskik on 15.06.2018.
//  Copyright © 2018 Kamil Szostakowski. All rights reserved.
//

import XCTest
@testable import MeteoModel

class MMTForecasterCommentModelControllerTests: XCTestCase
{
    // MARK: Properties
    var dataStore: MMTMockForecasterStore!
    var modelController: MMTForecasterCommentModelController!
    var modelControllerDelegate: MMTMockModelControllerDelegate<MMTForecasterCommentModelController>!
    
    // MARK: Setup methods
    override func setUp()
    {
        super.setUp()
        
        dataStore = MMTMockForecasterStore()
        modelControllerDelegate = MMTMockModelControllerDelegate<MMTForecasterCommentModelController>()
        modelController = MMTForecasterCommentModelController(dataStore: dataStore)
        modelController.delegate = modelControllerDelegate
    }
    
    // MARK: Test methods
    func testInitialization()
    {
        XCTAssertNil(modelController.comment)
        XCTAssertNil(modelController.error)
    }
    
    func testFetchForecasterComment()
    {
        dataStore.comment = .success(NSAttributedString(string: "Lorem ipsum"))
        
        let expectations = modelControllerDelegate.awaitModelUpdate(completions: [verifyPendingRequest, {
            XCTAssertFalse($0.requestPending)
            XCTAssertEqual($0.comment?.string, "Lorem ipsum")
            XCTAssertNil($0.error)
        }])
        
        modelController.activate()
        wait(for: expectations, timeout: 2)
    }
    
    func testFetchForecasterCommentWhenFailure()
    {
        dataStore.comment = .failure(.commentFetchFailure)
        
        let expectations = modelControllerDelegate.awaitModelUpdate(completions: [verifyPendingRequest, {
            XCTAssertEqual($0.error, .commentFetchFailure)
            XCTAssertFalse($0.requestPending)
            XCTAssertNil($0.comment)
        }])
        
        modelController.activate()
        wait(for: expectations, timeout: 2)
    }
    
    func testFetchForcasterCommentBeforeCacheExpired()
    {
        dataStore.comment = .success(NSAttributedString(string: "Lorem ipsum"))
        
        let expectations = modelControllerDelegate.awaitModelUpdate(completions: [verifyPendingRequest, {
            XCTAssertFalse($0.requestPending)
            XCTAssertEqual($0.comment?.string, "Lorem ipsum")
            XCTAssertNil($0.error)
        }])
        
        modelController.activate()
        wait(for: expectations, timeout: 2)
        modelController.activate()
    }
    
    // MARK: Helper methods
    func verifyPendingRequest(controller: MMTForecasterCommentModelController)
    {
        XCTAssertNil(controller.error)
        XCTAssertNil(controller.comment)
        XCTAssertTrue(controller.requestPending)
    }
}
