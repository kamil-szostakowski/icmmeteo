//
//  MMTSearchInputFilterTests.swift
//  MobileMeteo
//
//  Created by Kamil Szostakowski on 09.09.2015.
//  Copyright (c) 2015 Kamil Szostakowski. All rights reserved.
//

import XCTest
import Foundation
@testable import MobileMeteo

class MMTSearchInputFilterTests: XCTestCase
{
    func testTooShortInput()
    {
        XCTAssertFalse(MMTSearchInput("aa ").isValid)
        XCTAssertFalse(MMTSearchInput("ab").isValid)
        XCTAssertFalse(MMTSearchInput("a").isValid)
        XCTAssertFalse(MMTSearchInput("").isValid)
    }
    
    func testValidInputs()
    {
        XCTAssertTrue(MMTSearchInput("aba").isValid)
        XCTAssertTrue(MMTSearchInput("bbb ").isValid)
        XCTAssertTrue(MMTSearchInput("lorem ipsum").isValid)
    }
    
    func testEmptyString()
    {
        XCTAssertEqual("", MMTSearchInput("   ").stringValue)
    }
    
    func testInputWithMultipleWhitespaces()
    {
        XCTAssertEqual("aaa bbb ccc", MMTSearchInput("aaa   bbb  ccc").stringValue)
    }
    
    func testInputWithLeadingWhitespaces()
    {
        XCTAssertEqual("aaa ccc", MMTSearchInput("     aaa ccc").stringValue)
    }
    
    func testInputWithTrailingWhitespaces()
    {
        XCTAssertEqual("aaa ccc ", MMTSearchInput("aaa ccc   ").stringValue)
    }
}
