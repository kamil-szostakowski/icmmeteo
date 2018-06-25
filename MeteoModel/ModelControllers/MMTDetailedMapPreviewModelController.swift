//
//  MMTDetailedMapPreviewModelController.swift
//  MeteoModel
//
//  Created by szostakowskik on 14.06.2018.
//  Copyright © 2018 Kamil Szostakowski. All rights reserved.
//

import UIKit
import Foundation

public class MMTDetailedMapPreviewModelController: MMTModelController
{
    // MARK: Properties
    public var moment: Date?
    public var momentImage: UIImage?
    public var error: MMTError?
    public var requestPending = false
    public private(set) var map: MMTDetailedMap
    
    public var momentsCount: Int {
        return meteorogram?.moments.count ?? 0
    }
    
    fileprivate var dataStore: MMTMeteorogramDataStore
    fileprivate var meteorogram: MMTMapMeteorogram?
    fileprivate var fetchSequenceRetryCount = 0
    
    // MARK: Initializers
    public init(map: MMTDetailedMap, dataStore: MMTMeteorogramDataStore)
    {
        self.map = map
        self.dataStore = dataStore        
    }
    
    // MARK: Lifecycle methods
    override public func activate()
    {
        fetchMeteorogram()
    }
}

extension MMTDetailedMapPreviewModelController
{
    // MARK: Interface methods
    public func onMomentDisplayRequest(index: Int)
    {
        guard let image = meteorogram?.images[index] else {
            retryMeteorogramFetchIfPossible()
            return
        }
        
        momentImage = image
        moment = meteorogram?.moments[index]
        delegate?.onModelUpdate(self)
    }
}

extension MMTDetailedMapPreviewModelController
{
    // MARK: Data update methods
    fileprivate func fetchMeteorogram()
    {
        requestPending = true
        delegate?.onModelUpdate(self)
        
        dataStore.meteorogram(for: map) {
            
            self.requestPending = false
            
            if case let .failure(error) = $0 {
                self.error = error
                self.meteorogram = nil
                self.delegate?.onModelUpdate(self)
            }
            
            if case let .success(meteorogram) = $0 {
                self.meteorogram = meteorogram
                self.error = nil
                self.onMomentDisplayRequest(index: 0)
            }            
        }
    }
    
    fileprivate func retryMeteorogramFetchIfPossible()
    {
        if requestPending == false
        {
            fetchSequenceRetryCount += 1
            
            guard fetchSequenceRetryCount < 3 else {
                resetMeteorogramData(with: .meteorogramFetchFailure)
                delegate?.onModelUpdate(self)
                return
            }
            
            fetchMeteorogram()
        }
    }
    
    fileprivate func resetMeteorogramData(with downloadError: MMTError)
    {
        error = downloadError
        meteorogram = nil
        moment = nil
        momentImage = nil
    }
}
