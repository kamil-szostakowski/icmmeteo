//
//  MMTMeteorogramWamController.swift
//  MobileMeteo
//
//  Created by Kamil Szostakowski on 20.07.2015.
//  Copyright (c) 2015 Kamil Szostakowski. All rights reserved.
//

import UIKit
import Foundation

typealias MMTWamMeteorogramsCache = [NSDate: NSData]

class MMTMeteorogramWamController: UIViewController, UICollectionViewDataSource, MMTCollectionViewDelegateWamLayout
{
    // MARK: Outlets
    
    @IBOutlet var forecastLength: UILabel!
    @IBOutlet var forecastStart: UILabel!
    @IBOutlet var collectionView: UICollectionView!
    
    private var categories: [MMTWamCategory]!
    private var cache: NSCache = NSCache()
    private var wamSettings: MMTWamSettings!
    private var categoryPreviewSettings: MMTWamSettings!
    private var wamStore: MMTWamModelStore!
    private var failureCount = 0
    private var failureWatch: NSTimer!
    private var presented: Bool = false
    private var lastUpdate: NSDate?

    // MARK: Properties

    private var itemHeight: CGFloat
    {
        let spacesCount = max(categories.count-1, 0)
        let spacing = CGFloat(spacesCount*layout.sectionSpacing.integerValue)
        
        return (collectionView.frame.size.height-spacing)/CGFloat(categories.count)
    }
    
    private var layout: MMTCollectionViewWamLayout {
        return collectionView.collectionViewLayout as! MMTCollectionViewWamLayout
    }
    
    // MARK: UIViewController methods
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        wamStore = MMTWamModelStore(date: NSDate())
        
