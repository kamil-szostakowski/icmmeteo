//
//  MMTForecasterCommentModelController.swift
//  MeteoModel
//
//  Created by szostakowskik on 15.06.2018.
//  Copyright © 2018 Kamil Szostakowski. All rights reserved.
//

import Foundation

public class MMTForecasterCommentModelController: MMTModelController
{
    // MAKR: Properties
    public var comment: NSAttributedString?
    public var error: MMTError?
    public var requestPending = false
    
    fileprivate var dataStore: MMTForecasterCommentDataStore
    fileprivate var lastUpdate: Date = Date.distantPast
    
    // MARK: Initializers
    public init(dataStore: MMTForecasterCommentDataStore)
    {
        self.dataStore = dataStore
    }
    
    // MARK: Lifecycle methods
    public override func activate()
    {
        guard Date().timeIntervalSince(lastUpdate) > TimeInterval(hours: 1) else {
            return
        }
        
        updateTextViewContent()
    }
    
    // MARK: Interface methods
    func updateTextViewContent()
    {
        requestPending = true                
        delegate?.onModelUpdate(self)
        
        dataStore.forecasterComment {
            
            self.lastUpdate = Date()
            self.requestPending = false
            
            switch $0 {
                case let .failure(error): self.error = error
                case let .success(content): self.comment = content.formattedAsComment()
            }
            
            self.delegate?.onModelUpdate(self)
        }
    }
}
