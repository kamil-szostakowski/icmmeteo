//
//  MMTResult.swift
//  MeteoModel
//
//  Created by szostakowskik on 25.06.2018.
//  Copyright © 2018 Kamil Szostakowski. All rights reserved.
//

import Foundation

public enum MMTResult<T>
{
    case success(T)
    case failure(MMTError)
}

extension MMTResult: Equatable where T: Equatable
{
    public static func == (lhs: MMTResult<T>, rhs: MMTResult<T>) -> Bool
    {
        if case let .success(first) = lhs, case let .success(second) = rhs {
            return first == second
        }
        
        if case let .failure(first) = lhs, case let .failure(second) = rhs {
            return first == second
        }
        
        return false
    }
}
