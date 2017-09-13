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
    
    // MARK: Properties
    
    var city: MMTCityProt!
    var climateModel: MMTClimateModel!
    
    private var citiesStore: MMTCitiesStore!
    private var meteorogramStore: MMTMeteorogramStore!
    private var meteorogramSize: CGSize!
    private var meteorogramLegendSize: CGSize!
    private var btnFavourite: UIButton!

    // MARK: Controller methods
    
    override func viewDidLoad()
    {
        super.viewDidLoad()

        citiesStore = MMTCitiesStore(db: MMTDatabase.instance, geocoder: MMTCityGeocoder(generalGeocoder: CLGeocoder()))
        meteorogramStore = MMTMeteorogramStore(model: climateModel, date: Date())
        navigationBar.topItem!.title = city.name

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
        let selectedImage = UIImage(named: "star")?.withRenderingMode(.alwaysTemplate)
        let unselectedImage = UIImage(named: "star-outline")?.withRenderingMode(.alwaysTemplate)
        
        btnFavourite = UIButton(type: .custom)
        btnFavourite.setImage(selectedImage, for: .selected)
        btnFavourite.setImage(unselectedImage, for: .normal)
        btnFavourite.addTarget(self, action: #selector(self.onStarBtnTouchAction(_:)), for: .touchUpInside)
        btnFavourite.isSelected = city.isFavourite
        btnFavourite.isUserInteractionEnabled = false
        
        navigationBar.topItem?.rightBarButtonItem = UIBarButtonItem(customView: btnFavourite)
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
            self.btnFavourite.isUserInteractionEnabled = true
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
    
    @IBAction func onStarBtnTouchAction(_ sender: UIButton)
    {
        city.isFavourite = !city.isFavourite
        sender.isSelected = city.isFavourite
        sender.imageView?.layer.add(CAAnimation.defaultScaleAnimation(), forKey: "scale")
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
        guard CSSearchableIndex.isIndexingAvailable() else { return }
        
        if city.isFavourite {
            CSSearchableIndex.default().indexSearchableCity(city, completion: nil)
        }
        
        if !city.isFavourite {
            CSSearchableIndex.default().deleteSearchableCity(city, completion: nil)
        }
    }
}
