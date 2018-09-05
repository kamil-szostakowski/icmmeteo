//
//  MMTInfoModelControllerTests.swift
//  MeteoModelTests
//
//  Created by szostakowskik on 22.08.2018.
//  Copyright © 2018 Kamil Szostakowski. All rights reserved.
//

import XCTest
@testable import MeteoModel

class MMTInfoModelControllerTests: XCTestCase
{
    // MARK: Properties
    var modelController: MMTInfoModelController!
    let options = NSAttributedString.EnumerationOptions.Element()
    
    // MARK: Setup methods
    override func setUp()
    {
        super.setUp()
        modelController = MMTInfoModelController(font: UIFont.systemFont(ofSize: 15))
        modelController.activate()
    }

    // MARK: Test methods
    func testFeedbackFormProperties()
    {
        XCTAssertEqual(modelController.feedbackEmailTopic, "ICM Meteo, Feedback")
        XCTAssertEqual(modelController.feedbackEmailRecipient, "meteo.contact1@gmail.com")
    }
    
    func testCreditsUrls()
    {
        XCTAssertEqual(count(attribute: .link, in: modelController.weatherIconsCredit), 3)
        XCTAssertEqual(count(attribute: .link, in: modelController.qaSupportCredit), 1)
        XCTAssertEqual(count(attribute: .link, in: modelController.authorCredit), 3)
    }
    
    func testCreditsContent()
    {
        XCTAssertEqual(modelController.weatherIconsCredit.string, "The Weather is Nice Today / Laura Reen / CC BY-NC 3.0")
        XCTAssertEqual(modelController.qaSupportCredit.string, "Bartosz Świeżawski")
        XCTAssertEqual(modelController.authorCredit.string, "Kamil Szostakowski / GitHub / Stack Overflow")
    }
}

extension MMTInfoModelControllerTests
{
    // MARK: Helper methods
    func count(attribute: NSAttributedStringKey, in string: NSMutableAttributedString) -> Int
    {
        var urlCount: Int = 0
        string.enumerateAttributes(in: string.fullRange, options: options) { attributes, _, _ in
            if attributes[attribute] != nil {
                urlCount += 1
            }
        }
        return urlCount
    }
}
