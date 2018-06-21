//
//  MMTImagesCache.swift
//  MeteoModel
//
//  Created by szostakowskik on 21.06.2018.
//  Copyright © 2018 Kamil Szostakowski. All rights reserved.
//

import UIKit
import Foundation

public class MMTImagesCache
{
    var cache: NSCache<NSString, UIImage>
    //var cache: NSMutableDictionary//<NSString, UIImage>
    
    init() {
        cache = NSCache<NSString, UIImage>()
        //cache = NSMutableDictionary()
    }
    
    func object(forKey: String) -> UIImage?
    {
        return cache.object(forKey: forKey as NSString)
    }
    
    func setObject(_ object: UIImage, forKey: String)
    {
        cache.setObject(object, forKey: forKey as NSString)
    }
    
    func removeAllObjects()
    {
        cache.removeAllObjects()
    }
}
