//
//  CAAnimation.swift
//  MobileMeteo
//
//  Created by Kamil Szostakowski on 08.01.2016.
//  Copyright © 2016 Kamil Szostakowski. All rights reserved.
//

import UIKit
import Foundation

extension CAAnimation
{
    class func defaultScaleAnimation() -> CAAnimation
    {
        let
        animation = CAKeyframeAnimation(keyPath: "transform.scale")
        animation.values = [1, 1.5, 1]
        animation.keyTimes = [0, 0.5, 1]
        animation.duration = 0.5
        
        return animation
    }
}