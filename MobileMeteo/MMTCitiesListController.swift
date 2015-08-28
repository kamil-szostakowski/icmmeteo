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
    
    private var citiesStore: MMTCitiesStore!
    private var capitalCities: [MMTCity]!
    private var favouriteCities: [MMTCity]!
    private var foundCities: [MMTCity]!
    private var selectedCity: MMTCity?
    
    // MARK: Controller methods
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        citiesStore = MMTCitiesStore(db: MMTDatabase.instance)
        
        lblForecastStart.text = "start prognozy t0: \(NSDateFormatter.shortStyleUtcDatetime(meteorogramStore.forecastStartDate))"        
        lblForecastLenght.text = "Długość prognozy: \(meteorogramStore.forecastLength)h, siatka \(meteorogramStore.gridNodeSize)km"
        
        tableView.tableHeaderView?.frame = CGRectMake(0, 0, view.frame.size.width, searchBar.bounds.height)
        displayCities(citiesStore.getAllCities())
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
    
    // MARK: Actions
    
    @IBAction func unwindToListOfCities(unwindSegue: UIStoryboardSegue)
    {
        searchBarCancelButtonClicked(searchBar)
    }
    
    // MARK: UITableViewDelegate methods
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int
    {
        return favouriteCities.count>0 ? 2 : 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        let nonCapitalsCount = favouriteCities.count+foundCities.count
        
        return section==0 && nonCapitalsCount>0 ? nonCapitalsCount : capitalCities.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        let city = cityAtIndexPath(indexPath)
        
        let
        cell = tableView.dequeueReusableCellWithIdentifier("CitiesListCell", forIndexPath: indexPath) as! UITableViewCell
        cell.textLabel!.text = city.name
        cell.detailTextLabel!.text = count(city.region)>0 ? city.region : " "
        
        return cell
    }
    
    func tableView(tableView: UITableView, accessoryButtonTappedForRowWithIndexPath indexPath: NSIndexPath)
    {
        selectedCity = cityAtIndexPath(indexPath)
        performSegueWithIdentifier(MMTSegue.DisplayMeteorogram, sender: self)
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat
    {
        return 24
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView?
    {
        let
        header = tableView.dequeueReusableCellWithIdentifier("CitiesListHeader") as! UITableViewCell
        header.textLabel?.text = titleForSection(section)
        
        return header
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
        let filteredCities = citiesStore.getCitiesMachingCriteria(searchBar.text)
        
        if searchBar.text == "" {
            displayCities(citiesStore.getAllCities())
        }
        else if filteredCities.count>0 {
            displayCities(filteredCities)
        }
        else {
            citiesStore.findCitiesMachingCriteris(searchBar.text) {(cities: [MMTCity]) in self.displayCities(cities) }
        }
    }
    
    func searchBarCancelButtonClicked(searchBar: UISearchBar)
    {
        searchBar.setShowsCancelButton(false, animated: true)
        searchBar.resignFirstResponder()
        searchBar.text = ""
    
        self.displayCities(citiesStore.getAllCities())
    }
    
    // MARK: Helper methods
    
    func displayCities(cities: [MMTCity])
    {
        capitalCities = cities.filter(){ $0.isCapital && !$0.isFavourite }
        favouriteCities = cities.filter(){ $0.isFavourite }
        foundCities = cities.filter(){ !$0.isCapital && !$0.isFavourite }
        
        tableView.reloadData()
    }
    
    func cityAtIndexPath(indexPath: NSIndexPath) -> MMTCity
    {
        if indexPath.section == 0 && favouriteCities.count>0 {
            return favouriteCities[indexPath.row]
        }
        
        if indexPath.section == 0 && foundCities.count>0 {
            return foundCities[indexPath.row]
        }
        
        return capitalCities[indexPath.row]
    }
    
    func titleForSection(section: Int) -> String
    {
        if section == 0 && favouriteCities.count>0 {
            return "Ulubione"
        }
        
        if section == 0 && foundCities.count>0 {
            return "Znalezione"
        }
        
        return "Miasta wojewódzkie"
    }
}