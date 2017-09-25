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
    var imageRenderingMode: UIImageRenderingMode {
        get { return image?.renderingMode ?? .automatic }
        set { image = image?.withRenderingMode(newValue) }
    }
    
    func updateSizeConstraints(_ size: CGSize)
    {
        for constraint in self.constraints 
        {
            if constraint.firstAttribute == NSLayoutAttribute.width {
                constraint.constant = size.width
            }
            
            if constraint.firstAttribute == NSLayoutAttribute.height {
                constraint.constant = size.height
            }
        }
    }
}
