//
//  MMTSearchInputFilter.swift
//  MobileMeteo
//
//  Created by Kamil Szostakowski on 09.09.2015.
//  Copyright (c) 2015 Kamil Szostakowski. All rights reserved.
//

import Foundation

class MMTSearchInput
{
    // MARK: Properties
    private var rawInput: String!
    
    var stringValue: String {
        return rawInput
    }
    
    var isValid: Bool {
        return rawInput.removed(doubled: .whitespaces).characters.count > 2
    }
    
    // MARK: Initializers
    
    init(_ input: String)
    {
        rawInput = input.removed(doubled: .whitespaces)
        
        // Supports multi word city names eg. Kędzierzyn Koźle
        if rawInput.characters.count > 0 && input.last == " " {
            rawInput.append(" ")
        }
    }
}

extension String
{
    func removed(doubled characterSet: CharacterSet) -> String
    {
        return components(separatedBy: characterSet)
            .filter(){ $0.characters.count > 0 }
            .joined(separator: " ")
    }
}
