//
//  MMTMeteorogramController.swift
//  MobileMeteo
//
//  Created by Kamil Szostakowski on 08.07.2015.
//  Copyright (c) 2015 Kamil Szostakowski. All rights reserved.
//

import UIKit
import Foundation
import CoreLocation
import CoreSpotlight

class MMTMeteorogramController: UIViewController, NSUserActivityDelegate
{
    // MARK: Outlets
    @IBOutlet weak var modelSegmentedControl: UISegmentedControl!
    @IBOutlet var navigationBar: UINavigationBar!
    @IBOutlet var meteorogramImage: UIImageView!
    @IBOutlet var legendImage: UIImageView!
    @IBOutlet var activityIndicator: UIView!
    @IBOutlet var scrollView: UIScrollView!
    @IBOutlet var scrollViewContainer: UIView!
    @IBOutlet weak var forecastStartLabel: UILabel!
    
    // MARK: Properties
    var city: MMTCityProt!
    
    fileprivate var meteorogramStore: MMTMeteorogramStore!
    fileprivate var btnFavourite: UIButton!    
}

// Lifecycle extension
extension MMTMeteorogramController
{
    // MARK: Lifecycle methods
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        meteorogramStore = MMTMeteorogramStore(model: MMTUmClimateModel(), date: Date())
        
        setupNavigationBar()
        setupInfoBar()
        setupStarButton()
        setupScrollView()
        
        updateMeteorogram()
        updateSpotlightIndex(for: city)
        analytics?.sendScreenEntryReport("Meteorogram: \(meteorogramStore.climateModel.type.rawValue)")
    }
    
    override func willTransition(to newCollection: UITraitCollection, with coordinator: UIViewControllerTransitionCoordinator)
    {
        coordinator.animate(alongsideTransition: nil) { _ in
            self.adjustZoomScale()
        }
        
        if newCollection.verticalSizeClass == .compact {
            analytics?.sendUserActionReport(.Meteorogram, action: .MeteorogramDidDisplayInLandscape, actionLabel: meteorogramStore.climateModel.type.rawValue)
        }
    }
    
    @objc func handleApplicationDidBecomeActiveNotification(_ notification: Notification)
    {
        let oldDate = meteorogramStore.forecastStartDate
        meteorogramStore.getForecastStartDate { (date: Date?, error: MMTError?) in
            guard let newDate = date else { return }
            
            if oldDate < newDate {
                self.updateMeteorogram()
            }
        }
    }
}

// Setup extension
extension MMTMeteorogramController
{
    // MARK: Setup methods
    fileprivate func setupNavigationBar()
    {
        navigationBar.accessibilityIdentifier = "meteorogram-screen"
        navigationBar.topItem!.title = city.name
        navigationBar.topItem!.leftBarButtonItem?.accessibilityIdentifier = "close"
    }
    
    fileprivate func setupStarButton()
    {
        let selectedImage = UIImage(named: "star")!.withRenderingMode(.alwaysTemplate)
        let unselectedImage = UIImage(named: "star-outline")!.withRenderingMode(.alwaysTemplate)
        
        btnFavourite = UIButton(type: .custom)
        btnFavourite.setImage(selectedImage, for: .selected)
        btnFavourite.setImage(unselectedImage, for: .normal)
        btnFavourite.addTarget(self, action: #selector(self.onStarBtnTouchAction(_:)), for: .touchUpInside)
        btnFavourite.isSelected = city.isFavourite
        btnFavourite.isEnabled = false
        btnFavourite.frame = CGRect(origin: .zero, size: selectedImage.size)
        btnFavourite.accessibilityIdentifier = "toggle-favourite"
        
        navigationBar.topItem?.rightBarButtonItem = UIBarButtonItem(customView: btnFavourite)
    }
    
    fileprivate func setupScrollView()
    {
        let contentSize = visibleContentSize()
        
        scrollView.maximumZoomScale = 1
        scrollView.minimumZoomScale = scrollView.zoomScaleFittingWidth(for: contentSize)
        scrollView.zoomScale = zoomScale(for: contentSize)
    }
    
    fileprivate func setupMeteorogram(image: UIImage?)
    {
        meteorogramImage.image = image
        meteorogramImage.accessibilityIdentifier = image == nil ? "meteorogram" : "meteorogram-loaded"
        btnFavourite.isEnabled = image != nil
        meteorogramImage.updateSizeConstraints(CGSize(meteorogram: meteorogramStore.climateModel.type)!)
    }
    
    fileprivate func setupMeteorogramLegend(image: UIImage?)
    {
        var size = CGSize(meteorogramLegend: meteorogramStore.climateModel.type)!
        
        if image == nil {
            size.width = 0
        }
        
        legendImage.image = image
        legendImage.accessibilityIdentifier = image == nil ? "legend" : "legend-loaded"
        legendImage.updateSizeConstraints(size)
    }
    
    fileprivate func setupNotificationHandler()
    {
        let handler = #selector(handleApplicationDidBecomeActiveNotification(_:))
        NotificationCenter.default.addObserver(self, selector: handler, name: .UIApplicationDidBecomeActive, object: nil)
    }
    
    fileprivate func setupInfoBar()
    {
        forecastStartLabel.text = MMTLocalizedStringWithFormat("forecast.start: %@", DateFormatter.utcFormatter.string(from: meteorogramStore.forecastStartDate))
    }
}

// Navigation extension
extension MMTMeteorogramController
{
    // MARK: Navigation methods
    @IBAction func onCloseBtnTouchAction(_ sender: UIBarButtonItem)
    {
        let
        citiesStore = MMTCitiesStore(db: .instance, geocoder: MMTCityGeocoder(general: CLGeocoder()))
        citiesStore.markCity(city, asFavourite: city.isFavourite)
        
        NotificationCenter.default.removeObserver(self)
        perform(segue: .UnwindToListOfCities, sender: self)
    }
    