        setupInfoBar()
        setupSettings()
        setupCollectionView()
    }
    
    override func viewDidAppear(animated: Bool)
    {
        super.viewDidAppear(animated)
        
        presented = true
        failureWatch = NSTimer.scheduledTimerWithTimeInterval(5, target: self, selector: "failureCheck", userInfo: nil, repeats: true)
        
        setupNotificationHandler()
        updateMeteorogramIfNeeded()
        
        analytics?.sendScreenEntryReport("Model WAM")
    }
    
    override func viewWillDisappear(animated: Bool)
    {
        super.viewWillDisappear(animated)
        
        presented = false
        failureWatch.invalidate()
        failureWatch = nil
        
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?)
    {
        if segue.identifier == MMTSegue.DisplayWamSettings {
            segue.destinationViewController.setValue(wamSettings, forKey: "wamSettings")
            segue.destinationViewController.setValue(wamStore, forKey: "wamStore")
        }
        
        if segue.identifier == MMTSegue.DisplayWamCategoryPreview {
            segue.destinationViewController.setValue(categoryPreviewSettings, forKey: "wamSettings")
            segue.destinationViewController.setValue(wamStore, forKey: "wamStore")
        }        
    }
    
    // MARK: Setup methods
    
    private func setupSettings()
    {
        categories = [.TideHeight, .AvgTidePeriod, .SpectrumPeakPeriod]
        wamSettings = MMTWamSettings(wamStore.getForecastMoments())
        categoryPreviewSettings = MMTWamSettings(wamStore.getForecastMoments())
        
        for moment in wamSettings.forecastMomentsGrouppedByDay.first! {
            wamSettings.setMomentSelection(moment.date, selected: true)
        }
    }
    
    private func setupCollectionView()
    {
        let headerClass: AnyClass = MMTWamHeaderView.classForCoder()
        let identifier = MMTCollectionViewWamLayout.headerViewIdentifier
        
        collectionView.registerClass(headerClass, forSupplementaryViewOfKind: identifier, withReuseIdentifier: identifier)
    }
    
    private func setupInfoBar()
    {
        let s = wamStore
        let formatter = NSDateFormatter.utcFormatter
        
        forecastStart.text = MMTLocalizedStringWithFormat("forecast.start: %@", formatter.stringFromDate(s.forecastStartDate))
        forecastLength.text = MMTLocalizedStringWithFormat("forecast.length: %dh", s.forecastLength)
    }
    
    private func setupNotificationHandler()
    {
        let handler = Selector("handleApplicationDidBecomeActiveNotification:")
        let notification = UIApplicationDidBecomeActiveNotification
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: handler, name: notification, object: nil)
    }
    
    // MARK: Actions
    
    @IBAction func unwindToWamModel(unwindSegue: UIStoryboardSegue)
    {
    }
    
    @IBAction func unwindToWamModelAndUpdateSettings(unwindSegue: UIStoryboardSegue)
    {
        if let controller = unwindSegue.sourceViewController as? MMTModelWamSettingsController {
            wamSettings = controller.wamSettings
        }
    }
    
    @objc func failureCheck()
    {
        guard failureCount>0 else { return }
        
        failureCount=0
        updateMeteorogramIfNeeded()
    }
    
    func handleApplicationDidBecomeActiveNotification(notification: NSNotification)
    {
        updateMeteorogramIfNeeded()
    }
    
    // MARK: UICollectionViewDataSource methods
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int
    {
        return presented ? categories.count : 0
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
    {
        return wamSettings.forecastSelectedMoments.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell
    {
        let date = wamSettings.forecastSelectedMoments[indexPath.row].date
        let tZeroPlus = wamStore.getHoursFromForecastStartDate(forDate: date)
        let category = categories[indexPath.section]
        
        let
        cell = collectionView.dequeueReusableCellWithReuseIdentifier("WamMomentItem", forIndexPath: indexPath) as! MMTWamCategoryItem
        cell.headerLabel.text = NSDateFormatter.utcFormatter.stringFromDate(date)
        cell.footerLabel.text = String(NSString(format: MMTFormat.TZeroPlus, tZeroPlus))
        cell.accessibilityIdentifier = "\(category) +\(tZeroPlus)"        
        cell.setNeedsLayout()
        cell.layoutIfNeeded()
        
        getThumbnailWithQuery(MMTWamModelMeteorogramQuery(category, date)) {
            (image: UIImage?, error: MMTError?) in
            
            guard error == nil else {
                self.failureCount++
                return
            }

            cell.map.image = image
        }
        
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, itemSizeForLayout collectionViewLayout: UICollectionViewLayout) -> CGSize
    {
        let width = itemHeight*0.928
        return CGSizeMake(width, itemHeight)
    }
    
    func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath)
        -> UICollectionReusableView
    {
        let category = categories[indexPath.section]
        
        let
        headerView = collectionView.dequeueReusableSupplementaryViewOfKind(kind, withReuseIdentifier: kind, forIndexPath: indexPath) as! MMTWamHeaderView
        headerView.categoryTitle = MMTTranslationWamCategory[category]!

        return headerView
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath)
    {
        let startMoment = categoryPreviewSettings.forecastMoments[indexPath.row].date
        let selectedMoments = categoryPreviewSettings.forecastSelectedMoments.map(){ $0.date }
        
        categoryPreviewSettings.selectedCategory = categories[indexPath.section]
        categoryPreviewSettings.setMomentsSelection(selectedMoments, selected: false)
        categoryPreviewSettings.setMomentSelection(startMoment, selected: true)
        
        performSegueWithIdentifier(MMTSegue.DisplayWamCategoryPreview, sender: self)
    }
    
    // MARK: Helper methods    
    
    private func updateMeteorogramIfNeeded()
    {
        guard lastUpdate == nil || NSDate().timeIntervalSinceDate(lastUpdate!) >= NSTimeInterval(minutes: 5) else
        {
            collectionView.reloadData()
            return
        }
        
        let forecastStartDate = wamStore.forecastStartDate
        let handleFailure = {
            self.lastUpdate = nil
            self.failureCount++
        }
        
        lastUpdate = NSDate()
        wamStore.getForecastStartDate(){ (date: NSDate?, error: MMTError?) in
            
            defer
            {
                self.setupInfoBar()
                self.setupSettings()
                self.collectionView.reloadData()
            }
            
            guard error == nil else { handleFailure(); return }
            guard date != nil else { handleFailure(); return }
            guard forecastStartDate != date! else { return }
        }
    }
    
    private func getThumbnailWithQuery(query: MMTWamModelMeteorogramQuery, completion: (image: UIImage?, error: MMTError?) -> Void)
    {
        let key = "\(query.category.rawValue)\(query.moment)"
        
        if let image = cache.objectForKey(key) as? UIImage
        {
            completion(image: image, error: nil)
            return
        }

        wamStore.getMeteorogramMomentThumbnailWithQuery(query) {
            (data: NSData?, error: MMTError?) in
            
            var thumbImg: UIImage?
            
            defer { completion(image: thumbImg, error: error) }
            guard let imageData = data else { return }
            guard let image = UIImage(data: imageData) else { return }
            
            thumbImg = image
            self.cache.setObject(image, forKey: key)
        }
    }
}