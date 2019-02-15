//
//  MMTForecastDescription.swift
//  MeteoWidget
//
//  Created by szostakowskik on 04.07.2018.
//  Copyright © 2018 Kamil Szostakowski. All rights reserved.
//

import UIKit
import MeteoModel
import MeteoUIKit

class MMTForecastDescriptionView: UIView
{
    struct ViewModel
    {
        var icon: UIImage
        var startDateText: String
        var descriptionText: String
        var city: String
    }
    
    // MARK: Properties
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet var startDateLabel: UILabel!
    @IBOutlet var descriptionLabel: UILabel!
    @IBOutlet weak var cityNameLabel: UILabel!
    
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
    func updated(with description: MMTForecastDescriptionView.ViewModel) -> MMTForecastDescriptionView
    {
        iconImageView.image = description.icon
        startDateLabel.text = description.startDateText
        descriptionLabel.text = description.descriptionText
        cityNameLabel.text = description.city
        
        return self
    }
}

extension MMTForecastDescriptionView.ViewModel
{
    init?(_ meteorogram: MMTMeteorogram)
    {
        guard let prediction = try? meteorogram.prediction() else {
            return nil
        }
        
        let startDate = DateFormatter.utcFormatter.string(from: meteorogram.startDate)
        var iconImage = #imageLiteral(resourceName: "ext-sunny")
        var components = [String]()
        
        if prediction.contains(.clouds) {
            components.append(MMTLocalizedString("widget.cloudy"))
            iconImage = #imageLiteral(resourceName: "ext-cloudy")
        } else {
            components.append(MMTLocalizedString("widget.sunny"))
        }
        
        if prediction.contains(.strongWind) {
            components.append(MMTLocalizedString("widget.windy"))
            iconImage = #imageLiteral(resourceName: "ext-wind")
        }

        if prediction.contains(.rain) {
            components.append(MMTLocalizedString("widget.rainy"))
            iconImage = #imageLiteral(resourceName: "ext-rain")
        }
        else if prediction.contains(.snow) {
            components.append(MMTLocalizedString("widget.snowy"))
            iconImage = #imageLiteral(resourceName: "ext-snow")
        }
        
        icon = iconImage
        startDateText = MMTLocalizedStringWithFormat("widget.forecast.start: %@", startDate)
        descriptionText = components.joined(separator: ", ")
        city = meteorogram.city.name
    }
}
