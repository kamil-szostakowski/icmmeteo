//
//  MMTMeteorogramStore.swift
//  MobileMeteo
//
//  Created by Kamil Szostakowski on 08.07.2015.
//  Copyright (c) 2015 Kamil Szostakowski. All rights reserved.
//

import Foundation

class MMTMeteorogramStore: NSObject
{
    func getMeteorogramWithQuery(query: MMTMeteorogramQuery, completion: MMTFetchMeteorogramCompletion)
    {
        let delegate = MMTMeteorogramFetchDelegate(completion: completion)
        let request = NSURLRequest(URL: NSURL.mmt_meteorogramSearchUrlWithQuery(query))
        
        NSURLConnection(request: request, delegate: delegate)?.start()
    }
}