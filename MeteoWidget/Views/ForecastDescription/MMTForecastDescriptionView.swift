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
        
        var
        components = [String]()
        components.append(prediction.contains(.clouds) ? "Pochmurnie" : "Słonecznie")
        
        if prediction.contains(.strongWind) {
            components.append("silny wiatr")
            iconImage = #imageLiteral(resourceName: "ext-wind")
        }

        if prediction.contains(.rain) {
            components.append("\nmożliwy deszcz")
            iconImage = #imageLiteral(resourceName: "ext-rain")
        }
        else if prediction.contains(.snow) {
            components.append("\nmożliwy śnieg")
            iconImage = #imageLiteral(resourceName: "ext-snow")
        }
        
        icon = iconImage
        startDateText = "Start prognozy: \(startDate)"
        descriptionText = components.joined(separator: ", ")
        city = meteorogram.city.name
    }
}
