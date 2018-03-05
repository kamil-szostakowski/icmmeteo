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
import MeteoModel

class MMTMeteorogramController: UIViewController, NSUserActivityDelegate, MMTActivityIndicating
{
    // MARK: Outlets
    @IBOutlet weak var modelSegmentedControl: UISegmentedControl!
    @IBOutlet var navigationBar: UINavigationBar!
    @IBOutlet var meteorogramImage: UIImageView!
    @IBOutlet var legendImage: UIImageView!
    @IBOutlet var scrollView: UIScrollView!
    @IBOutlet var scrollViewContainer: UIView!
    @IBOutlet weak var forecastStartLabel: UILabel!
    
    // MARK: Properties
    var city: MMTCityProt!
    var activityIndicator: MMTActivityIndicator!
    
    fileprivate var meteorogramStore: MMTMeteorogramStore!
    fileprivate var btnFavourite: UIButton!    
}

// MARK: Lifecycle extension
extension MMTMeteorogramController
{
    // MARK: Lifecycle methods
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        print("Fav: \(city.isFavourite)")
        print("Cap: \(city.isCapital)")
        
        setupMeteorogramStore(model: MMTUmClimateModel())
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
}

// MARK: Setup extension
extension MMTMeteorogramController
{
    // MARK: Setup methods
    fileprivate func setupMeteorogramStore(model: MMTClimateModel)
    {
        let cache = MMTCoreData.instance.meteorogramsCache
        let date = model.startDate(for: Date())
        meteorogramStore = MMTMeteorogramStore(model: model, date: date, cache: cache)
    }
    
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
    
    fileprivate func setupInfoBar()
    {
        forecastStartLabel.text = MMTLocalizedStringWithFormat("forecast.start: %@", DateFormatter.utcFormatter.string(from: meteorogramStore.forecastStartDate))
    }
}

// MARK: Navigation extension
extension MMTMeteorogramController
{
    // MARK: Navigation methods
    @IBAction func onCloseBtnTouchAction(_ sender: UIBarButtonItem)
    {
        MMTCitiesStore().save(city: city)
        MMTCoreData.instance.context.saveContextIfNeeded()
        try? MMTShortcutsMigrator().migrate()
        perform(segue: .UnwindToListOfCities, sender: self)
    }
    
    @IBAction func onStarBtnTouchAction(_ sender: UIButton)
    {
        city.isFavourite = !city.isFavourite
        sender.isSelected = city.isFavourite
        sender.imageView?.layer.add(CAAnimation.defaultScaleAnimation(), forKey: "scale")
        
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
        
        setupMeteorogramStore(model: climateModel)
        updateMeteorogram()
    }
    
    // Mark: Navigation helper methods
    fileprivate func displayErrorAlert(_ error: MMTError)
    {
        let alert = UIAlertController.alertForMMTError(error){ _ in
            self.onCloseBtnTouchAction(self.navigationBar.topItem!.leftBarButtonItem!)
        }
        
        if meteorogramStore.climateModel.type == .UM {
            let actionTitle = MMTLocalizedString("label.try.coamps")
            let tryCoampsAction = UIAlertAction(title: actionTitle, style: .default) { action in
                self.modelSegmentedControl.selectedSegmentIndex = 1
                self.modelTypeDidChange(self.modelSegmentedControl)
            }
            alert.addAction(tryCoampsAction)
        }
        
        present(alert, animated: true, completion: nil)
    }
}

// MARK: Data update extension
extension MMTMeteorogramController
{
    // MARK: Data update methods
    fileprivate func updateMeteorogram()
    {
        setupMeteorogram(image: nil)
        setupMeteorogramLegend(image: nil)
        
        meteorogramStore.getForecastStartDate {_,_ in
            self.setupInfoBar()
        }
        
        scrollView.contentOffset = .zero
        modelSegmentedControl.isEnabled = false
        
        displayActivityIndicator(in: view, message: MMTLocalizedString("label.loading.meteorogram"))
        
        meteorogramStore.getLegend {
            (image: UIImage?, error: MMTError?) in
            self.setupMeteorogramLegend(image: image)
        }
        
        meteorogramStore.getMeteorogram(for: city) {
            (image: UIImage?, error: MMTError?) in
            
            self.hideActivityIndicator()
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

// MARK: Meteorogram zooming extension
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

// MARK: Spotlight extension
extension MMTMeteorogramController
{
    // MARK: Spotlight methods
    fileprivate func updateSpotlightIndex(for city: MMTCityProt)
    {
        guard CSSearchableIndex.isIndexingAvailable() else { return }
        let shortcut = MMTMeteorogramShortcut(model: MMTUmClimateModel(), city: city)
                
        if city.isFavourite {
            CSSearchableIndex.default().register(shortcut)
        } else {
            CSSearchableIndex.default().unregister(shortcut)
        }
    }
}
