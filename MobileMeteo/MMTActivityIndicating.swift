//
//  MMTActivityIndicating.swift
//  MobileMeteo
//
//  Created by szostakowskik on 27.02.2018.
//  Copyright © 2018 Kamil Szostakowski. All rights reserved.
//

import UIKit
import Foundation

protocol MMTActivityIndicating: AnyObject
{
    var activityIndicator: MMTActivityIndicator! { get set }
    
    func displayActivityIndicator(in view: UIView, message: String?)
    
    func hideActivityIndicator()
}

extension MMTActivityIndicating
{
    func displayActivityIndicator(in view: UIView, message: String?)
    {
        guard activityIndicator == nil else {
            return
        }
        
        activityIndicator = MMTActivityIndicator(frame: .zero)
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.message = message
        
        view.addCenteredSubview(view: activityIndicator)
    }
    
    func hideActivityIndicator()
    {
        guard activityIndicator != nil else {
            return
        }
        
        activityIndicator.removeFromSuperview()
        activityIndicator = nil
    }
}
