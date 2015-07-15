//
//  NSURL.swift
//  MobileMeteo
//
//  Created by Kamil Szostakowski on 30.06.2015.
//  Copyright (c) 2015 Kamil Szostakowski. All rights reserved.
//

import Foundation
import CoreLocation

extension NSURL
{
    public static func mmt_baseUrl() -> NSURL
    {
        return NSURL(string: "http://www.meteo.pl")!;
    }
    
    public static func mmt_meteorogramSearchUrlWithQuery(query: MMTMeteorogramQuery) -> NSURL
    {
        let lat = query.location.coordinate.latitude;
        let lng = query.location.coordinate.longitude;
        let searchComponent = "/um/php/mgram_search.php?NALL=\(lat)&EALL=\(lng)&lang=pl&fdate=\(query.date)"

        return NSURL(string: searchComponent, relativeToURL: mmt_baseUrl())!
    }
    
    public static func mmt_meteorogramDownloadBaseUrl() -> NSURL
    {
        return NSURL(string: "/um/metco/mgram_pict.php", relativeToURL: mmt_baseUrl())!
    }
}