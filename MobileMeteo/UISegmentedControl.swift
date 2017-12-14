//
//  UISegmentedControl.swift
//  MobileMeteo
//
//  Created by szostakowskik on 14.12.2017.
//  Copyright © 2017 Kamil Szostakowski. All rights reserved.
//

import Foundation

extension UISegmentedControl
{
    var selectedModelType: MMTClimateModelType? {
        get {
            guard let title = titleForSegment(at: selectedSegmentIndex) else {
                return nil
            }
            return MMTClimateModelType(rawValue: title)
        }
        set {
            guard let selectedIndex = ((0..<numberOfSegments).first { titleForSegment(at: $0) == newValue?.rawValue }) else {
                return
            }
            selectedSegmentIndex = selectedIndex
        }
    }
}
