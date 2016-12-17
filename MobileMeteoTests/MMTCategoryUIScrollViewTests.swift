//
//  MMTCategoryUIScrollViewTests.swift
//  MobileMeteo
//
//  Created by Kamil Szostakowski on 25.11.2015.
//  Copyright © 2015 Kamil Szostakowski. All rights reserved.
//

import XCTest
import UIKit
import Foundation
@testable import MobileMeteo

class MMTCategoryUIScrollViewTests: XCTestCase
{
    var scrollView: UIScrollView!
    
    // MARK: Setup methods
    
    override func setUp()
    {
        super.setUp()
        
        scrollView = UIScrollView(frame: CGRect(x: 0, y: 0, width: 320, height: 480))
        scrollView.contentSize = CGSize(width: 540, height: 660)
    }
    
    override func tearDown()
    {
        super.tearDown()
        scrollView = nil
    }
    
    // MARK: Test methods
    
    func testZoomScaleFittingWidth()
    {
        var
        scale = scrollView.zoomScaleFittingWidth(for: CGSize(width: 540, height: 660))
        scale = round(scale*1000)/1000
        
        XCTAssertEqual(0.593, scale)
    }
    
    func testZoomScaleFittingHeight()
    {
        var
        scale = scrollView.zoomScaleFittingHeight(for: CGSize(width: 540, height: 660))
        scale = round(scale*1000)/1000
    
        XCTAssertEqual(0.727, scale)
    }
}
