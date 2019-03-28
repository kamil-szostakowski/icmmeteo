//
//  UIView.swift
//  MobileMeteo
//
//  Created by Kamil Szostakowski on 19/12/16.
//  Copyright © 2016 Kamil Szostakowski. All rights reserved.
//

import UIKit
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
    
    func loadFromNib() -> UIView
    {
        let nibName = String(describing: type(of: self))
        let bundle = Bundle(for: type(of: self))
        
        let
        view = bundle.loadNibNamed(nibName, owner: self, options: nil)?.first as! UIView
        view.translatesAutoresizingMaskIntoConstraints = false
        
        return view
    }
    
    func addFillingSubview(_ subview: UIView, _ insets: UIEdgeInsets = .zero)
    {
        addSubview(subview)
        
        NSLayoutConstraint.activate([
            subview.topAnchor.constraint(equalTo: topAnchor, constant: insets.top),
            subview.bottomAnchor.constraint(equalTo: bottomAnchor, constant: insets.bottom),
            subview.leadingAnchor.constraint(equalTo: leadingAnchor, constant: insets.left),
            subview.trailingAnchor.constraint(equalTo: trailingAnchor, constant: insets.right),
        ])
    }
}
