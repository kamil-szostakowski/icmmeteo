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
    func onModelUpdate()
}

public protocol MMTModelController
{
    var delegate: MMTModelControllerDelegate? { get set }
    
    func activate()
    
    func deactivate()
}
