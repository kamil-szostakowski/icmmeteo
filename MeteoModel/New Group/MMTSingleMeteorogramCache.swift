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

class MMTSingleMeteorogramCache
{    
    // MARK: Properties
    private let appGroup = UserDefaults(suiteName: groupId)
    private let fileCoordinator = NSFileCoordinator(filePresenter: nil)
    private let fileUrl = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: groupId)?.appendingPathComponent("meteorogram.png")
    
    // MARK: Interface methods
    func store(meteorogram: MMTMeteorogram, completion: @escaping (Bool) -> Void)
    {
        let serialized = MMTMeteorogram.serialize(meteorogram)
        serialized.keys.forEach { self.appGroup?.set(serialized[$0], forKey: $0) }
        appGroup?.synchronize()
        
        DispatchQueue.global().async {
            guard let url = self.fileUrl else {
                completion(false)
                return
            }
            completion(self.write(image: meteorogram.image, to: url))
        }
    }
    
    func restoreMeteorogram(completion: @escaping (MMTMeteorogram?) -> Void)
    {
        guard let dict = appGroup?.dictionaryRepresentation() else { completion(nil); return }
        guard var meteorogram = MMTMeteorogram.deserialize(from: dict) else { completion(nil); return }
        
        DispatchQueue.global().async {
            guard let url = self.fileUrl else { completion(meteorogram); return }
            guard let image = self.read(from: url) else { completion(meteorogram); return }
            
            meteorogram.image = image
            completion(meteorogram)
        }
    }
    
    // MARK: Helper methods
    private func write(image: UIImage, to url: URL) -> Bool
    {
        var success = false
        fileCoordinator.coordinate(writingItemAt: url, options: .forReplacing, error: nil) {
            do { try image.pngData()?.write(to: $0); success = true }
            catch {}
        }
        
        return success
    }
    
    private func read(from url: URL) -> UIImage?
    {
        var image: UIImage?
        fileCoordinator.coordinate(readingItemAt: url, options: .withoutChanges, error: nil) {
            guard let imageDate = try? Data(contentsOf: $0) else { return }
            image = UIImage(data: imageDate)
        }
        
        return image
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
