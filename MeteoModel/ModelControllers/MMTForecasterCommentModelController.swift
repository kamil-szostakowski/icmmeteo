//
//  MMTForecasterCommentModelController.swift
//  MeteoModel
//
//  Created by szostakowskik on 15.06.2018.
//  Copyright © 2018 Kamil Szostakowski. All rights reserved.
//

import Foundation

public class MMTForecasterCommentModelController: MMTBaseModelController
{
    // MAKR: Properties
    public var requestPending = false
    public var comment: MMTResult<NSAttributedString>
    
    fileprivate var dataStore: MMTForecasterCommentDataStore
    fileprivate var lastUpdate: Date = Date.distantPast
    
    // MARK: Initializers
    public init(dataStore: MMTForecasterCommentDataStore)
    {
        self.comment = .success(NSMutableAttributedString())
        self.dataStore = dataStore
    }
    
    // MARK: Lifecycle methods
    public override func activate()
    {
        let timeElapsed = Date().timeIntervalSince(lastUpdate) > TimeInterval(hours: 1)
        
        if case .failure(_) = comment {
            updateTextViewContent()
        } else if timeElapsed {
            updateTextViewContent()
        }
    }
    
    // MARK: Interface methods
    func updateTextViewContent()
    {
        requestPending = true
        comment = .success(NSMutableAttributedString())
        delegate?.onModelUpdate(self)
        
        dataStore.forecasterComment {
            
            self.lastUpdate = Date()
            self.requestPending = false
            
            switch $0 {
                case let .failure(error):
                    self.comment = .failure(error)
                case let .success(content):
                    self.comment = .success(content.formattedAsComment())
            }
            
            self.delegate?.onModelUpdate(self)
        }
    }
}
