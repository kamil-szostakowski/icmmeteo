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
    var climateModel: MMTClimateModel!
    var activityIndicator: MMTActivityIndicator!

    private var meteorogramSize: CGSize!
    private var meteorogramLegendSize: CGSize!
    private var fetchSequenceStarted = false
    private var fetchSequenceRetryCount = 0
    private var moments: [Date]!
    private var meteorogramStore: MMTDetailedMapsStore!

    private var cache: NSCache<NSString, UIImage> {
        return MMTDatabase.instance.meteorogramsCache
    }

    private var notFetchedMoments: [Date] {
        return moments.filter(){ cache.object(forKey: key(for: $0)) == nil }
    }

    private var detailedMapSize: CGSize {
        return CGSize(width: meteorogramSize.width-meteorogramLegendSize.width, height: meteorogramSize.height)
    }

    // MARK: Overrides
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        setupMeteorogramStore(for: Date())
        lockUserInterface(true)

        setupHeader()
        setupSlider()
        setupMeteorogramSize()
        fetchForecastStartDate()
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

    private func setupSlider()
    {
        slider.minimumValue = 0
        slider.maximumValue = Float(moments.count-1)
        slider.value = 0
    }
    
    private func setupMeteorogramStore(for date: Date)
    {
        meteorogramStore = MMTDetailedMapsStore(model: climateModel, date: climateModel.startDate(for: Date()))
        moments = meteorogramStore.getForecastMoments(for: detailedMap)
        
        if moments == nil {
            displayErrorAlert(.meteorogramFetchFailure)
        }
    }

    private func setupMeteorogramSize()
    {
        meteorogramSize = CGSize(map: meteorogramStore.climateModel.type)
        meteorogramLegendSize = CGSize(mapLegend: meteorogramStore.climateModel.type)
    }

    private func setupScrollView()
    {
        scrollView.maximumZoomScale = 1
        scrollView.minimumZoomScale = scrollView.zoomScaleFittingWidth(for: meteorogramSize)
        scrollView.zoomScale = scrollView.zoomScaleFittingWidth(for: detailedMapSize)

        detailedMapImage.updateSizeConstraints(meteorogramSize)
    }

    private func setupHeader()
    {
        mapTitle.text = MMTLocalizedStringWithFormat("detailed-maps.\(detailedMap.type.rawValue)")
        momentLabel.text = DateFormatter.utcFormatter.string(from: moments.first!)
    }

    // MARK: Actions

    @IBAction func onSliderPositionChangeAction(_ sender: UISlider)
    {        
        let index = Int(round(sender.value))
        configureScreenWithMoment(at: index)
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

    // MARK: Data update methods
    
    private func fetchForecastStartDate()
    {
        meteorogramStore.getForecastStartDate {(_ date: Date?, _ error: MMTError?) in
            guard let startDate = date else {
                self.displayErrorAlert(.meteorogramFetchFailure)
                return
            }
            self.setupMeteorogramStore(for: startDate)
            self.fetchMeteorogramSequenceIfRequired()
        }
    }

    private func fetchMeteorogramSequenceIfRequired()
    {
        if notFetchedMoments.count == 0
        {
            configureScreenWithMoment(at: 0)
            handleSequenceFetchFinish(errorCount: 0)
            return;
        }

        fetchMeteorogramSequence()
    }

    private func fetchMeteorogramSequence()
    {
        fetchSequenceStarted = true
        var errorCount = 0

        meteorogramStore.getMeteorograms(for: notFetchedMoments, map: detailedMap.type) {
            (image: UIImage?, date: Date?, error: MMTError?, finish: Bool) in

            guard error == nil else
            {
                errorCount += 1
                return
            }

            if finish
            {
                self.fetchSequenceStarted = false
                self.handleSequenceFetchFinish(errorCount: errorCount)
                return
            }

            self.cache.setObject(image!, forKey: self.key(for: date!))

            if date == self.moments.first
            {
                self.configureScreenWithMoment(at: 0)
            }
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

        present(alert, animated: true, completion: nil)
    }

    private func configureScreenWithMoment(at index: Int)
    {
        let moment = moments[index]

        guard let image = cache.object(forKey: key(for: moment)) else {

            retryMeteorogramFetchSequenceIfNotStarted()
            return
        }

        momentLabel.text = DateFormatter.utcFormatter.string(from: moment)
        detailedMapImage.image = image
    }

    private func handleSequenceFetchFinish(errorCount: Int)
    {
        guard fetchSequenceRetryCount < 2 else {
            displayErrorAlert(.meteorogramFetchFailure)
            lockUserInterface(false)
            return
        }

        guard cache.object(forKey: key(for: moments[0])) != nil else {
            retryMeteorogramFetchSequenceIfNotStarted()
            return
        }

        lockUserInterface(false)

        let errorRatioExceded = errorCount > moments.count/2

        if errorRatioExceded {
            displayErrorAlert(.meteorogramFetchFailure)
        }
    }

    private func key(for moment: Date) -> NSString
    {
        return "\(climateModel.type.rawValue)-\(detailedMap.type.rawValue)-\(moment)" as NSString
    }
}
