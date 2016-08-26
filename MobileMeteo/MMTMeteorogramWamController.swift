//
//  MMTMeteorogramWamController.swift
//  MobileMeteo
//
//  Created by Kamil Szostakowski on 20.07.2015.
//  Copyright (c) 2015 Kamil Szostakowski. All rights reserved.
//

import UIKit
import Foundation

typealias MMTWamMeteorogramsCache = [Date: Data]

class MMTMeteorogramWamController: UIViewController, UICollectionViewDataSource, MMTCollectionViewDelegateWamLayout
{
    // MARK: Outlets
    
    @IBOutlet var forecastLength: UILabel!
    @IBOutlet var forecastStart: UILabel!
    @IBOutlet var collectionView: UICollectionView!
    
    fileprivate var categories: [MMTWamCategory]!
    fileprivate var cache = NSCache<NSString, UIImage>()
    fileprivate var wamSettings: MMTWamSettings!
    fileprivate var categoryPreviewSettings: MMTWamSettings!
    fileprivate var wamStore: MMTWamModelStore!
    fileprivate var failureCount = 0
    fileprivate var failureWatch: Timer!
    fileprivate var presented: Bool = false
    fileprivate var lastUpdate: Date?

    // MARK: Properties

    fileprivate var itemHeight: CGFloat
    {
        let spacesCount = max(categories.count-1, 0)
        let spacing = CGFloat(spacesCount*layout.sectionSpacing.intValue)
        
        return (collectionView.frame.size.height-spacing)/CGFloat(categories.count)
    }
    
    fileprivate var layout: MMTCollectionViewWamLayout {
        return collectionView.collectionViewLayout as! MMTCollectionViewWamLayout
    }
    
    // MARK: UIViewController methods
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        wamStore = MMTWamModelStore(date: Date())
        