    @IBAction func onStarBtnTouchAction(_ sender: UIButton)
    {
        city.isFavourite = !city.isFavourite
        sender.isSelected = city.isFavourite
        sender.imageView?.layer.add(CAAnimation.defaultScaleAnimation(), forKey: "scale")
        updateSpotlightIndex(for: city)
        
        let action: MMTAnalyticsAction = city.isFavourite ?
            MMTAnalyticsAction.LocationDidAddToFavourites :
            MMTAnalyticsAction.LocationDidRemoveFromFavourites
        
        analytics?.sendUserActionReport(.Locations, action: action, actionLabel:  city.name)
    }
    
    @IBAction func modelTypeDidChange(_ sender: UISegmentedControl)
    {
        let climateModel: MMTClimateModel = sender.selectedSegmentIndex == 0 ?
            MMTUmClimateModel() :
            MMTCoampsClimateModel()
        
        meteorogramStore = MMTMeteorogramStore(model: climateModel, date: Date())
        updateMeteorogram()
    }
    
    // Mark: Navigation helper methods
    fileprivate func displayErrorAlert(_ error: MMTError)
    {
        let alert = UIAlertController.alertForMMTError(error){ _ in
            self.perform(segue: .UnwindToListOfCities, sender: self)
        }
        
        present(alert, animated: true, completion: nil)
    }
}

// Data update extension
extension MMTMeteorogramController
{
    // MARK: Data update methods
    fileprivate func updateMeteorogram()
    {
        setupMeteorogram(image: nil)
        setupMeteorogramLegend(image: nil)
        setupInfoBar()
        
        scrollView.contentOffset = .zero
        activityIndicator.isHidden = false
        modelSegmentedControl.isEnabled = false
        
        meteorogramStore.getForecastStartDate { _,_ in
            self.setupInfoBar()
        }
        
        meteorogramStore.getLegend {
            (image: UIImage?, error: MMTError?) in
            self.setupMeteorogramLegend(image: image)
        }
        
        meteorogramStore.getMeteorogram(for: city) {
            (image: UIImage?, error: MMTError?) in
            
            self.activityIndicator.isHidden = true
            self.modelSegmentedControl.isEnabled = true
            
            guard error == nil else {
                self.displayErrorAlert(error!)
                return
            }
            
            self.setupMeteorogram(image: image)
            self.adjustZoomScale()
            self.analytics?.sendUserActionReport(.Meteorogram, action: .MeteorogramDidDisplay, actionLabel: self.meteorogramStore.climateModel.type.rawValue)
        }
    }
}

// Meteorogram zooming extension
extension MMTMeteorogramController : UIScrollViewDelegate
{
    // Mark: Zooming actions
    @IBAction func onScrollViewDoubleTapAction(_ sender: UITapGestureRecognizer)
    {
        adjustZoomScale()
    }
    
    // MARK: Zooming helper methods
    fileprivate func adjustZoomScale()
    {
        scrollView.animateZoom(scale: zoomScale(for: visibleContentSize()))
    }
    
    fileprivate func zoomScale(for size: CGSize) -> CGFloat
    {
        let isLandscape = traitCollection.verticalSizeClass == .compact
        
        return isLandscape ? scrollView.zoomScaleFittingWidth(for: size) : scrollView.zoomScaleFittingHeight(for: size)
    }
    
    fileprivate func visibleContentSize() -> CGSize
    {
        var meteorogramSize = CGSize(meteorogram: meteorogramStore.climateModel.type)!
        let legendSize = CGSize(meteorogramLegend: meteorogramStore.climateModel.type)!
        
        if traitCollection.verticalSizeClass == .compact {
            meteorogramSize.width += legendSize.width
        }
        
        return meteorogramSize
    }
    
    // MARK: UIScrollViewDelegate methods
    func viewForZooming(in scrollView: UIScrollView) -> UIView?
    {
        return scrollViewContainer
    }
}

// Spotlight extension
extension MMTMeteorogramController
{
    // MARK: Spotlight methods
    fileprivate func updateSpotlightIndex(for city: MMTCityProt)
    {
        guard CSSearchableIndex.isIndexingAvailable() else { return }
        
        if city.isFavourite {
            CSSearchableIndex.default().indexSearchableCity(city, completion: nil)
        }
        else {
            CSSearchableIndex.default().deleteSearchableCity(city, completion: nil)
        }
    }
}
