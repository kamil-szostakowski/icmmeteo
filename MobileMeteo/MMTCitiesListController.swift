//
//  MMTModelUmController.swift
//  MobileMeteo
//
//  Created by Kamil Szostakowski on 08.07.2015.
//  Copyright (c) 2015 Kamil Szostakowski. All rights reserved.
//

import UIKit
import Foundation

class MMTCitiesListController: UIViewController, UITableViewDelegate, UISearchBarDelegate
{        
    // MARK: Outlets

    @IBOutlet var topSpacing: NSLayoutConstraint!    
    @IBOutlet var infoBar: UIView!
    @IBOutlet var searchBar: UISearchBar!
    @IBOutlet var tableView: UITableView!
    @IBOutlet var lblForecastLenght: UILabel!
    @IBOutlet var lblForecastStart: UILabel!
        
    // MARK: Properties
    
    var meteorogramStore: MMTGridClimateModelStore!
    
    private var citiesIndex: MMTCitiesIndex!
    private var citiesStore: MMTCitiesStore!
    private var selectedCity: MMTCity?
    
    private let kCurrentLocationKey = "currentLocation"
    
    // MARK: Controller methods
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        citiesIndex = MMTCitiesIndex()
        citiesStore = MMTCitiesStore(db: MMTDatabase.instance)
        
        lblForecastStart.text = "Start prognozy t0: \(NSDateFormatter.shortStyleUtcDatetime(meteorogramStore.forecastStartDate))"        
        lblForecastLenght.text = "Długość prognozy: \(meteorogramStore.forecastLength)h, siatka \(meteorogramStore.gridNodeSize)km"
        
        tableView.tableHeaderView?.frame = CGRectMake(0, 0, view.frame.size.width, searchBar.bounds.height)
    }
    
    override func viewWillAppear(animated: Bool)
    {
        super.viewWillAppear(animated)
        
        searchBarCancelButtonClicked(searchBar)
        citiesStore.addObserver(self, forKeyPath: kCurrentLocationKey, options: .New, context: nil)
    }
    
    override func viewWillDisappear(animated: Bool)
    {
        super.viewWillDisappear(animated)
        citiesStore.removeObserver(self, forKeyPath: kCurrentLocationKey)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?)
    {
        searchBar.text = ""
        
        if (segue.identifier == MMTSegue.DisplayMeteorogram)
        {
            let
            controller = segue.destinationViewController as! MMTMeteorogramController
            controller.meteorogramStore = meteorogramStore
            controller.city = selectedCity
        }
    }
    
    override func observeValueForKeyPath(keyPath: String, ofObject object: AnyObject, change: [NSObject : AnyObject], context: UnsafeMutablePointer<Void>)
    {
        if keyPath == kCurrentLocationKey && searchBar.text == "" {
            citiesStore.getAllCities() { self.displayCities($0) }
        }
    }
    
    // MARK: Actions
    
    @IBAction func unwindToListOfCities(unwindSegue: UIStoryboardSegue)
    {
    }
    
    // MARK: UITableViewDelegate methods
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int
    {
        return citiesIndex.getAllGroups().count
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return citiesIndex.citiesForGroupAtIndex(section).count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        let city = citiesIndex.cityAtIndexPath(indexPath)
        let reuseId = count(city.region)>0 ? "CitiesListCell" : "SpecialListCell"
        let others = citiesIndex.typeForGroupAtIndex(indexPath.section) != .Others
      
        let
        cell = tableView.dequeueReusableCellWithIdentifier(reuseId, forIndexPath: indexPath) as! UITableViewCell
        cell.detailTextLabel?.text = others ? city.region : "Obecna lokalizacja"        
        cell.textLabel!.text = city.name
        
        return cell
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat
    {
        return citiesIndex.typeForGroupAtIndex(section) == .Others ? 0 : 30
    }

    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView?
    {
        if citiesIndex.typeForGroupAtIndex(section) == .Others {
            return nil
        }
        
        let
        header = tableView.dequeueReusableCellWithIdentifier("CitiesListHeader") as! UITableViewCell
        header.textLabel?.text = citiesIndex.labelForGroupAtIndex(section)
        
        return header
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)
    {
        selectedCity = citiesIndex.cityAtIndexPath(indexPath)
        performSegueWithIdentifier(MMTSegue.DisplayMeteorogram, sender: self)
    }
    
    // MARK: UIScrollViewDelegate methods
    
    func scrollViewDidScroll(scrollView: UIScrollView)
    {
        let scrolled = scrollView.contentOffset.y > 0
        let offset: CGFloat = scrolled ? max(-44, -scrollView.contentOffset.y) : 0
        
        self.animateInfoBarScrollWithOffset(offset)
    }
    
    func scrollViewDidEndDragging(scrollView: UIScrollView, willDecelerate decelerate: Bool)
    {
        let offset: CGFloat = scrollView.contentOffset.y > 0 ? -44 : 0
        
        self.animateInfoBarScrollWithOffset(offset)
        
        if scrollView.contentOffset.y < self.searchBar.bounds.height {
            self.tableView.adjustContentOffsetForHeaderOfHeight(self.searchBar.bounds.height)
        }
    }
    
    private func animateInfoBarScrollWithOffset(offset: CGFloat)
    {
        let alpha: CGFloat = offset < 0 ? 0 : 1
        
        if topSpacing.constant != offset
        {
            let animations = { () -> Void in
                self.topSpacing.constant = offset
                self.infoBar.alpha = alpha
                self.view.layoutIfNeeded()
            }
            
            UIView.animateWithDuration(0.2, delay: 0, usingSpringWithDamping: 0.9, initialSpringVelocity: 5, options: nil, animations: animations, completion: nil)
        }
    }    
    
    // MARK: UISearchBarDelegate methods
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String)
    {
        searchBar.setShowsCancelButton(true, animated: true)
        
        if searchBar.text == "" {
            citiesStore.getAllCities() { self.displayCities($0) }
        }
        else {
            citiesStore.getCitiesMatchingCriteria(searchBar.text) { self.displayCities($0) }
        }
    }
    
    func searchBarCancelButtonClicked(searchBar: UISearchBar)
    {
        searchBar.setShowsCancelButton(false, animated: true)
        searchBar.resignFirstResponder()
        searchBar.text = ""
    
        citiesStore.getAllCities() { self.displayCities($0) }
    }
    
    // MARK: Helper methods    
    
    private func displayCities(cities: [MMTCity])
    {
        citiesIndex = MMTCitiesIndex(cities: cities)
        tableView.reloadData()
    }
}