//
//  MMTModelController.swift
//  MeteoModel
//
//  Created by szostakowskik on 08.06.2018.
//  Copyright © 2018 Kamil Szostakowski. All rights reserved.
//

import Foundation

public protocol MMTModelControllerDelegate : AnyObject
{
    func onModelUpdate(_ controller: MMTModelController)
}

public class MMTModelController
{
    public weak var delegate: MMTModelControllerDelegate?
    
    public func activate()
    {
    }
    
    public func deactivate()
    {        
    }
}
