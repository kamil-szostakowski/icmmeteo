//
//  UIView.swift
//  MobileMeteo
//
//  Created by Kamil Szostakowski on 19/12/16.
//  Copyright © 2016 Kamil Szostakowski. All rights reserved.
//

import Foundation

extension UIView
{
    func addCenteredSubview(view: UIView)
    {
        addSubview(view)

        let horizontal = NSLayoutConstraint(item: view, attribute: .centerX, relatedBy: .equal, toItem: self, attribute: .centerX, multiplier: 1, constant: 0)

        let vartical = NSLayoutConstraint(item: view, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1, constant: 0)

        addConstraint(horizontal)
        addConstraint(vartical)
    }
}
