//
//  MMTPredictionModel.swift
//  MeteoModel
//
//  Created by szostakowskik on 23/01/2019.
//  Copyright © 2019 Kamil Szostakowski. All rights reserved.
//

import UIKit
import Foundation
import CoreGraphics

// MARK: Protocol definition
public protocol MMTPredictionModel
{
    func predict(_ image: CGImage) throws -> MMTMeteorogram.Prediction
}

// MARK: Default prediction model implementation
class MMTPredictionModelImpl : MMTPredictionModel
{
    // MARK: Inner types
    class InputProcessor {}
    
    // MARK: Properties
    private let model = MeteoML()
    private let inputProcessor = InputProcessor()
    static let shared = MMTPredictionModelImpl()
    
    // MARK: Interface methods
    func predict(_ image: CGImage) throws -> MMTMeteorogram.Prediction
    {
        let predictions = try inputProcessor.inputs(from: image)
            .map { return try model.prediction(input: $0) }
        
        return try MMTMeteorogram.Prediction(predictions)
    }
}

// MARK: Helper class responsible for model input transformation
fileprivate extension MMTPredictionModelImpl.InputProcessor
{
    // MARK: Input transformation methods
    func inputs(from image: CGImage, size: CGSize = CGSize(width: 180, height: 85)) throws -> [MeteoMLInput]
    {
        return try [140, 314, 522]
            .map { return CGRect(origin: CGPoint(x: 65, y: $0), size: size) }
            .map { return try self.transformCrop(input: image, to: $0) }
            .map { return try self.transformScale(input: $0, scale: 0.5) }
            .map { return try self.transformGrayscale(input: $0) }
            .map { return try self.transformPixelBuffer(input: $0) }
            .map { return try MeteoMLInput($0) }
    }
    
    private func transformCrop(input: CGImage, to rect: CGRect) throws -> CGImage
    {
        guard let image = input.cropping(to: rect) else { throw MMTError.invalidMLInput }
        return image
    }
    
    private func transformGrayscale(input: CGImage) throws -> CGImage
    {
        guard let context = input.createContext() else { throw MMTError.invalidMLInput }
        context.draw(input, in: CGRect(origin: .zero, size: input.size))
        guard let image = context.makeImage() else { throw MMTError.invalidMLInput }
        
        return image
    }
    
    private func transformScale(input: CGImage, scale: CGFloat) throws -> CGImage
    {
        let width = Int(input.size.width * scale)
        let height = Int(input.size.height * scale)
        let size = CGSize(width: width, height: height)
        
        guard let context = input.createContext(size: size) else { throw MMTError.invalidMLInput }
        context.draw(input, in: CGRect(origin: .zero, size: size))
        guard let image = context.makeImage() else { throw MMTError.invalidMLInput }
        
        return image
    }
    
    private func transformPixelBuffer(input: CGImage) throws -> CVPixelBuffer
    {
        let width = input.width
        let height = input.height
        var pixBuffer:CVPixelBuffer? = nil
        
        guard CVPixelBufferCreate(kCFAllocatorDefault, width, height, kCVPixelFormatType_OneComponent8 , nil, &pixBuffer) == kCVReturnSuccess else {
            throw MMTError.invalidMLInput
        }
        
        guard let pixelBuffer = pixBuffer else {
            throw MMTError.invalidMLInput
        }
        
        let lockFlags = CVPixelBufferLockFlags(rawValue: 0)
        CVPixelBufferLockBaseAddress(pixelBuffer, lockFlags)
        
        let data = CVPixelBufferGetBaseAddress(pixelBuffer)
        let cSpace = CGColorSpaceCreateDeviceGray()
        
        guard let context = CGContext(data: data, width: width, height: height, bitsPerComponent: 8, bytesPerRow: CVPixelBufferGetBytesPerRow(pixelBuffer), space: cSpace, bitmapInfo: CGBitmapInfo(rawValue: 0).rawValue) else {
            throw MMTError.invalidMLInput
        }
        
        context.draw(input, in: CGRect(origin: .zero, size: input.size))
        CVPixelBufferUnlockBaseAddress(pixelBuffer, lockFlags)
        
        return pixelBuffer
    }
}

// MARK: Convenience extension
fileprivate extension CGImage
{
    var size: CGSize {
        return CGSize(width: width, height: height)
    }
    
    func createContext(size: CGSize = .zero) -> CGContext?
    {
        let sWidth = size == .zero ? width : Int(size.width)
        let sHeight = size == .zero ? height : Int(size.height)
        let cSpace = CGColorSpaceCreateDeviceGray()
        
        let context = CGContext(data: nil, width: sWidth, height: sHeight, bitsPerComponent: bitsPerComponent, bytesPerRow: bytesPerRow, space: cSpace, bitmapInfo: CGImageAlphaInfo.none.rawValue
        )
        
        return context
    }
}

// MARK: Convenience extension
fileprivate extension MeteoMLInput
{
    convenience init(_ pixelBuffer: CVPixelBuffer) throws
    {
        self.init(dnn__input_from_feature_columns__input_layer__image__encoded__ToFloat__0: pixelBuffer)
    }
}

// MARK: Convenience extension
fileprivate extension MMTMeteorogram.Prediction
{
    init(_ predictions: [MeteoMLOutput]) throws
    {
        guard predictions.count == 3 else {
            throw MMTError.invalidMLInput
        }
        
        let treshold = 0.7
        self = []
        
        // Checking rain probability
        if predictions[0].dnn__head__predictions__probabilities__0[0].doubleValue > treshold {
            self.insert(.rain)
        }
        
        // Checking string wind probability
        if predictions[1].dnn__head__predictions__probabilities__0[1].doubleValue > treshold {
            self.insert(.strongWind)
        }
        
        // Checking clouds probability
        if predictions[2].dnn__head__predictions__probabilities__0[2].doubleValue > treshold {
            self.insert(.clouds)
        }
    }
}
