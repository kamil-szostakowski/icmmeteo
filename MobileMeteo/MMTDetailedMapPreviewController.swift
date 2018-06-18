//
//  MMTDetailedMapPreviewController.swift
//  MobileMeteo
//
//  Created by Kamil on 02.12.2016.
//  Copyright © 2016 Kamil Szostakowski. All rights reserved.
//
// TODO: Check how application handles dates from the future

import Foundation
import MeteoModel

class MMTDetailedMapPreviewController: UIViewController, MMTActivityIndicating
{
    // MARK: Properties
    @IBOutlet weak var detailedMapImage: UIImageView!
    @IBOutlet weak var slider: UISlider!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var mapTitle: UILabel!
    @IBOutlet weak var momentLabel: UILabel!
    @IBOutlet weak var scrollView: UIScrollView!
    
    var detailedMap: MMTDetailedMap!
    var activityIndicator: MMTActivityIndicator!

    fileprivate var meteorogramSize: CGSize!
    fileprivate var meteorogramLegendSize: CGSize!
    fileprivate var modelController: MMTDetailedMapPreviewModelController!

    private var detailedMapSize: CGSize {
        return CGSize(width: meteorogramSize.width-meteorogramLegendSize.width, height: meteorogramSize.height)
    }

    // MARK: Lifecycle methods
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        setupModelController()
        setupHeader(with: detailedMap.climateModel.startDate(for: Date()))
        setupMeteorogramSize()
        
        modelController.activate()
    }

    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)
        setupScrollView()
    }
    
    override var supportedInterfaceOrientations : UIInterfaceOrientationMask
    {
        return .portrait
    }
}

extension MMTDetailedMapPreviewController
{
    // MARK: Setup methods
    fileprivate func setupSlider(with momentsCount: Int)
    {
        // TODO: Need to be somehow refactored
        guard slider.maximumValue != Float(momentsCount-1) else {
            return
        }
        
        slider.minimumValue = 0
        slider.maximumValue = Float(momentsCount-1)
        slider.value = 0
    }
    
    fileprivate func setupHeader(with moment: Date)
    {
        mapTitle.text = MMTLocalizedStringWithFormat("detailed-maps.\(detailedMap.type.rawValue)")
        momentLabel.text = DateFormatter.utcFormatter.string(from: moment)
    }
    
    fileprivate func setupModelController()
    {
        modelController = MMTDetailedMapPreviewModelController(map: detailedMap)
        modelController.delegate = self
    }
    
    fileprivate func setupMeteorogramSize()
    {
        meteorogramSize = CGSize(map: detailedMap.climateModel.type)
        meteorogramLegendSize = CGSize(mapLegend: detailedMap.climateModel.type)
    }
    
    fileprivate func setupScrollView()
    {
        scrollView.maximumZoomScale = 1
        scrollView.minimumZoomScale = scrollView.zoomScaleFittingWidth(for: meteorogramSize)
        scrollView.zoomScale = scrollView.zoomScaleFittingWidth(for: detailedMapSize)
        
        detailedMapImage.updateSizeConstraints(meteorogramSize)
    }
}

extension MMTDetailedMapPreviewController: UIScrollViewDelegate
{
    // MARK: Actions
    @IBAction func onSliderPositionChangeAction(_ sender: UISlider)
    {
        modelController.onMomentDisplayRequest(index: Int(round(sender.value)))
    }
    
    @IBAction func onScrollViewDoubleTapAction(_ sender: UITapGestureRecognizer)
    {
        scrollView.animateZoom(scale: scrollView.zoomScaleFittingWidth(for: detailedMapSize))
    }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView?
    {
        return detailedMapImage
    }
}

extension MMTDetailedMapPreviewController
{
    // MARK: Helper methods
    fileprivate func lockUserInterface(_ lock: Bool)
    {        
        switch lock
        {
            case true: displayActivityIndicator(in: view, message: MMTLocalizedString("label.loading.meteorogram"))
            case false: hideActivityIndicator()
        }
        
        slider.isEnabled = !lock
        scrollView.isUserInteractionEnabled = !lock
    }
    
    fileprivate func displayErrorAlert(_ error: MMTError)
    {
        let alert = UIAlertController.alertForMMTError(error){ _ in
            self.perform(segue: .UnwindToListOfDetailedMaps, sender: self)
        }
        
        hideActivityIndicator()
        present(alert, animated: true, completion: nil)
    }
}

extension MMTDetailedMapPreviewController: MMTModelControllerDelegate
{
    func onModelUpdate(_ controller: MMTModelController)
    {
        lockUserInterface(modelController.requestPending)
        
        if let error = modelController.error {
            displayErrorAlert(error)
            return
        }
        
        guard modelController.requestPending == false else {
            return
        }
        
        setupSlider(with: modelController.momentsCount)
        setupHeader(with: modelController.moment!)
        detailedMapImage.image = modelController.momentImage
    }
}
