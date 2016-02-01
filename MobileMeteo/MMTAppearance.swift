//
//  MMTAppearance.swift
//  MobileMeteo
//
//  Created by Kamil Szostakowski on 02.09.2015.
//  Copyright (c) 2015 Kamil Szostakowski. All rights reserved.
//

import UIKit
import Foundation

struct MMTAppearance
{
    static var textColor: UIColor
    {
        return UIColor(red: 0, green: 0.55, blue: 0.46, alpha: 1)
    }
    
    static var lightGrayBackgroundColor: UIColor
    {
        return UIColor(white: 0.95, alpha: 1)
    }
    
    static func fontWithSize(size: CGFloat) -> UIFont
    {
        return UIFont(name: "HelveticaNeue-Light", size: size)!
    }
    
    static func boldFontWithSize(size: CGFloat) -> UIFont
    {
        return UIFont(name: "HelveticaNeue-CondensedBold", size: size)!        
    }    
}