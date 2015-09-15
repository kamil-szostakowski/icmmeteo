//
//  MMTSearchInputFilter.swift
//  MobileMeteo
//
//  Created by Kamil Szostakowski on 09.09.2015.
//  Copyright (c) 2015 Kamil Szostakowski. All rights reserved.
//

import Foundation

public class MMTSearchInput: NSObject
{
    // MARK: Properties
    private var rawInput: String!
    
    public var stringValue: String {
        return rawInput
    }
    
    public var isValid: Bool {
        return count(stringWithRemovedDuplicatedWhitespaces(rawInput))>2
    }
    
    // MARK: Initializers
    
    public init(_ input: String)
    {
        super.init()
        
        rawInput = stringWithRemovedDuplicatedWhitespaces(input)
        
        if count(rawInput) > 0 && Array(input).last == Character(" ")
        {
            rawInput.append(Character(" "))
        }
    }
    
    // MARK: Helper methods
    
    private func stringWithRemovedDuplicatedWhitespaces(input: String) -> String
    {
        let characterSet = NSCharacterSet.whitespaceCharacterSet()
        let components = input.componentsSeparatedByCharactersInSet(characterSet).filter(){ count($0) > 0 }
        
        return join(" ", components)
    }
}