//
//  MMTPredictingForecastServiceTests.swift
//  MeteoModelTests
//
//  Created by szostakowskik on 11/03/2019.
//  Copyright © 2019 Kamil Szostakowski. All rights reserved.
//

import XCTest
@testable import MeteoModel

class MMTPredictingForecastServiceTests: XCTestCase
{
    // MARK: Properties
    var meteorogram = MMTMeteorogram.loremCity
    var predictionModel: MMTMockPredictionModel?
    var forecastService = MMTMockForecastService()
    
    lazy var service: MMTPredictingForecastService! = {
        return MMTPredictingForecastService(forecastService, predictionModel)
    }()    

    // MARK: Test methods
    func testPassUpdateResult()
    {
        verifyStatus(.failed)
        verifyStatus(.noData)
        verifyStatus(.newData)
    }
    
    func testPassMeteorogram()
    {
        verifyMeteorogram(nil)
        
        meteorogram.prediction = .rain
        verifyMeteorogram(meteorogram) { XCTAssertEqual($0?.prediction, .rain) }
        
        meteorogram.prediction = nil
        verifyMeteorogram(meteorogram) { XCTAssertNil($0?.prediction) }
    }
    
    func testPrediction_NoExistingPrediction()
    {
        meteorogram.prediction = nil
        predictionModel = MMTMockPredictionModel(.snow)
        
        verifyMeteorogram(meteorogram) { XCTAssertEqual($0?.prediction, .snow) }
    }
    
    func testPrediction_DontOverwriteExistingPrediction()
    {
        predictionModel = MMTMockPredictionModel(.snow)
        verifyMeteorogram(meteorogram) { XCTAssertEqual($0?.prediction, self.meteorogram.prediction) }
    }
}

// MARK: Helper extension
extension MMTPredictingForecastServiceTests
{
    func verifyStatus(_ status: MMTUpdateResult)
    {
        let completionExpect = expectation(description: "Completion expectation")
        
        forecastService.status = status
        service.update(for: meteorogram.city) {
            completionExpect.fulfill()
            XCTAssertEqual($0, status)
        }
        
        wait(for: [completionExpect], timeout: 1)
    }
    
    func verifyMeteorogram(_ aMeteorogram: MMTMeteorogram?, _ completion: ((MMTMeteorogram?) -> Void)? = nil)
    {
        let completionExpect = expectation(description: "Completion expectation")
        
        forecastService.currentMeteorogram = aMeteorogram
        service.update(for: meteorogram.city) { _ in
            completionExpect.fulfill()
            XCTAssertEqual(self.service.currentMeteorogram, aMeteorogram)
            if completion != nil {
                completion!(self.service.currentMeteorogram)
            }
        }
        
        wait(for: [completionExpect], timeout: 1)
    }
}
