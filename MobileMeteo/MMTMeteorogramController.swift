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

class MMTMeteorogramController: UIViewController, UIScrollViewDelegate, NSUserActivityDelegate
{
    // MARK: Outlets
    
    @IBOutlet var navigationBar: UINavigationBar!
    @IBOutlet var meteorogramImage: UIImageView!
    @IBOutlet var legendImage: UIImageView!
    @IBOutlet var activityIndicator: UIView!
    @IBOutlet var scrollView: UIScrollView!
    @IBOutlet var scrollViewContainer: UIView!
    @IBOutlet var btnFavourite: UIBarButtonItem!
    
    // MARK: Properties
    
    var city: MMTCityProt!
    var climateModel: MMTClimateModel!
    
    private var citiesStore: MMTCitiesStore!
    private var meteorogramStore: MMTMeteorogramStore!
    private var meteorogramSize: CGSize!
    private var meteorogramLegendSize: CGSize!

    // MARK: Controller methods
    
    override func viewDidLoad()
    {
        super.viewDidLoad()

        citiesStore = MMTCitiesStore(db: MMTDatabase.instance, geocoder: MMTCityGeocoder(generalGeocoder: CLGeocoder()))
        meteorogramStore = MMTMeteorogramStore(model: climateModel, date: Date())
        navigationBar.topItem!.title = city.name
        btnFavourite.isEnabled = false

        setupStarButton()
        setupMeteorogramSize()
    }
    
    override func viewDidAppear(_ animated: Bool)
    {
        super.viewDidAppear(animated)
                
        setupScrollView()        
        setupMeteorogram()
        setupMeteorogramLegend()
        
        updateCityStateInSpotlightIndex(city)
        analytics?.sendScreenEntryReport("Meteorogram: \(climateModel.type.rawValue)")
        analytics?.sendUserActionReport(.Meteorogram, action: .MeteorogramDidDisplay, actionLabel: climateModel.type.rawValue)
    }
    
    override func willTransition(to newCollection: UITraitCollection, with coordinator: UIViewControllerTransitionCoordinator)
    {
        coordinator.animate(alongsideTransition: nil) { (UIViewControllerTransitionCoordinatorContext) -> Void in                
            self.adjustZoomScale()
        }
        
        if newCollection.verticalSizeClass == .compact {
            analytics?.sendUserActionReport(.Meteorogram, action: .MeteorogramDidDisplayInLandscape, actionLabel: climateModel.type.rawValue)
        }
    }
    
    // MARK: Setup methods
    
    private func setupScrollView()
    {
        let contentSize = visibleContentSize()
        let zoomScale = zoomScaleForVisibleContentSize(contentSize)
        
        meteorogramImage.updateSizeConstraints(meteorogramSize)
        legendImage.updateSizeConstraints(meteorogramLegendSize)

        scrollView.maximumZoomScale = 1
        scrollView.minimumZoomScale = scrollView.zoomScaleFittingWidth(for: contentSize)
        scrollView.zoomScale = zoomScale
    }
    
    private func setupStarButton()
    {
        let imageName = city.isFavourite ? "star" : "star-outline"
        navigationBar.topItem?.rightBarButtonItem?.image = UIImage(named: imageName)
    }

    private func setupMeteorogramSize()
    {
        meteorogramSize = CGSize(forMeteorogramOfModel: climateModel.type)
        meteorogramLegendSize = CGSize(forMeteorogramLegendOfModel: climateModel.type)
    }
    
    private func setupMeteorogram()
    {
        meteorogramStore.getMeteorogramForLocation(city.location){
            (image: UIImage?, error: MMTError?) in
            
            guard error == nil else
            {
                self.activityIndicator.isHidden = true
                self.displayErrorAlert(error!)
                return
            }
            
            self.meteorogramImage.image = image!
            self.activityIndicator.isHidden = true
            self.btnFavourite.isEnabled = true
        }
    }
    
    private func setupMeteorogramLegend()
    {
        meteorogramStore.getMeteorogramLegend(){ (image: UIImage?, error: MMTError?) in
            
            guard error == nil else
            {
                var
                size: CGSize = self.meteorogramLegendSize
                size.width = 0
                
                self.legendImage.updateSizeConstraints(size)
                return
            }
            
            self.legendImage.image = image!
        }
    }

    // MARK: Actions

    @IBAction func onCloseBtnTouchAction(_ sender: UIBarButtonItem)
    {
        citiesStore.markCity(city, asFavourite: city.isFavourite)
        performSegue(withIdentifier: MMTSegue.UnwindToListOfCities, sender: self)
    }
    
    @IBAction func onScrollViewDoubleTapAction(_ sender: UITapGestureRecognizer)
    {
        adjustZoomScale()
    }
    
    @IBAction func onStartBtnTouchAction(_ sender: UIBarButtonItem)
    {
        if let button = (navigationBar.layer.sublayers!.max(){ $0.position.x < $1.position.x }) {
            button.add(CAAnimation.defaultScaleAnimation(), forKey: "scale")
        }                
        
        city.isFavourite = !city.isFavourite
        setupStarButton()
        updateCityStateInSpotlightIndex(city)
        
        let action: MMTAnalyticsAction = city.isFavourite ?
            MMTAnalyticsAction.LocationDidAddToFavourites :
            MMTAnalyticsAction.LocationDidRemoveFromFavourites        
        
        analytics?.sendUserActionReport(.Locations, action: action, actionLabel:  city.name)
    }

    // MARK: UIScrollViewDelegate methods
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView?
    {
        return scrollViewContainer
    }
    
    // MARK: Helper methods
    
    private func adjustZoomScale()
    {
        scrollView.animateZoom(scale: zoomScaleForVisibleContentSize(visibleContentSize()))
    }
    
    private func visibleContentSize() -> CGSize
    {
        var contentSize: CGSize = meteorogramSize
        
        if traitCollection.verticalSizeClass == .compact {
            contentSize.width += meteorogramLegendSize.width
        }
        
        return contentSize
    }
    
    private func zoomScaleForVisibleContentSize(_ size: CGSize) -> CGFloat
    {
        let isLandscape = traitCollection.verticalSizeClass == .compact
        
        return isLandscape ? scrollView.zoomScaleFittingWidth(for: size) : scrollView.zoomScaleFittingHeight(for: size)
    }
    
    private func displayErrorAlert(_ error: MMTError)
    {
        let alert = UIAlertController.alertForMMTError(error){ (UIAlertAction) -> Void in
            self.performSegue(withIdentifier: MMTSegue.UnwindToListOfCities, sender: self)
        }

        present(alert, animated: true, completion: nil)
    }
    
    private func updateCityStateInSpotlightIndex(_ city: MMTCityProt)
    {
        guard #available(iOS 9.0, *) else { return }        
        guard CSSearchableIndex.isIndexingAvailable() else { return }
        
        if city.isFavourite {
            CSSearchableIndex.default().indexSearchableCity(city, completion: nil)
        }
        
        if !city.isFavourite {
            CSSearchableIndex.default().deleteSearchableCity(city, completion: nil)
        }
    }
}
