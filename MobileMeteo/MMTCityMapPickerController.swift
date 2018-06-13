//
//  MMTCityMapPackerController.swift
//  MobileMeteo
//
//  Created by Kamil Szostakowski on 07.09.2015.
//  Copyright (c) 2015 Kamil Szostakowski. All rights reserved.
//

import MapKit
import Foundation
import MeteoModel

class MMTCityMapPickerController: UIViewController
{
    // MARK: Outlets
    @IBOutlet var mapView: MKMapView!
    @IBOutlet var btnClose: UIBarButtonItem!
    @IBOutlet var btnShow: UIBarButtonItem!
    @IBOutlet var navigationBar: UINavigationBar!
    
    // MARK: Properties
    private var modelController: MMTCurrentCityModelController!
    private var selectedLocation: CLLocation!

    var selectedCity: MMTCityProt?
 
    // MARK: Lifecycle methods
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        setupButtons()
        setupModelController()
        setupMapView()
    }    
    
    override var supportedInterfaceOrientations : UIInterfaceOrientationMask
    {
        return UIInterfaceOrientationMask.portrait
    }
}

extension MMTCityMapPickerController
{
    // MARK: Setup methods
    fileprivate func setupMapView()
    {
        let spanInMeters: CLLocationDistance = 230000
        let centerOfPoland = CLLocationCoordinate2D(latitude: 52.249, longitude: 19.20)
        let region = MKCoordinateRegionMakeWithDistance(centerOfPoland, spanInMeters, spanInMeters)
        
        mapView.setRegion(region, animated: false)
    }
    
    fileprivate func setInteractionEnabled(_ enabled: Bool)
    {
        btnClose.isEnabled = enabled
        btnShow.isEnabled = enabled
        mapView.isUserInteractionEnabled = enabled
    }
    
    fileprivate func setupButtons()
    {
        btnClose.accessibilityIdentifier = "close"
        navigationBar.accessibilityIdentifier = "select-location-screen"
        btnShow.accessibilityIdentifier = "show"
        btnShow.isEnabled = false
    }
    
    fileprivate func setupModelController()
    {
        modelController = MMTCurrentCityModelController(store: MMTCoreDataCitiesStore())
        modelController.delegate = self
    }
}

extension MMTCityMapPickerController: MMTModelControllerDelegate
{
    // MARK: Action methods
    @IBAction func longPressDidRecognized(_ sender: UILongPressGestureRecognizer)
    {
        if sender.state == .ended
        {
            let pressedPoint = sender.location(in: mapView)
            let pressedCoordinates = mapView.convert(pressedPoint, toCoordinateFrom: mapView)
            
            selectedLocation = CLLocation(latitude: pressedCoordinates.latitude, longitude: pressedCoordinates.longitude)
            btnShow.isEnabled = true
            
            mapView.removeAnnotations(mapView.annotations)
            mapView.addAnnotation(MMTCityAnnotation(coordinate: pressedCoordinates))
        }
    }
    
    @IBAction func didClickCancelButton(_ sender: UIBarButtonItem)
    {
        selectedCity = nil
    }
    
    @IBAction func didClickShowButton(_ sender: UIBarButtonItem)
    {
        modelController.onLocationChange(location: selectedLocation)
    }
    
    func onModelUpdate(_ controller: MMTModelController)
    {
        setInteractionEnabled(!modelController.requestPending)
        
        guard modelController.error == nil else {
            present(UIAlertController.alertForMMTError(modelController.error!), animated: true, completion: nil)
            return
        }
        
        guard modelController.requestPending == false else {
            return
        }
        
        selectedCity = modelController.currentCity
        perform(segue: .UnwindToListOfCities, sender: self)
    }
}
