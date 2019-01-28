//
//  MMTGoogleAnalytics.swift
//  MobileMeteo
//
//  Created by Kamil Szostakowski on 22.01.2016.
//  Copyright © 2016 Kamil Szostakowski. All rights reserved.
//

import Foundation
import MeteoModel

extension GAI: MMTAnalytics
{    
    public func sendScreenEntryReport(_ screen: String)
    {
        let analyticsReport = GAIDictionaryBuilder.createScreenView().build() as NSDictionary
        
        defaultTracker.set(kGAIScreenName, value: screen)
        defaultTracker.send(analyticsReport as? [AnyHashable: Any])
    }
    
    public func sendUserActionReport(_ report: MMTAnalyticsReport)
    {
        let category = report.category.rawValue
        let action = report.action.rawValue
        let analyticsReport = GAIDictionaryBuilder.createEvent(withCategory: category, action: action, label: report.actionLabel, value: 1).build() as NSDictionary
        
        defaultTracker.set(kGAIScreenName, value: category)
        defaultTracker.send(analyticsReport as? [AnyHashable: Any])
    }
    
    public func sendUserActionReport(_ category: MMTAnalyticsCategory, action: MMTAnalyticsAction, actionLabel label: String)
    {
        sendUserActionReport(MMTAnalyticsReport(category: category, action: action, actionLabel: label))
    }
}

extension MMTAnalyticsReporter
{
    public var analytics: MMTAnalytics?
    {        
        guard GAI.sharedInstance().defaultTracker != nil else {
            return nil
        }
        
        GAI.sharedInstance().logger.logLevel = .none
        
        #if DEBUG
        GAI.sharedInstance().dryRun = true
        GAI.sharedInstance().logger.logLevel = .warning
        #endif

        return GAI.sharedInstance()
    }
}

extension UIViewController: MMTAnalyticsReporter {}
