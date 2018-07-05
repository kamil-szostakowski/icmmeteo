//
//  MMTUpdatableView.swift
//  MeteoWidget
//
//  Created by szostakowskik on 05.07.2018.
//  Copyright © 2018 Kamil Szostakowski. All rights reserved.
//

import Foundation

// TODO: Possible to factor out to the future UI related framework
protocol MMTUpdatableView
{
    associatedtype T
    associatedtype U
    
    func updated(with: U) -> T
}
