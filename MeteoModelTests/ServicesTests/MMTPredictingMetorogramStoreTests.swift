//
//  MMTPredictingForecastServiceTests.swift
//  MeteoModelTests
//
//  Created by szostakowskik on 11/03/2019.
//  Copyright © 2019 Kamil Szostakowski. All rights reserved.
//

import XCTest
@testable import MeteoModel

class MMTPredictingMetorogramStoreTests: XCTestCase
{
    // MARK: Properties
    var meteorogram = MMTMeteorogram.loremCity
    var mapMeteorogram = MMTMapMeteorogram(model: MMTUmClimateModel())
    var predictionModel: MMTMockPredictionModel?
    var meteorogramStore = MMTMockMeteorogramStore()
    
    lazy var store: MMTPredictingMetorogramStore! = {
        return MMTPredictingMetorogramStore(meteorogramStore, predictionModel)
    }()    

    // MARK: Test methods
    func testPassUpdateResult()
    {
        verifyResult(.success(meteorogram))
        verifyResult(.failure(.meteorogramFetchFailure))
        verifyResult(.failure(.meteorogramNotFound))
    }
    
    func testPassMapMeteorogram()
    {
        verifyMapResult(.success(mapMeteorogram))
        verifyMapResult(.failure(.meteorogramFetchFailure))
        verifyMapResult(.failure(.meteorogramNotFound))
    }
    
    func testPassMeteorogram()
    {
        meteorogram.prediction = .rain
        verifyResult(.success(meteorogram)) {
            XCTAssertEqual($0?.prediction, .rain)
        }

        meteorogram.prediction = nil
        verifyResult(.success(meteorogram)) {
            XCTAssertNil($0?.prediction)
        }
    }

    func testPrediction_NoExistingPrediction()
    {
        meteorogram.prediction = nil
        predictionModel = MMTMockPredictionModel(.snow)

        verifyResult(.success(meteorogram)) {
            XCTAssertEqual($0?.prediction, .snow)
        }
    }

    func testPrediction_DontOverwriteExistingPrediction()
    {
        predictionModel = MMTMockPredictionModel(.snow)
        verifyResult(.success(meteorogram)) {
            XCTAssertEqual($0?.prediction, self.meteorogram.prediction)
        }
    }
}

// MARK: Helper extension
extension MMTPredictingMetorogramStoreTests
{
    func verifyResult(_ result: MMTResult<MMTMeteorogram>, _ completion: ((MMTMeteorogram?) -> Void)? = nil)
    {
        let completionExpect = expectation(description: "Completion expectation")
        
        meteorogramStore.meteorogram = result
        store.meteorogram(for: meteorogram.city) {
            completionExpect.fulfill()
            XCTAssertEqual($0, result)
            
            if completion != nil {
                switch $0 {
                    case .success(let m): completion!(m)
                    case .failure(_): completion!(nil)
                }
            }
        }
        
        wait(for: [completionExpect], timeout: 1)
    }
    
    func verifyMapResult(_ result: MMTResult<MMTMapMeteorogram>)
    {
        let completionExpect = expectation(description: "Completion expectation")
        let detailedMap = MMTDetailedMap(MMTUmClimateModel(), .Fog, 0)
        
        meteorogramStore.mapMeteorogram = result
        store.meteorogram(for: detailedMap) {
            completionExpect.fulfill()
            XCTAssertEqual($0, result)
        }
        
        wait(for: [completionExpect], timeout: 1)
    }
}
