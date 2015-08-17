//
//  UIScrollView.swift
//  MobileMeteo
//
//  Created by Kamil Szostakowski on 17.08.2015.
//  Copyright (c) 2015 Kamil Szostakowski. All rights reserved.
//

import UIKit
import Foundation

public extension UIScrollView
{
    public func adjustContentOffsetForHeaderOfHeight(height: CGFloat)
    {
        let animations = { () -> Void in
            self.contentOffset.y = self.contentOffset.y >= height/2 ? height : 0
            self.layoutIfNeeded()
        }
            
        UIView.animateWithDuration(0.2, delay: 0, usingSpringWithDamping: 0.9, initialSpringVelocity: 5, options: nil, animations: animations, completion: nil)
    }
}