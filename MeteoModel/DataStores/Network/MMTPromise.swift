//
//  MMTPromise.swift
//  MeteoModel
//
//  Created by szostakowskik on 25.07.2018.
//  Copyright © 2018 Kamil Szostakowski. All rights reserved.
//

import Foundation

public class MMTPromise<T>
{
    // MARK: Properties
    private var callback: ((MMTResult<T>) -> Void)?
    
    private var result: MMTResult<T>? {
        didSet { result.map(report) }
    }
    
    // MARK: Initializers
    public init() {}
    
    // MARK: Methods
    public func observe(completion: @escaping (MMTResult<T>) -> Void)
    {
        callback = completion
        result.map(report)
    }
    
    public func resolve(with value: MMTResult<T>)
    {
        if result == nil {
            result = value
        }
    }    
    
    private func report(result: MMTResult<T>)
    {
        if let completion = callback {
            completion(result)
        }
    }
}
