//
//  MMTGoogleAnalytics.swift
//  MobileMeteo
//
//  Created by Kamil Szostakowski on 22.01.2016.
//  Copyright © 2016 Kamil Szostakowski. All rights reserved.
//

import Foundation

extension GAI: MMTAnalytics
{    
    func sendScreenEntryReport(screen: String)
    {
        let analyticsReport = GAIDictionaryBuilder.createScreenView().build()
        
        defaultTracker.set(kGAIScreenName, value: screen)
        defaultTracker.send(analyticsReport as [NSObject : AnyObject])
    }
    
    func sendUserActionReport(report: MMTAnalyticsReport)
    {
        let category = report.category.rawValue
        let action = report.action.rawValue
        let analyticsReport = GAIDictionaryBuilder.createEventWithCategory(category, action: action, label: report.actionLabel, value: 1).build()
        
        defaultTracker.set(kGAIScreenName, value: category)
        defaultTracker.send(analyticsReport as [NSObject : AnyObject])
    }
    
    func sendUserActionReport(category: MMTAnalyticsCategory, action: MMTAnalyticsAction, actionLabel label: String)
    {
        sendUserActionReport(MMTAnalyticsReport(category: category, action: action, actionLabel: label))
    }
}

extension UIViewController
{
    var analytics: MMTAnalytics?
    {        
        guard GAI.sharedInstance().defaultTracker != nil else {
            return nil
        }
        
        GAI.sharedInstance().logger.logLevel = .None
        
        #if DEBUG
        GAI.sharedInstance().dryRun = true
        GAI.sharedInstance().logger.logLevel = .Warning
        #endif

        return GAI.sharedInstance()
    }
}