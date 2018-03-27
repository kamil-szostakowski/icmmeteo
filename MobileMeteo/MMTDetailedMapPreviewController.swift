//
//  MMTDetailedMapPreviewController.swift
//  MobileMeteo
//
//  Created by Kamil on 02.12.2016.
//  Copyright © 2016 Kamil Szostakowski. All rights reserved.
//
// TODO: Check how application handles dates from the future

import UIKit
import Foundation
import MeteoModel

class MMTDetailedMapPreviewController: UIViewController, UIScrollViewDelegate, MMTActivityIndicating
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

    private var meteorogramSize: CGSize!
    private var meteorogramLegendSize: CGSize!
    private var fetchSequenceStarted = false
    private var fetchSequenceRetryCount = 0
    private var meteorogramStore: MMTMeteorogramStore!
    private var meteorogram: MMTMapMeteorogram!

    private var detailedMapSize: CGSize {
        return CGSize(width: meteorogramSize.width-meteorogramLegendSize.width, height: meteorogramSize.height)
    }

    // MARK: Overrides
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        setupHeader(with: detailedMap.climateModel.startDate(for: Date()))
        setupMeteorogramStore()
        setupMeteorogramSize()
        fetchMeteorogramSequence()
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

    // MARK: Setup methods
    private func setupSlider(with meteorogram: MMTMapMeteorogram)
    {
        slider.minimumValue = 0
        slider.maximumValue = Float(meteorogram.moments.count-1)
        slider.value = 0
    }
    
    private func setupHeader(with moment: Date)
    {
        mapTitle.text = MMTLocalizedStringWithFormat("detailed-maps.\(detailedMap.type.rawValue)")
        momentLabel.text = DateFormatter.utcFormatter.string(from: moment)
    }
    
    private func setupMeteorogramStore()
    {
        meteorogramStore = MMTMeteorogramStore(model: detailedMap.climateModel)
    }

    private func setupMeteorogramSize()
    {
        meteorogramSize = CGSize(map: detailedMap.climateModel.type)
        meteorogramLegendSize = CGSize(mapLegend: detailedMap.climateModel.type)
    }

    private func setupScrollView()
    {
        scrollView.maximumZoomScale = 1
        scrollView.minimumZoomScale = scrollView.zoomScaleFittingWidth(for: meteorogramSize)
        scrollView.zoomScale = scrollView.zoomScaleFittingWidth(for: detailedMapSize)

        detailedMapImage.updateSizeConstraints(meteorogramSize)
    }
    
    private func configureScreen(with meteorogram: MMTMapMeteorogram, momentIndex: Int)
    {
        guard let image = meteorogram.images[momentIndex] else {
            retryMeteorogramFetchSequenceIfNotStarted()
            return
        }
        
        setupHeader(with: meteorogram.moments[momentIndex])
        detailedMapImage.image = image
    }

    // MARK: Actions
    @IBAction func onSliderPositionChangeAction(_ sender: UISlider)
    {        
        let index = Int(round(sender.value))
        configureScreen(with: meteorogram, momentIndex: index)
    }

    @IBAction func onScrollViewDoubleTapAction(_ sender: UITapGestureRecognizer)
    {        
        scrollView.animateZoom(scale: scrollView.zoomScaleFittingWidth(for: detailedMapSize))
    }

    // MARK: Scroll view methods

    func viewForZooming(in scrollView: UIScrollView) -> UIView?
    {
        return detailedMapImage
    }

    private func fetchMeteorogramSequence()
    {
        lockUserInterface(true)
        fetchSequenceStarted = true
        
        meteorogramStore.meteorogram(for: detailedMap) { (meteorogram: MMTMapMeteorogram?, error: MMTError?) in
            
            self.fetchSequenceStarted = false
            self.meteorogram = meteorogram
            self.lockUserInterface(false)
            
            guard error == nil, meteorogram != nil, self.fetchSequenceRetryCount < 2 else {
                self.displayErrorAlert(error!)
                return
            }
            
            self.setupSlider(with: self.meteorogram)
            self.configureScreen(with: self.meteorogram, momentIndex: 0)
        }
    }

    private func retryMeteorogramFetchSequenceIfNotStarted()
    {
        if fetchSequenceStarted == false
        {
            fetchSequenceRetryCount += 1
            fetchMeteorogramSequence()
        }
    }

    // MARK: Helper methods
    private func lockUserInterface(_ lock: Bool)
    {
        if lock == true
        {
            displayActivityIndicator(in: view, message: MMTLocalizedString("label.loading.meteorogram"))
            slider.isEnabled = false
            scrollView.isUserInteractionEnabled = false
            return
        }

        if lock == false
        {
            hideActivityIndicator()
            slider.isEnabled = true
            scrollView.isUserInteractionEnabled = true
            return
        }
    }

    private func displayErrorAlert(_ error: MMTError)
    {
        let alert = UIAlertController.alertForMMTError(error){ _ in
            self.perform(segue: .UnwindToListOfDetailedMaps, sender: self)
        }

        hideActivityIndicator()
        present(alert, animated: true, completion: nil)
    }
}
