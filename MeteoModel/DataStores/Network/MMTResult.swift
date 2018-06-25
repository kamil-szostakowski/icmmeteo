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
