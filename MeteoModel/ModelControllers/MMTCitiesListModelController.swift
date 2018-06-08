//
//  MMTCitiesListModelController.swift
//  MeteoModel
//
//  Created by szostakowskik on 01.06.2018.
//  Copyright © 2018 Kamil Szostakowski. All rights reserved.
//

import Foundation

public protocol MMTModelControllerDelegate : AnyObject
{
    func onModelUpdate()
}

public class MMTCitiesListModelController
{
    // MARK: Properties
    private weak var delegate: MMTModelControllerDelegate?
    
    // MARK: Initializers
    public init(delegate: MMTModelControllerDelegate)
    {
        self.delegate = delegate
    }
    
    // MARK: Interface methods
    public func activate()
    {        
    }
    
    public func deactivate()
    {
    }
}
