//
//  MMTCityMapPackerController.swift
//  MobileMeteo
//
//  Created by Kamil Szostakowski on 07.09.2015.
//  Copyright (c) 2015 Kamil Szostakowski. All rights reserved.
//

import UIKit
import MapKit
import Foundation
import MeteoModel

class MMTCityAnnotation: NSObject, MKAnnotation
{
    let coordinate: CLLocationCoordinate2D
    
    init(coordinate: CLLocationCoordinate2D)
    {
        self.coordinate = coordinate
        super.init()
    }
}

class MMTCityMapPickerController: UIViewController, MKMapViewDelegate
{
    // MARK: Outlets
    
    @IBOutlet var mapView: MKMapView!
    @IBOutlet var btnClose: UIBarButtonItem!
    @IBOutlet var btnShow: UIBarButtonItem!
    @IBOutlet var navigationBar: UINavigationBar!
    
    // MARK: Properties
    
    private var citiesStore: MMTCitiesStore!
    private var selectedLocation: CLLocation!

    var selectedCity: MMTCityProt?
 
    // MARK: Overrideds
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        btnClose.accessibilityIdentifier = "close"
        btnShow.accessibilityIdentifier = "show"
        navigationBar.accessibilityIdentifier = "select-location-screen"
        
        citiesStore = MMTCitiesStore()
        btnShow.isEnabled = false
        
        setupMapView()
    }    
    
    override var supportedInterfaceOrientations : UIInterfaceOrientationMask
    {
        return UIInterfaceOrientationMask.portrait
    }
    
    // MARK: Setup methods
    
    fileprivate func setupMapView()
    {
        let spanInMeters: CLLocationDistance = 230000
        let centerOfPoland = CLLocationCoordinate2D(latitude: 52.249, longitude: 19.20)
        let region = MKCoordinateRegionMakeWithDistance(centerOfPoland, spanInMeters, spanInMeters)

        mapView.setRegion(region, animated: false)
    }
    
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
        setInteractionEnabled(false)
        
        citiesStore.findCityForLocation(selectedLocation) {
            (city: MMTCityProt?, error: MMTError?) in
            
            guard let aCity = city, error == nil else
            {
                self.present(UIAlertController.alertForMMTError(error!), animated: true, completion: nil)
                self.setInteractionEnabled(true)
                return
            }
            
            self.selectedCity = aCity
            self.perform(segue: .UnwindToListOfCities, sender: self)
        }
    }
    
    // MARK: Helper methods
    
    fileprivate func setInteractionEnabled(_ enabled: Bool)
    {
        btnClose.isEnabled = enabled
        btnShow.isEnabled = enabled
        mapView.isUserInteractionEnabled = enabled
    }
}
