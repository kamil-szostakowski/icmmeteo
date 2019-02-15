//
//  MMTMeteorogramController.swift
//  MobileMeteo
//
//  Created by Kamil Szostakowski on 08.07.2015.
//  Copyright (c) 2015 Kamil Szostakowski. All rights reserved.
//

import Foundation
import CoreLocation
import CoreSpotlight
import MeteoModel
import MeteoUIKit

class MMTMeteorogramController: UIViewController, MMTActivityIndicating
{
    // MARK: Outlets
    @IBOutlet weak var modelSegmentedControl: UISegmentedControl!
    @IBOutlet weak var forecastStartLabel: UILabel!
    @IBOutlet var navigationBar: UINavigationBar!
    @IBOutlet var meteorogramImage: UIImageView!
    @IBOutlet var legendImage: UIImageView!
    @IBOutlet var scrollView: UIScrollView!
    @IBOutlet var scrollViewContainer: UIView!
    
    // MARK: Properties
    var city: MMTCityProt!
    var activityIndicator: MMTActivityIndicator!
    
    fileprivate var btnFavourite: UIButton!
    fileprivate var modelController: MMTMeteorogramModelController!
}

extension MMTMeteorogramController
{
    // MARK: Lifecycle methods
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        setupModelController(model: MMTUmClimateModel())
        setupNavigationBar()
        setupStarButton()
        setupScrollView()
        
        modelController.activate()
        CSSearchableIndex.update(for: city)
    }
    
    override func willTransition(to newCollection: UITraitCollection, with coordinator: UIViewControllerTransitionCoordinator)
    {
        coordinator.animate(alongsideTransition: nil) { _ in
            self.adjustZoomScale()
        }
        
        if newCollection.verticalSizeClass == .compact {
            analytics?.sendUserActionReport(.Meteorogram, action: .MeteorogramDidDisplayInLandscape, actionLabel: modelController.climateModel.type.rawValue)
        }
    }
}

extension MMTMeteorogramController
{
    // MARK: Setup methods
    fileprivate func setupModelController(model: MMTClimateModel)
    {
        modelController = MMTMeteorogramModelController(city: city, model: model)
        modelController.analytics = analytics
        modelController.delegate = self
    }
    
    fileprivate func setupNavigationBar()
    {
        navigationBar.accessibilityIdentifier = "meteorogram-screen"
        navigationBar.topItem!.title = modelController.city.name
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
        btnFavourite.isSelected = modelController.city.isFavourite
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
        scrollView.zoomScale = scrollView.zoomScale(for: contentSize)
    }
    
    fileprivate func setupMeteorogram(image: UIImage?)
    {
        meteorogramImage.image = image
        meteorogramImage.accessibilityIdentifier = image == nil ? "meteorogram" : "meteorogram-loaded"
        btnFavourite.isEnabled = image != nil
        meteorogramImage.updateSizeConstraints(CGSize(meteorogram: modelController.climateModel.type)!)
    }
    
    fileprivate func setupMeteorogramLegend(image: UIImage?)
    {
        var size = CGSize(meteorogramLegend: modelController.climateModel.type)!
        
        if image == nil {
            size.width = 0
        }
        
        legendImage.image = image
        legendImage.accessibilityIdentifier = image == nil ? "legend" : "legend-loaded"
        legendImage.updateSizeConstraints(size)
    }
    
    fileprivate func setupInfoBar(date: Date?)
    {
        let forecastStartDate = date ?? modelController.climateModel.startDate(for: Date())
        forecastStartLabel.text = MMTLocalizedStringWithFormat("forecast.start: %@", DateFormatter.utcFormatter.string(from: forecastStartDate))
    }
    
    fileprivate func display(error: MMTError)
    {
        let alert = UIAlertController.alertForMMTError(error){ _ in
            self.onCloseBtnTouchAction(self.navigationBar.topItem!.leftBarButtonItem!)
        }
        
        if modelController.climateModel.type == .UM {
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

extension MMTMeteorogramController
{
    // MARK: Action methods
    @IBAction func onCloseBtnTouchAction(_ sender: UIBarButtonItem)
    {
        modelController.deactivate()
        MMTCoreData.instance.context.saveContextIfNeeded()
        try? MMTShortcutsMigrator().migrate()
        perform(segue: .UnwindToListOfCities, sender: self)
    }
    
    @IBAction func onStarBtnTouchAction(_ sender: UIButton)
    {
        modelController.onToggleFavorite()
    }
    
    @IBAction func modelTypeDidChange(_ sender: UISegmentedControl)
    {
        let climateModel: MMTClimateModel = sender.selectedSegmentIndex == 0 ?
            MMTUmClimateModel() :
            MMTCoampsClimateModel()
        
        setupModelController(model: climateModel)
        modelController.activate()
    }
    
    @IBAction func onScrollViewDoubleTapAction(_ sender: UITapGestureRecognizer)
    {
        adjustZoomScale()
    }
}

// MARK: Meteorogram zooming extension
extension MMTMeteorogramController : UIScrollViewDelegate
{
    // MARK: Zooming methods
    func viewForZooming(in scrollView: UIScrollView) -> UIView?
    {
        return scrollViewContainer
    }
    
    fileprivate func adjustZoomScale()
    {
        scrollView.animateZoomScale(for: visibleContentSize())
    }
    
    fileprivate func visibleContentSize() -> CGSize
    {
        var meteorogramSize = meteorogramImage.frame.size
        let legendSize = legendImage.frame.size
        
        if traitCollection.verticalSizeClass == .compact {
            meteorogramSize.width += legendSize.width
        }
        
        return meteorogramSize
    }
}

extension MMTMeteorogramController: MMTModelControllerDelegate
{
    // MARK: Model update methods
    func onModelUpdate(_ controller: MMTModelController)
    {
        city = modelController.city
        
        switch modelController.requestPending {
            case true: displayActivityIndicator(in: view, message: MMTLocalizedString("label.loading.meteorogram"))
            case false: hideActivityIndicator()
        }
        
        if btnFavourite.isSelected != modelController.city.isFavourite {
            btnFavourite.isSelected = modelController.city.isFavourite
            btnFavourite.imageView?.layer.add(CAAnimation.defaultScaleAnimation(), forKey: "scale")
        }
        
        modelSegmentedControl.isEnabled = modelController.meteorogram != nil
        
        if let error = modelController.error {
            display(error: error)
            return
        }
        
        setupInfoBar(date: modelController.meteorogram?.startDate)
        setupMeteorogram(image: modelController.meteorogram?.image)
        setupMeteorogramLegend(image: modelController.meteorogram?.legend)
        
        let hasMeteorogram = modelController.meteorogram != nil
        
        switch hasMeteorogram {
            case true: adjustZoomScale()
            case false: scrollView.contentOffset = .zero
        }
    }
}