        setupInfoBar()
        setupSettings()
        setupCollectionView()
    }
    
    override func viewDidAppear(_ animated: Bool)
    {
        super.viewDidAppear(animated)
        
        presented = true
        failureWatch = Timer.scheduledTimer(timeInterval: 5, target: self, selector: #selector(failureCheck), userInfo: nil, repeats: true)
        
        setupNotificationHandler()
        updateMeteorogramIfNeeded()
        
        analytics?.sendScreenEntryReport("Model WAM")
    }
    
    override func viewWillDisappear(_ animated: Bool)
    {
        super.viewWillDisappear(animated)
        
        presented = false
        failureWatch.invalidate()
        failureWatch = nil
        
        NotificationCenter.default.removeObserver(self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        if segue.identifier == MMTSegue.DisplayWamSettings {
            segue.destination.setValue(wamSettings, forKey: "wamSettings")
            segue.destination.setValue(wamStore, forKey: "wamStore")
        }
        
        if segue.identifier == MMTSegue.DisplayWamCategoryPreview {
            segue.destination.setValue(categoryPreviewSettings, forKey: "wamSettings")
            segue.destination.setValue(wamStore, forKey: "wamStore")
        }        
    }
    
    // MARK: Setup methods
    
    fileprivate func setupSettings()
    {
        categories = [.TideHeight, .AvgTidePeriod, .SpectrumPeakPeriod]
        wamSettings = MMTWamSettings(wamStore.getForecastMoments())
        categoryPreviewSettings = MMTWamSettings(wamStore.getForecastMoments())
        
        for moment in wamSettings.forecastMomentsGrouppedByDay.first! {
            wamSettings.setMomentSelection(moment.date, selected: true)
        }
    }
    
    fileprivate func setupCollectionView()
    {
        let headerClass: AnyClass = MMTWamHeaderView.classForCoder()
        let identifier = MMTCollectionViewWamLayout.headerViewIdentifier
        
        collectionView.register(headerClass, forSupplementaryViewOfKind: identifier, withReuseIdentifier: identifier)
    }
    
    fileprivate func setupInfoBar()
    {        
        let formatter = DateFormatter.utcFormatter
        
        forecastStart.text = MMTLocalizedStringWithFormat("forecast.start: %@", formatter.string(from: wamStore.forecastStartDate))
        forecastLength.text = MMTLocalizedStringWithFormat("forecast.length: %dh", wamStore.forecastLength)
    }
    
    fileprivate func setupNotificationHandler()
    {
        let handler = #selector(handleApplicationDidBecomeActiveNotification(_:))
        let notification = NSNotification.Name.UIApplicationDidBecomeActive
        
        NotificationCenter.default.addObserver(self, selector: handler, name: notification, object: nil)
    }
    
    // MARK: Actions
    
    @IBAction func unwindToWamModel(_ unwindSegue: UIStoryboardSegue)
    {
    }
    
    @IBAction func unwindToWamModelAndUpdateSettings(_ unwindSegue: UIStoryboardSegue)
    {
        if let controller = unwindSegue.source as? MMTModelWamSettingsController {
            wamSettings = controller.wamSettings
        }
    }
    
    @objc func failureCheck()
    {
        guard failureCount>0 else { return }
        
        failureCount=0
        updateMeteorogramIfNeeded()
    }
    
    func handleApplicationDidBecomeActiveNotification(_ notification: Notification)
    {
        updateMeteorogramIfNeeded()
    }
    
    // MARK: UICollectionViewDataSource methods
    
    func numberOfSections(in collectionView: UICollectionView) -> Int
    {
        return presented ? categories.count : 0
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
    {
        return wamSettings.forecastSelectedMoments.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
    {
        let date = wamSettings.forecastSelectedMoments[indexPath.row].date
        let tZeroPlus = wamStore.getHoursFromForecastStartDate(forDate: date)
        let category = categories[indexPath.section]
        
        let
        cell = collectionView.dequeueReusableCell(withReuseIdentifier: "WamMomentItem", for: indexPath) as! MMTWamCategoryItem
        cell.headerLabel.text = DateFormatter.utcFormatter.string(from: date)
        cell.footerLabel.text = String(NSString(format: MMTFormat.TZeroPlus as NSString, tZeroPlus))
        cell.accessibilityIdentifier = "\(category) +\(tZeroPlus)"        
        cell.setNeedsLayout()
        cell.layoutIfNeeded()
        
        getThumbnailWithQuery(MMTWamModelMeteorogramQuery(category, date)) {
            (image: UIImage?, error: MMTError?) in
            
            guard error == nil else {
                self.failureCount += 1
                return
            }

            cell.map.image = image
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, itemSizeForLayout collectionViewLayout: UICollectionViewLayout) -> CGSize
    {
        let width = itemHeight*0.928
        return CGSize(width: width, height: itemHeight)
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath)
        -> UICollectionReusableView
    {
        let category = categories[indexPath.section]
        
        let
        headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: kind, for: indexPath) as! MMTWamHeaderView
        headerView.categoryTitle = MMTTranslationWamCategory[category]! as NSString

        return headerView
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath)
    {
        let startMoment = categoryPreviewSettings.forecastMoments[indexPath.row].date
        let selectedMoments = categoryPreviewSettings.forecastSelectedMoments.map(){ $0.date }
        
        categoryPreviewSettings.selectedCategory = categories[indexPath.section]
        categoryPreviewSettings.setMomentsSelection(selectedMoments, selected: false)
        categoryPreviewSettings.setMomentSelection(startMoment, selected: true)
        
        performSegue(withIdentifier: MMTSegue.DisplayWamCategoryPreview, sender: self)
    }
    
    // MARK: Helper methods    
    
    fileprivate func updateMeteorogramIfNeeded()
    {
        guard lastUpdate == nil || Date().timeIntervalSince(lastUpdate!) >= TimeInterval(minutes: 5) else
        {
            collectionView.reloadData()
            return
        }
        
        let forecastStartDate = wamStore.forecastStartDate
        let handleFailure = {
            self.lastUpdate = nil
            self.failureCount += 1
        }
        
        lastUpdate = Date()
        wamStore.getForecastStartDate(){ (date: Date?, error: MMTError?) in
            
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
    
    fileprivate func getThumbnailWithQuery(_ query: MMTWamModelMeteorogramQuery, completion: @escaping (_ image: UIImage?, _ error: MMTError?) -> Void)
    {
        let key = "\(query.category.rawValue)\(query.moment)" as NSString
        
        if let image = cache.object(forKey: key)
        {
            completion(image, nil)
            return
        }

        wamStore.getMeteorogramMomentThumbnailWithQuery(query) {
            (data: Data?, error: MMTError?) in
            
            var thumbImg: UIImage?
            
            defer { completion(thumbImg, error) }
            guard let imageData = data else { return }
            guard let image = UIImage(data: imageData) else { return }
            
            thumbImg = image
            self.cache.setObject(image, forKey: key)
        }
    }
}
