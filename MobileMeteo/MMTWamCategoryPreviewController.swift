//
//  MMTWamCategoryPreviewController.swift
//  MobileMeteo
//
//  Created by Kamil Szostakowski on 26.08.2015.
//  Copyright (c) 2015 Kamil Szostakowski. All rights reserved.
//

import UIKit
import Foundation

class MMTWamCategoryPreviewController: UIViewController, UIScrollViewDelegate
{
    @IBOutlet var prevMomentButton: UIBarButtonItem!
    @IBOutlet var nextMomentBtn: UIBarButtonItem!
    @IBOutlet var meteorogramImage: UIImageView!
    @IBOutlet var activityIndicator: UIView!
    @IBOutlet var momentLabel: UILabel!
    @IBOutlet var navigationBar: UINavigationBar!
    @IBOutlet var scrollView: UIScrollView!
    
    private var cache = NSCache<NSString, UIImage>()
    private var meteorogramSize: CGSize!
    private var meteorogramLegendSize: CGSize!
    private var wamMoments: [MMTWamMoment]!

    var wamStore: MMTWamModelStore!
    var selectedCategory: MMTWamCategory!
    var selectedMoment: Int = 0
    
    private var isFirstMoment: Bool {
        return selectedMoment == 0
    }
    
    private var isLastMoment: Bool {
        return selectedMoment == wamMoments.count-1
    }
    
    // MARK: Overrides
    
    override func viewDidLoad()
    {
        super.viewDidLoad()        
        
        navigationBar.topItem?.title = MMTTranslationWamCategory[selectedCategory]
        meteorogramImage.accessibilityIdentifier = "\(selectedCategory)"
        wamMoments = wamStore.getForecastMoments()

        setupMeteorogramSize()        
        setupNavigationButtons()        
    }
    
    override func viewDidAppear(_ animated: Bool)
    {
        super.viewDidAppear(animated)
        
        setupScrollView()
        displayCurrentMoment()
        analytics?.sendScreenEntryReport("Model WAM category preview")
    }
    
    override var supportedInterfaceOrientations : UIInterfaceOrientationMask
    {
        return UIInterfaceOrientationMask.portrait
    }
    
    // MARK: Setup methods
    
    private func setupNavigationButtons()
    {
        prevMomentButton.isEnabled = false
        prevMomentButton.accessibilityIdentifier = "PrevButton"
        
        nextMomentBtn.isEnabled = false
        nextMomentBtn.accessibilityIdentifier = "NextButton"
    }
    
    private func setupMomentLabelForDate(_ date: Date)
    {
        let tZeroPlus = wamStore.getHoursFromForecastStartDate(forDate: date)
        let tZeroPlusString = String(format: MMTFormat.TZeroPlus, tZeroPlus)
        let momentString = DateFormatter.utcFormatter.string(from: date)
        
        momentLabel.text = "start \(tZeroPlusString) = \(momentString)"
    }

    private func setupMeteorogramSize()
    {
        meteorogramSize = CGSize(forDetailedMapOfModel: .WAM)
        meteorogramLegendSize = CGSize(forDetailedMapLegendOfModel: .WAM)
    }
    
    private func setupScrollView()
    {
        meteorogramImage.updateSizeConstraints(meteorogramSize)
        
        scrollView.maximumZoomScale = 1
        scrollView.minimumZoomScale = scrollView.zoomScaleFittingWidth(for: meteorogramSize)
        scrollView.zoomScale = scrollView.zoomScaleFittingHeight(for: meteorogramSize)
    }
    
    // MARK: Action methods    
    
    @IBAction func didClickNextMomentBtn(_ sender: UIBarButtonItem)
    {
        selectedMoment += 1
        displayCurrentMoment()
    }

    @IBAction func didClickPreviousMomentBtn(_ sender: UIBarButtonItem)
    {
        selectedMoment -= 1
        displayCurrentMoment()
    }
    
    @IBAction func didRecognizedDoubleTapGesture(_ sender: UITapGestureRecognizer)
    {
        let defaultZoomScale = scrollView.zoomScaleFittingHeight(for: meteorogramSize)
        
        scrollView.animateZoom(scale: defaultZoomScale)
    }

    // MARK: UIScrollViewDelegate methods
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView?
    {
        return meteorogramImage
    }
    
    // MARK: Helper methods
    
    private func displayCurrentMoment()
    {
        let moment = wamMoments[selectedMoment].date
        
        setupMomentLabelForDate(moment as Date)
        
        prevMomentButton.isEnabled = false
        nextMomentBtn.isEnabled = false
        
        getMeteorogramWithQuery(MMTWamModelMeteorogramQuery(category: selectedCategory, moment: moment)){
            (image: UIImage?, error: MMTError?) in
            
            self.meteorogramImage.image = image
            self.prevMomentButton.isEnabled = !self.isFirstMoment
            self.nextMomentBtn.isEnabled = !self.isLastMoment
        }
    }
    
    private func getMeteorogramWithQuery(_ query: MMTWamModelMeteorogramQuery, completion: @escaping MMTFetchMeteorogramCompletion)
    {
        let key = "\(query.moment)" as NSString
        
        if let image = cache.object(forKey: key)
        {
            completion(image, nil)
            return
        }
        
        activityIndicator.isHidden = false
        
        wamStore.getMeteorogramMomentWithQuery(query){
            (img: UIImage?, error: MMTError?) in
            
            self.activityIndicator.isHidden = true
            
            guard let image = img, error == nil else
            {
                let alert = UIAlertController.alertForMMTError(error!){ (UIAlertAction) -> Void in
                    self.performSegue(withIdentifier: MMTSegue.UnwindToWamModel, sender: self)
                }
                
                self.present(alert, animated: true, completion: nil)
                return
            }
            
            self.cache.setObject(image, forKey: key)
            completion(image, error)
        }
    }
}
