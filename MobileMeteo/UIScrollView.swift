//
//  UIScrollView.swift
//  MobileMeteo
//
//  Created by Kamil Szostakowski on 17.08.2015.
//  Copyright (c) 2015 Kamil Szostakowski. All rights reserved.
//

import UIKit
import Foundation

extension UIScrollView
{
    func adjustContentOffsetForHeaderOfHeight(height: CGFloat)
    {
        let animations = { () -> Void in
            self.contentOffset.y = self.contentOffset.y >= height/2 ? height : 0
            self.layoutIfNeeded()
        }
            
        UIView.animateWithDuration(0.2, delay: 0, usingSpringWithDamping: 0.9, initialSpringVelocity: 5, options: [], animations: animations, completion: nil)
    }
    
    func animatedZoomToScale(scale: CGFloat)
    {
        let animation = { () -> Void in
            
            self.zoomScale = scale
            self.contentOffset = CGPoint.zero
        }
        
        UIView.animateWithDuration(0.5, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 10, options: [], animations: animation, completion: nil)
    }
    
    func minZoomScaleForSize(size: CGSize) -> CGFloat
    {
        return self.bounds.width/size.width
    }
    
    func defaultZoomScale(size: CGSize) -> CGFloat
    {
        return self.bounds.height/size.height
    }
}