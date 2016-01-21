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
    
    // MARK: Properties
    
    private var citiesStore: MMTCitiesStore!
    private var selectedLocation: CLLocation!
    
    var meteorogramStore: MMTGridClimateModelStore!    
    var selectedCity: MMTCity?
 
    // MARK: Overrideds
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        citiesStore = MMTCitiesStore(db: MMTDatabase.instance)
        btnShow.enabled = false
        
        setupMapView()
    }    
    
    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask
    {
        return UIInterfaceOrientationMask.Portrait
    }
    
    // MARK: Setup methods
    
    private func setupMapView()
    {
        let spanInMeters: CLLocationDistance = 230000
        let centerOfPoland = CLLocationCoordinate2D(latitude: 52.249, longitude: 19.20)
        let region = MKCoordinateRegionMakeWithDistance(centerOfPoland, spanInMeters, spanInMeters)

        mapView.setRegion(region, animated: false)
    }
    
    // MARK: Action methods
    
    @IBAction func longPressDidRecognized(sender: UILongPressGestureRecognizer)
    {
        if sender.state == .Ended
        {
            let pressedPoint = sender.locationInView(mapView)
            let pressedCoordinates = mapView.convertPoint(pressedPoint, toCoordinateFromView: mapView)
            
            selectedLocation = CLLocation(latitude: pressedCoordinates.latitude, longitude: pressedCoordinates.longitude)
            btnShow.enabled = true

            mapView.removeAnnotations(mapView.annotations)
            mapView.addAnnotation(MMTCityAnnotation(coordinate: pressedCoordinates))
        }
    }
    
    @IBAction func didClickCancelButton(sender: UIBarButtonItem)
    {
        selectedCity = nil
    }
    
    @IBAction func didClickShowButton(sender: UIBarButtonItem)
    {
        setInteractionEnabled(false)
        
        citiesStore.findCityForLocation(selectedLocation) {
            (city: MMTCity?, error: MMTError?) in
            
            guard error == nil else
            {
                self.presentViewController(UIAlertController.alertForMMTError(error!), animated: true, completion: nil)
                self.setInteractionEnabled(true)
                return
            }
            
            guard let aCity = city else {
                return
            }
            
            self.selectedCity = aCity
            self.performSegueWithIdentifier(MMTSegue.UnwindToListOfCities, sender: self)
        }
    }
    
    // MARK: Helper methods
    
    private func setInteractionEnabled(enabled: Bool)
    {
        btnClose.enabled = enabled
        btnShow.enabled = enabled
        mapView.userInteractionEnabled = enabled
    }
}