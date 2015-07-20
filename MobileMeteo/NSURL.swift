//
//  NSURL.swift
//  MobileMeteo
//
//  Created by Kamil Szostakowski on 30.06.2015.
//  Copyright (c) 2015 Kamil Szostakowski. All rights reserved.
//

import Foundation
import CoreLocation

public extension NSURL
{
    public static func mmt_baseUrl() -> NSURL
    {
        return NSURL(string: "http://www.meteo.pl")!;
    }
    
    public static func mmt_meteorogramDownloadBaseUrl(type: MMTModelType) -> NSURL
    {
        var downloadBaseUrl = "/metco/mgram_pict.php"
        
        if type == .UM {
            downloadBaseUrl = "/um" + downloadBaseUrl
        }
        
        return NSURL(string: downloadBaseUrl, relativeToURL: mmt_baseUrl())!
    }
    
    public static func mmt_meteorogramSearchUrlWithQuery(query: MMTMeteorogramQuery) -> NSURL
    {
        let lat = query.location.coordinate.latitude;
        let lng = query.location.coordinate.longitude;
        var searchComponent = "/php/mgram_search.php?NALL=\(lat)&EALL=\(lng)&lang=pl&fdate=\(query.date)"
        
        if query.type == .UM {
            searchComponent = "/um" + searchComponent
        }

        return NSURL(string: searchComponent, relativeToURL: mmt_baseUrl())!
    }
}