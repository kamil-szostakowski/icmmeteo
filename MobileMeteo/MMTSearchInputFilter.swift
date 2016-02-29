//
//  MMTSearchInputFilter.swift
//  MobileMeteo
//
//  Created by Kamil Szostakowski on 09.09.2015.
//  Copyright (c) 2015 Kamil Szostakowski. All rights reserved.
//

import Foundation

class MMTSearchInput: NSObject
{
    // MARK: Properties
    private var rawInput: String!
    
    var stringValue: String {
        return rawInput
    }
    
    var isValid: Bool {
        return stringWithRemovedDuplicatedWhitespaces(rawInput).characters.count>2
    }
    
    // MARK: Initializers
    
    init(_ input: String)
    {
        super.init()
        
        rawInput = stringWithRemovedDuplicatedWhitespaces(input)
        
        if rawInput.characters.count > 0 && Array(input.characters).last == Character(" ") {
            rawInput.append(Character(" "))
        }
    }
    
    // MARK: Helper methods
    
    private func stringWithRemovedDuplicatedWhitespaces(input: String) -> String
    {
        let characterSet = NSCharacterSet.whitespaceCharacterSet()
        let components = input.componentsSeparatedByCharactersInSet(characterSet).filter(){ $0.characters.count > 0 }
        
        return components.joinWithSeparator(" ")
    }
}