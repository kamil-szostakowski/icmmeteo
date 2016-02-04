//
//  MMTMeteorogramUrlSessionTests.swift
//  MobileMeteo
//
//  Created by Kamil Szostakowski on 04.02.2016.
//  Copyright © 2016 Kamil Szostakowski. All rights reserved.
//

import XCTest
import Foundation
@testable import MobileMeteo

class MMTMeteorogramUrlSessionTests: XCTestCase
{
    var session: MMTMeteorogramUrlSession!
    
    var validContent: String {
        return contentWithDateString("2016.02.04 00:00 UTC")
    }
    
    var invalidContent: String {
        return contentWithDateString("201.02.04 00:00 UT")
    }
    
    // MARK: Setup methods
    
    override func setUp()
    {
        super.setUp()
        session = MMTMeteorogramUrlSession()
    }
    
    override func tearDown()
    {
        session = nil
        super.tearDown()
    }
    
    // MARK: Test methods

    func testEmptyContentParseWithValidEncoding()
    {
        XCTAssertNil(session.htmlStringFromResponseData(nil))
    }
    
    func testContentParseWithValidEncoding()
    {
        let data = validContent.dataUsingEncoding(NSWindowsCP1250StringEncoding)!
        XCTAssertEqual(validContent, session.htmlStringFromResponseData(data))
    }
    
    func testContentParseWithInvalidEncoding()
    {
        let data = validContent.dataUsingEncoding(NSUTF8StringEncoding)!        
        XCTAssertNil(session.htmlStringFromResponseData(data))
    }
    
    func testFindingOfForecastStartDateForEmptyInput()
    {
        XCTAssertNil(session.forecastStartDateFromHtmlResponse(""))
    }
    
    func testFindingOfForecastStartDateForValidInput()
    {
        let expectedDate = TT.getDate(2016, 2, 4, 0)
        let date = session.forecastStartDateFromHtmlResponse(validContent)

        XCTAssertEqual(expectedDate, date)
    }
    
    func testFindingOfForecastStartDateForInalidInput()
    {
        XCTAssertNil(session.forecastStartDateFromHtmlResponse(invalidContent))
    }
    
    // MARK: Helper methods
    
    private func contentWithDateString(dateString: String) -> String
    {
        return "<div style=\"position: absolute; left: 0px; top: 0px; padding: 0px; margin: 0px; width: 100%; height: 80px; background-color:  #edc389;\"><div class=\"info_model\" id=\"info_coamps\"><table border=0 cellspacing=5 cellpadding=5><tr valign=middle><td><font style='color:#8d6329; font-size: 32px; font-weight: 700'>MODEL UM</font></td><td><font style='color: #7d5319;'>Siatka: 4km. Długość prognozy 60h. </font><br><font class='start_data'>start prognozy t<sub>0</sub> : \(dateString)</font></td><td onMouseOver=\"this.style.cursor='pointer';\" onClick=\"loadModel(0,1)\"><div style=\"background-color: #ddb379; border: 1px solid #ad8349\"><table border=0 cellspacing=0 cellpadding=0><tr><td><img src=\"/web_pict/refresh-32.png\" style=\"margin: 4px\"></td><td style='font-family: Arial; font-size: 9px; font-weight: 700; color:#444; padding: 5px'>załaduj<br>najnowszą prognozę</td></tr></table></div></td></tr></table></div><div style=\"position: absolute; left 0px; bottom: 0px; padding: 0px; margin: 0px; width: 100%;  border: 1px solid #cda369; border-left: 0px; border-right: 0px; background-color: #ddb379\"><font style='color: #ffffff; font-weight: 700;'><A class=\"navi_um\"></A><A class=\"navi_um\" href=\"javascript:loadDIV('meteorogram_um','kon_3c_b',0);\">METEOROGRAMY</A> | <A class=\"navi_um\" href=\"javascript:loadDIV('szczegolowe_um','kon_3c_b',0);\">MAPY SZCZEGÓŁOWE</A></div></div>"
    }
}