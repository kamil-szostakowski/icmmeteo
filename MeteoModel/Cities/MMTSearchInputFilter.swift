//
//  MMTSearchInputFilter.swift
//  MobileMeteo
//
//  Created by Kamil Szostakowski on 09.09.2015.
//  Copyright (c) 2015 Kamil Szostakowski. All rights reserved.
//

import Foundation

public class MMTSearchInput
{
    // MARK: Properties
    private var rawInput: String!
    
    public var stringValue: String {
        return rawInput
    }
    
    public var isValid: Bool {
        return rawInput.removed(doubled: .whitespaces).count > 2
    }
    
    // MARK: Initializers
    
    public init(_ input: String)
    {
        rawInput = input.removed(doubled: .whitespaces)
        
        // Supports multi word city names eg. Kędzierzyn Koźle
        if rawInput.count > 0 && input.last == " " {
            rawInput.append(" ")
        }
    }
}

extension String
{
    func removed(doubled characterSet: CharacterSet) -> String
    {
        return components(separatedBy: characterSet)
            .filter(){ $0.count > 0 }
            .joined(separator: " ")
    }
}
