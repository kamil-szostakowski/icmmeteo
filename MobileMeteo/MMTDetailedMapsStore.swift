//
//  MMTBaseClimateModelStore.swift
//  MobileMeteo
//
//  Created by Kamil Szostakowski on 29/12/16.
//  Copyright © 2016 Kamil Szostakowski. All rights reserved.
//

import Foundation

class MMTDetailedMapsStore: MMTForecastStore
{
    // MARK: Methods
    
    func getForecastMoments(for map: MMTDetailedMap) -> [Date]
    {
        var moments = [Date]()
        
        for index in 0...climateModel.detailedMapMomentsCount {

            let momentOffset = index == 0 ? climateModel.detailedMapStartDelay : TimeInterval(hours: index*3)
            let momentDate = forecastStartDate.addingTimeInterval(momentOffset)

            moments.append(momentDate)
        }

        return Array(moments[map.momentsOffset..<moments.count])
    }

    func getMeteorogram(for map: MMTDetailedMap, moment: Date, completion: @escaping MMTFetchMeteorogramCompletion)
    {
        let tZeroPlus = getHoursFromForecastStartDate(forDate: moment)
        let startDate = forecastStartDate

        guard let downloadUrl = try? URL.mmt_detailedMapDownloadUrl(for: climateModel.type, map: map.type, tZero: startDate, plus: tZeroPlus) else {

            completion(nil, .detailedMapNotSupported)
            return
        }

        urlSession.fetchImageFromUrl(downloadUrl, completion: completion)
    }

    func getMeteorograms(for moments: [Date], map: MMTDetailedMap, completion: @escaping MMTFetchMeteorogramsCompletion)
    {
        let queue = DispatchQueue.global()
        let group = DispatchGroup()

        for date in moments
        {
            queue.async(group: group) {
                group.enter()

                self.getMeteorogram(for: map, moment: date) {
                    (image: UIImage?, error: MMTError?) in

                    DispatchQueue.main.async { completion(image, date, error, false) }
                    group.leave()
                }
            }
        }

        group.notify(queue: queue) {
            DispatchQueue.main.async { completion(nil, nil, nil, true) }
        }
    }    
}
