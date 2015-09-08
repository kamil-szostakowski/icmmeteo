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
    var selectedCity: MMTCity!
 
    // MARK: Overrideds
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        citiesStore = MMTCitiesStore(db: MMTDatabase.instance)
        
        setupMapView()
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?)
    {
        if (segue.identifier == MMTSegue.DisplayMeteorogram)
        {
            let
            controller = segue.destinationViewController as! MMTMeteorogramController
            controller.meteorogramStore = meteorogramStore
            controller.city = selectedCity
        }
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

            mapView.removeAnnotations(mapView.annotations)
            mapView.addAnnotation(MMTCityAnnotation(coordinate: pressedCoordinates))
        }
    }
    
    @IBAction func didClickShowButton(sender: UIBarButtonItem)
    {
        if mapView.annotations.count == 1
        {
            btnClose.enabled = false
            btnShow.enabled = false
            mapView.userInteractionEnabled = false
            
            citiesStore.findCityForLocation(selectedLocation)
            {                
                self.selectedCity = $0 != nil ? $0! : MMTCity(name: "", region: "", location: self.selectedLocation)
                self.performSegueWithIdentifier(MMTSegue.DisplayMeteorogram, sender: self)
            }
        }
        
        else
        {
            UIAlertView(title: nil, message: "Wybierz lokalizację dla której chcesz zobaczyć meteorogram.", delegate: nil, cancelButtonTitle: "Zamknij").show()
        }
    }
}