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
    var expectedResult = NSAttributedString(string: "Lorem ipsum").formattedAsComment()
    var emptyResult = NSMutableAttributedString()
    
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
        XCTAssertEqual(modelController.comment, .success(emptyResult))
    }
    
    func testFetchForecasterComment()
    {
        dataStore.comment = .success(expectedResult)
        
        let expectations = modelControllerDelegate.awaitModelUpdate(completions: [verifyPendingRequest, {
            XCTAssertFalse($0.requestPending)
            XCTAssertEqual($0.comment, self.dataStore.comment)
        }])
        
        modelController.activate()
        wait(for: expectations, timeout: 2)
    }
    
    func testFetchForecasterCommentWhenFailure()
    {
        dataStore.comment = .failure(.commentFetchFailure)
        
        let expectations = modelControllerDelegate.awaitModelUpdate(completions: [verifyPendingRequest, {
            XCTAssertEqual($0.comment, .failure(.commentFetchFailure))
            XCTAssertFalse($0.requestPending)
        }])
        
        modelController.activate()
        wait(for: expectations, timeout: 2)
    }
    
    func testFetchForecasterCommentSuccessAfterFailure()
    {
        modelController.comment = .failure(.commentFetchFailure)
        dataStore.comment = .success(expectedResult)
        
        let expectations = modelControllerDelegate.awaitModelUpdate(completions: [verifyPendingRequest, {
            XCTAssertFalse($0.requestPending)
            XCTAssertEqual($0.comment, self.dataStore.comment)
        }])
        
        modelController.activate()
        wait(for: expectations, timeout: 2)
    }
    
    /*
     * - Open the app.
     * - Go to the airplane mode.
     * - Got to the comment tab.
     * - Application should display an error.
     * - Leave the airplane mode
     * - Go to the comment tab again.
     * - Application should load and present comment.
     */
    func testFetchForecasterCommentFailureAfterSuccess()
    {
        modelController.comment = .success(expectedResult)
        dataStore.comment = .failure(.commentFetchFailure)
        
        let expectations = modelControllerDelegate.awaitModelUpdate(completions: [verifyPendingRequest, {
            XCTAssertFalse($0.requestPending)
            XCTAssertEqual($0.comment, self.dataStore.comment)
            }])
        
        modelController.activate()
        wait(for: expectations, timeout: 2)
    }
    
    func testFetchForcasterCommentBeforeCacheExpired()
    {
        dataStore.comment = .success(expectedResult)
        
        let expectations = modelControllerDelegate.awaitModelUpdate(completions: [verifyPendingRequest, {
            XCTAssertFalse($0.requestPending)
            XCTAssertEqual($0.comment, self.dataStore.comment)
        }])
        
        modelController.activate()
        wait(for: expectations, timeout: 2)
        modelController.activate()
    }
    
    /*
     * - Open the app.
     * - Go to the airplane mode.
     * - Got to the comment tab.
     * - Application should display an error.
     * - Leave the airplane mode
     * - Go to the comment tab again.
     * - Application should display activity indicator and no content underneath.
     */
    func testCommentValueDuringSecondFetch()
    {
        modelController.comment = .success(expectedResult)
        dataStore.comment = .success(expectedResult)
        
        let expectations = modelControllerDelegate.awaitModelUpdate(completions: [{
            XCTAssertTrue($0.requestPending)
            XCTAssertEqual($0.comment, .success(self.emptyResult))
        },{
            XCTAssertFalse($0.requestPending)
            XCTAssertEqual($0.comment, self.dataStore.comment)
        }])
        
        modelController.activate()
        wait(for: expectations, timeout: 2)
    }
    
    // MARK: Helper methods
    func verifyPendingRequest(controller: MMTForecasterCommentModelController)
    {
        XCTAssertTrue(controller.requestPending)
    }
}
