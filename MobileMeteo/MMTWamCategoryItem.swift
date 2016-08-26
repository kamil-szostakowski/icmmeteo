//
//  MMTWamCategoryItem.swift
//  MobileMeteo
//
//  Created by Kamil Szostakowski on 20.07.2015.
//  Copyright (c) 2015 Kamil Szostakowski. All rights reserved.
//

import UIKit
import Foundation

class MMTWamCategoryItem: UICollectionViewCell
{
    @IBOutlet var map: UIImageView!
    @IBOutlet var headerLabel: UILabel!
    @IBOutlet var footerLabel: UILabel!
    @IBOutlet var activityIndicator: UIActivityIndicatorView!
    
    override func awakeFromNib()
    {
        super.awakeFromNib()
        map.addObserver(self, forKeyPath: "image", options: .new, context: nil)
    }
    
    override func prepareForReuse()
    {
        map.image = nil
        headerLabel.text = ""
        footerLabel.text = ""
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?)
    {
        if keyPath == "image" && change != nil {
            enableActivityIndicator(change![.oldKey] is NSNull)
        }
    }
    
    deinit
    {
        map.removeObserver(self, forKeyPath: "image")
    }
    
    // MARK: Helper methods
    
    fileprivate func enableActivityIndicator(_ enabled: Bool)
    {
        activityIndicator.isHidden = !enabled

        if enabled
        {
            activityIndicator.startAnimating()
        }
        else
        {
            activityIndicator.stopAnimating()
        }
    }
}
