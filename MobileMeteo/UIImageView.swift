//
//  UIImageView.swift
//  MobileMeteo
//
//  Created by Kamil Szostakowski on 26.08.2015.
//  Copyright (c) 2015 Kamil Szostakowski. All rights reserved.
//

import UIKit
import Foundation

extension UIImageView
{
    func updateSizeConstraints(size: CGSize)
    {
        for constraint in self.constraints 
        {
            if constraint.firstAttribute == NSLayoutAttribute.Width {
                constraint.constant = size.width
            }
            
            if constraint.firstAttribute == NSLayoutAttribute.Height {
                constraint.constant = size.height
            }
        }
    }
}