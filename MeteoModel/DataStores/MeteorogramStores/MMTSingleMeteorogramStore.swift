//
//  MMTPredictionCache.swift
//  MeteoModel
//
//  Created by szostakowskik on 20/02/2019.
//  Copyright © 2019 Kamil Szostakowski. All rights reserved.
//

import UIKit
import Foundation
import CoreLocation

fileprivate let groupId = "group.com.szostakowski.meteo"

class MMTSingleMeteorogramStore: MMTMeteorogramCache
{    
    // MARK: Properties
    private let appGroup = UserDefaults(suiteName: groupId)
    private let fileCoordinator = NSFileCoordinator(filePresenter: nil)
    private let fileUrl: URL
    
    // MARK
    init(_ url: URL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: groupId)!.appendingPathComponent("meteorogram.png"))
    {
        self.fileUrl = url
    }
    
    // MARK: Interface methods
    var isEmpty: Bool {
        guard let dict = appGroup?.dictionaryRepresentation() else { return false }
        return MMTMeteorogram.deserialize(from: dict) == nil
    }
    
    @discardableResult
    func store(_ meteorogram: MMTMeteorogram) -> Bool
    {
        FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)
        
        let serialized = MMTMeteorogram.serialize(meteorogram)
        serialized.keys.forEach { self.appGroup?.set(serialized[$0], forKey: $0) }
        appGroup?.synchronize()
        
        return write(image: meteorogram.image, to: fileUrl)
    }
    
    func restore() -> MMTMeteorogram?
    {
        guard let dict = appGroup?.dictionaryRepresentation() else { return nil }
        guard var meteorogram = MMTMeteorogram.deserialize(from: dict) else { return nil }
        guard let image = read(from: fileUrl) else { return nil }
            
        meteorogram.image = image
        return meteorogram
    }
    
    @discardableResult
    func cleanup() -> Bool
    {
        let city = MMTCityProt(name: "", region: "", location: CLLocation())
        let dummyMeteorogram = MMTMeteorogram(model: MMTUmClimateModel(), city: city)
        let serialized = MMTMeteorogram.serialize(dummyMeteorogram)
        
        serialized.keys.forEach { self.appGroup?.removeObject(forKey: $0) }
        appGroup?.synchronize()
        
        return delete(at: fileUrl)
    }
}

// MARK: File operations extension
fileprivate extension MMTSingleMeteorogramStore
{
    func write(image: UIImage, to url: URL) -> Bool
    {
        var success = false
        
        fileCoordinator.coordinate(writingItemAt: url, options: .forReplacing, error: nil) {
            do { try image.pngData()?.write(to: $0); success = true } catch {}
        }
        return success
    }
    
    func read(from url: URL) -> UIImage?
    {
        var image: UIImage?
        fileCoordinator.coordinate(readingItemAt: url, options: .withoutChanges, error: nil) {
            guard let imageDate = try? Data(contentsOf: $0) else { return }
            image = UIImage(data: imageDate)
        }
        return image
    }
    
    func delete(at url: URL) -> Bool
    {
        var success = false
        fileCoordinator.coordinate(writingItemAt: url, options: .forDeleting, error: nil) {
            do { try FileManager.default.removeItem(at: $0); success = true } catch {}
        }
        return success
    }
}

// MARK: City serialization extension
fileprivate extension MMTCityProt
{
    static func serialize(_ city: MMTCityProt) -> [String: Any]
    {
        return [
            "city-name": city.name,
            "city-region": city.region,
            "city-lat": city.location.coordinate.latitude,
            "city-lng": city.location.coordinate.longitude
        ]
    }
    
    static func deserialize(from dict: [String: Any]) -> MMTCityProt?
    {
        guard let name = dict["city-name"] as? String else { return nil }
        guard let region = dict["city-region"] as? String else { return nil }
        guard let lat = dict["city-lat"] as? Double else { return nil }
        guard let lng = dict["city-lng"] as? Double else { return nil }
        
        let location = CLLocation(latitude: lat, longitude: lng)
        return MMTCityProt(name: name, region: region, location: location)
    }
}

// MARK: Meteorogram serialization extension
fileprivate extension MMTMeteorogram
{
    static func serialize(_ meteorogram: MMTMeteorogram) -> [String: Any]
    {
        let serializedCity = MMTCityProt.serialize(meteorogram.city)
        
        return [
            "met-model": meteorogram.model.type.rawValue,
            "met-prediction": meteorogram.prediction?.rawValue ?? 0,
            "met-start-date": meteorogram.startDate.timeIntervalSince1970
        ].merging(serializedCity) { (current, new) in current }
    }
    
    static func deserialize(from dict: [String: Any]) -> MMTMeteorogram?
    {
        guard let modelName = dict["met-model"] as? String else { return nil }
        guard let modelType = MMTClimateModelType(rawValue: modelName) else { return nil }
        guard let startDate = dict["met-start-date"] as? Double else { return nil }
        guard let prediction = dict["met-prediction"] as? Int else { return nil }
        guard let city = MMTCityProt.deserialize(from: dict) else { return nil }
        
        var
        meteorogram = MMTMeteorogram(model: modelType.model, city: city)
        meteorogram.startDate = Date(timeIntervalSince1970: startDate)
        meteorogram.prediction = MMTMeteorogram.Prediction(rawValue: prediction)
        
        return meteorogram
    }
}
