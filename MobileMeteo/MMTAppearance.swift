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
    
    static var meteoGreenColor: UIColor
    {
        return UIColor(red: 16/255, green: 123/255, blue: 98/255, alpha: 1)
    }
    
    static var lightGrayBackgroundColor: UIColor
    {
        return UIColor(white: 0.95, alpha: 1)
    }
    
    static func fontWithSize(_ size: CGFloat) -> UIFont
    {
        return UIFont(name: "HelveticaNeue-Light", size: size)!
    }
    
    static func boldFontWithSize(_ size: CGFloat) -> UIFont
    {
        return UIFont(name: "HelveticaNeue-CondensedBold", size: size)!        
    }    
}
