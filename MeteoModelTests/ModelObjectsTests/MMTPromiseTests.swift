//
//  MMTPromiseTests.swift
//  MeteoModelTests
//
//  Created by szostakowskik on 27.07.2018.
//  Copyright © 2018 Kamil Szostakowski. All rights reserved.
//

import XCTest
@testable import MeteoModel

class MMTPromiseTests: XCTestCase
{
    // MARK: Test methods
    func testResolvePromise()
    {
        verifyResolvePromise(.success(1))
        verifyResolvePromise(.failure(.meteorogramNotFound))
        verifyResolvePromise(.success(1), resolveAfterRegistration: false)
    }
    
    func testResolvePromiseTwice()
    {
        let completion = expectation(description: "Completion expectation")
        let result: MMTResult<Int> = .success(1)
        let promise = MMTPromise<Int>()
        
        promise.observe {
            XCTAssertEqual($0, result)
            completion.fulfill()
        }
        
        promise.resolve(with: result)
        promise.resolve(with: result)
        
        wait(for: [completion], timeout: 0.5)
    }
}

extension MMTPromiseTests
{
    // MARK: Verify methods
    fileprivate func verifyResolvePromise(_ result: MMTResult<Int>, resolveAfterRegistration: Bool = true)
    {
        let completion = expectation(description: "Completion expectation")
        let promise = MMTPromise<Int>()
        
        if resolveAfterRegistration == false {
            promise.resolve(with: result)
        }
        
        promise.observe {
            XCTAssertEqual($0, result)
            completion.fulfill()
        }
        
        if resolveAfterRegistration {
            promise.resolve(with: result)
        }
        
        wait(for: [completion], timeout: 0.5)
    }
}
