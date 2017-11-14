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
    @IBOutlet var navigationBar: UINavigationBar!
    @IBOutlet var meteorogramImage: UIImageView!
    @IBOutlet var legendImage: UIImageView!
    @IBOutlet var activityIndicator: UIView!
    @IBOutlet var scrollView: UIScrollView!
    @IBOutlet var scrollViewContainer: UIView!
    
    // MARK: Properties
    var city: MMTCityProt!
    var climateModel: MMTClimateModel!
    
    fileprivate var meteorogramStore: MMTMeteorogramStore!
    fileprivate var btnFavourite: UIButton!
}

// Lifecycle extension
extension MMTMeteorogramController
{
    // MARK: Controller methods
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        meteorogramStore = MMTMeteorogramStore(model: climateModel, date: Date())
        
        setupNavigationBar()
        setupStarButton()
        setupScrollView()
        
        updateMeteorogram()
        updateSpotlightIndex(for: city)
        analytics?.sendScreenEntryReport("Meteorogram: \(climateModel.type.rawValue)")
    }
    
    override func willTransition(to newCollection: UITraitCollection, with coordinator: UIViewControllerTransitionCoordinator)
    {
        coordinator.animate(alongsideTransition: nil) { _ in
            self.adjustZoomScale()
        }
        
        if newCollection.verticalSizeClass == .compact {
            analytics?.sendUserActionReport(.Meteorogram, action: .MeteorogramDidDisplayInLandscape, actionLabel: climateModel.type.rawValue)
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
        self.meteorogramImage.image = image
        self.btnFavourite.isEnabled = true
    }
    
    fileprivate func setupMeteorogramLegend(image: UIImage?)
    {
        guard image != nil else {
            let size = CGSize(width: 0, height: self.meteorogramImage.frame.size.height)            
            legendImage.updateSizeConstraints(size)
            return
        }
        
        legendImage.image = image
    }
}

// Navigation extension
extension MMTMeteorogramController
{
    // MARK: Actions
    @IBAction func onCloseBtnTouchAction(_ sender: UIBarButtonItem)
    {
        let
        citiesStore = MMTCitiesStore(db: .instance, geocoder: MMTCityGeocoder(general: CLGeocoder()))
        citiesStore.markCity(city, asFavourite: city.isFavourite)
        
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
        meteorogramImage.updateSizeConstraints(CGSize(meteorogram: climateModel.type)!)
        legendImage.updateSizeConstraints(CGSize(meteorogramLegend: climateModel.type)!)
        
        meteorogramStore.getMeteorogramLegend {
            (image: UIImage?, error: MMTError?) in
            self.setupMeteorogramLegend(image: image)
        }
        
        meteorogramStore.getMeteorogramForLocation(city.location){
            (image: UIImage?, error: MMTError?) in
            
            self.activityIndicator.isHidden = true
            
            guard error == nil else {
                self.displayErrorAlert(error!)
                return
            }
            
            self.setupMeteorogram(image: image)
            self.analytics?.sendUserActionReport(.Meteorogram, action: .MeteorogramDidDisplay, actionLabel: self.climateModel.type.rawValue)
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
        var meteorogramSize = CGSize(meteorogram: climateModel.type)!
        let legendSize = CGSize(meteorogramLegend: climateModel.type)!
        
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
