//
//  MMTResultTests.swift
//  MeteoModelTests
//
//  Created by szostakowskik on 31.07.2018.
//  Copyright © 2018 Kamil Szostakowski. All rights reserved.
//

import XCTest
@testable import MeteoModel

class MMTResultTests: XCTestCase
{
    // MARK: Test methods
    func testEqualityWhenSuccess()
    {
        let first = MMTResult<Int>.success(10)
        let second = MMTResult<Int>.success(10)
        
        XCTAssertEqual(first, second)
    }
    
    func testNonEqualityWhenSuccess()
    {
        let first = MMTResult<Int>.success(10)
        let second = MMTResult<Int>.success(20)
        
        XCTAssertNotEqual(first, second)
    }
    
    func testEqualityWhenFailure()
    {
        let first = MMTResult<Int>.failure(.commentFetchFailure)
        let second = MMTResult<Int>.failure(.commentFetchFailure)
        
        XCTAssertEqual(first, second)
    }
    
    func testNonEqualityWhenFailure()
    {
        let first = MMTResult<Int>.failure(.commentFetchFailure)
        let second = MMTResult<Int>.failure(.invalidMigrationChain)
        
        XCTAssertNotEqual(first, second)
    }    
}
