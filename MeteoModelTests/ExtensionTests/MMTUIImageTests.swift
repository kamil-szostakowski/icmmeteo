//
//  MMTUIImageTests.swift
//  MeteoModelTests
//
//  Created by szostakowskik on 05.03.2018.
//  Copyright © 2018 Kamil Szostakowski. All rights reserved.
//

import XCTest
@testable import MeteoModel

class MMTUIImageTests: XCTestCase
{
    func testImageFromNil()
    {
        let imageData: Data? = nil
        
        XCTAssertNil(UIImage(nil))
        XCTAssertNil(UIImage(imageData))
    }
    
    func testImageFromValidData()
    {
        let data = UIImage.from(color: .red).pngData()
        XCTAssertNotNil(UIImage(data))
    }
    
    func testImageFromInvalidData()
    {
        let data = Data(base64Encoded: "lorem ipsum")
        XCTAssertNil(UIImage(data))
    }    
}
