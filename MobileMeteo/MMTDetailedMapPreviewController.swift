//
//  MMTDetailedMapPreviewController.swift
//  MobileMeteo
//
//  Created by Kamil on 02.12.2016.
//  Copyright © 2016 Kamil Szostakowski. All rights reserved.
//
// TODO: Check how application handles dates from the future
// TODO: How often the start date of forecast is being refreshed

import UIKit
import Foundation

class MMTDetailedMapPreviewController: UIViewController, UIScrollViewDelegate
{
    // MARK: Properties
    
    @IBOutlet weak var detailedMapImage: UIImageView!
    @IBOutlet weak var slider: UISlider!
    @IBOutlet var activityIndicator: UIView!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var mapTitle: UILabel!
    @IBOutlet weak var momentLabel: UILabel!
    @IBOutlet weak var scrollView: UIScrollView!
    
    var meteorogramStore: MMTDetailedMapsStore!
    var detailedMap: MMTDetailedMap!
    
    private var fetchSequenceStarted = false
    private var fetchSequenceRetryCount = 0
    private var moments: [MMTWamMoment]!

    private var cache: NSCache<NSString, UIImage> {
        return MMTDatabase.instance.detailedMapsCache
    }

    private var notFetchedMoments: [MMTWamMoment]
    {
        return moments.filter(){ cache.object(forKey: key(for: $0.date)) == nil }
    }

    private var detailedMapSize: CGSize {

        let contantSize = meteorogramStore.detailedMapMeteorogramSize
        let legendSize = meteorogramStore.detailedMapMeteorogramLegendSize

        return CGSize(width: contantSize.width-legendSize.width, height: contantSize.height)
    }

    private var meteorogramType: String {
        return meteorogramStore is MMTUmModelStore ? "UM" : "COAMPS"
    }

    // MARK: Overrides
    
    override func viewDidLoad()
    {
        super.viewDidLoad()

        moments = meteorogramStore.getForecastMomentsForMap(detailedMap)

        if moments == nil
        {
            displayErrorAlert(.meteorogramFetchFailure)
        }

        lockUserInterface(true)

        setupHeader()
        setupSlider()
        fetchMeteorogramSequence()
    }

    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)

        setupScrollView()
    }

    // MARK: Setup methods

    private func setupSlider()
    {
        slider.minimumValue = 0
        slider.maximumValue = Float(moments.count-1)
        slider.value = 0
    }

    private func setupScrollView()
    {
        let contentSize = meteorogramStore.detailedMapMeteorogramSize

        scrollView.maximumZoomScale = 1
        scrollView.minimumZoomScale = scrollView.zoomScaleFittingWidth(for: contentSize)
        scrollView.zoomScale = scrollView.zoomScaleFittingWidth(for: detailedMapSize)

        detailedMapImage.updateSizeConstraints(contentSize)
    }

    private func setupHeader()
    {
        mapTitle.text = MMTLocalizedStringWithFormat("detailed-maps.\(detailedMap.rawValue)")
        momentLabel.text = DateFormatter.utcFormatter.string(from: moments.first!.date)
    }

    // MARK: Actions

    @IBAction func onSliderPositionChangeAction(_ sender: UISlider)
    {        
        let index = Int(round(sender.value))
        let moment = moments[index]

        guard let image = cache.object(forKey: key(for: moment.date)) else {

            retryMeteorogramFetchSequenceIfNotStarted()
            return
        }

        momentLabel.text = DateFormatter.utcFormatter.string(from: moment.date)
        detailedMapImage.image = image
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

    private func retryMeteorogramFetchSequenceIfNotStarted()
    {
        if fetchSequenceStarted == false
        {
            fetchSequenceRetryCount += 1
            fetchMeteorogramSequence()
        }
    }

    private func fetchMeteorogramSequence()
    {
        fetchSequenceStarted = true
        var errorCount = 0

        NSLog("XXX: NotFetchedMoments: \(notFetchedMoments.count)")

        meteorogramStore.getMeteorograms(for: notFetchedMoments, map: detailedMap) {
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

            if date == self.moments.first?.date
            {
                self.detailedMapImage.image = image
            }
        }
    }

    // MARK: Helper methods

    private func lockUserInterface(_ lock: Bool)
    {
        if lock == true
        {
            view.addCenteredSubview(view: activityIndicator)
            slider.isEnabled = false
            scrollView.isUserInteractionEnabled = false
            return
        }

        if lock == false
        {
            activityIndicator.removeFromSuperview()
            slider.isEnabled = true
            scrollView.isUserInteractionEnabled = true
            return
        }
    }

    private func displayErrorAlert(_ error: MMTError)
    {
        let alert = UIAlertController.alertForMMTError(error){ (UIAlertAction) -> Void in
            self.performSegue(withIdentifier: MMTSegue.UnwindToListOfDetailedMaps, sender: self)
        }

        present(alert, animated: true, completion: nil)
    }

    private func handleSequenceFetchFinish(errorCount: Int)
    {
        guard fetchSequenceRetryCount < 2 else {
            
            displayErrorAlert(.meteorogramFetchFailure)
            return
        }

        guard cache.object(forKey: key(for: moments[0].date)) != nil else {

            retryMeteorogramFetchSequenceIfNotStarted()
            return
        }

        lockUserInterface(false)

        let errorRatioExceded = errorCount > moments.count/2

        if errorRatioExceded
        {
            displayErrorAlert(.meteorogramFetchFailure)
        }
    }

    private func key(for moment: Date) -> NSString
    {
        return "\(meteorogramType)-\(detailedMap.rawValue)-\(moment)" as NSString
    }
}
