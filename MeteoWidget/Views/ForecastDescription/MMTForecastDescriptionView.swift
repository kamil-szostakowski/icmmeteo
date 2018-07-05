//
//  MMTForecastDescription.swift
//  MeteoWidget
//
//  Created by szostakowskik on 04.07.2018.
//  Copyright © 2018 Kamil Szostakowski. All rights reserved.
//

import UIKit
import MeteoModel

class MMTForecastDescriptionView: UIView
{
    // MARK: Properties
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet var startDateLabel: UILabel!
    @IBOutlet var descriptionLabel: UILabel!
    
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

extension MMTForecastDescriptionView: MMTUpdatableView
{
    func updated(with meteorogram: MMTMeteorogram) -> MMTForecastDescriptionView
    {
        let startDate = DateFormatter.utcFormatter.string(from: meteorogram.startDate)
        
        iconImageView.image = #imageLiteral(resourceName: "ext-sunny")
        startDateLabel.text = "Start prognozy: \(startDate)"
        descriptionLabel.text = "Pochmurnie, możliwe opady"
        return self
    }
}
