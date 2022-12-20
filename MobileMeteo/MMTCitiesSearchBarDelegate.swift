//
//  MMTCitiesSearchBarDelegate.swift
//  MobileMeteo
//
//  Created by szostakowskik on 07.06.2018.
//  Copyright © 2018 Kamil Szostakowski. All rights reserved.
//

import UIKit
import Foundation
import MeteoModel

class MMTCitiesSearchBarDelegate: NSObject, UISearchBarDelegate
{
    // MARK: Properties
    private var onSearch: (String?) -> Void
    
    // MARK: Initializers
    init(handler: @escaping (String?) -> Void)
    {
        onSearch = handler
        super.init()
    }
    
    // MARK: UISearchBarDelegate methods
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar)
    {
        searchBar.setShowsCancelButton(true, animated: true)
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String)
    {
        searchBar.text = MMTSearchInput(searchText).stringValue
        onSearch(searchBar.text)
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar)
    {
        searchBar.reset()
        onSearch(nil)
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar)
    {
        onSearch(nil)
    }
}

extension UISearchBar
{
    func reset()
    {
        resignFirstResponder()
        setShowsCancelButton(false, animated: true)
        text = ""
    }
}
