//
//  MMTUpdateErrorView.swift
//  MeteoWidget
//
//  Created by szostakowskik on 04.07.2018.
//  Copyright © 2018 Kamil Szostakowski. All rights reserved.
//

import UIKit
import MeteoModel
import MeteoUIKit

class MMTUpdateErrorView: UIView
{
    // MARK: Properties    
    @IBOutlet weak var descriptionLabel: UILabel!
    
    // MARK: Initializers
    required init?(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)
    }
    
    override init(frame: CGRect)
    {
        super.init(frame: frame)
        awakeFromNib()
    }    
    
    // MARK: Lifecycle methods
    override func awakeFromNib()
    {
        super.awakeFromNib()
        addFillingSubview(loadFromNib())
    }
}

extension MMTUpdateErrorView: MMTUpdatableView
{
    func updated(with errorType: MMTError) -> MMTUpdateErrorView
    {
        var key = ""        
        switch errorType
        {
            case .locationServicesDisabled: key = "error.widget.locationServicesDisabled"
            default: key = "error.widget.meteorogramFetchFailure"            
        }
                
        descriptionLabel.text = MMTLocalizedString(key)
        return self
    }
}
