//
//  MMTNSAttributedStringTests.swift
//  MeteoModelTests
//
//  Created by szostakowskik on 22.08.2018.
//  Copyright © 2018 Kamil Szostakowski. All rights reserved.
//

import XCTest
@testable import MeteoModel

class MMTNSAttributedStringTests: XCTestCase
{
    // MARK: Properties
    var string: NSMutableAttributedString!
    
    // MARK: Setup methods
    override func setUp()
    {
        super.setUp()
        string = NSMutableAttributedString(string: "Lorem ipsum dolor sit amet")
    }
    
    // MARK: Test methods
    func testFullRange()
    {
        XCTAssertEqual(string.fullRange.location, 0)
        XCTAssertEqual(string.fullRange.length, 26)
    }
    
    func testFullRangeForEmptyString()
    {
        let emptyString = NSMutableAttributedString()
        
        XCTAssertEqual(emptyString.fullRange.location, 0)
        XCTAssertEqual(emptyString.fullRange.length, 0)
    }
    
    func testAddAttributeForFullRange()
    {
        var range = NSRange(location: 0, length: 0)
        
        string.addAttribute(.foregroundColor, value: UIColor.red)
        
        XCTAssertNotNil(string.attribute(.foregroundColor, at: 0, effectiveRange: &range))
        XCTAssertEqual(range, NSRange(location: 0, length: 26))
    }
    
    func testSetUrlForSubstring()
    {
        var range = NSRange(location: 0, length: 0)
        string.set(url: "http://example.com", for: "ipsum")
        
        XCTAssertNotNil(string.attribute(.link, at: 6, effectiveRange: &range))
        XCTAssertEqual(range, NSRange(location: 6, length: 5))
    }
    
    func testSetUrlForNotExistingSubstring()
    {
        var range = NSRange(location: 0, length: 0)
        string.set(url: "http://example.com", for: "example")
        
        XCTAssertNil(string.attribute(.link, at: 0, effectiveRange: &range))
        XCTAssertEqual(range, NSRange(location: 0, length: 26))
    }
}
