//
//  MMTViewModeDataSource.swift
//  MeteoWidget
//
//  Created by szostakowskik on 05.07.2018.
//  Copyright © 2018 Kamil Szostakowski. All rights reserved.
//

import MeteoModel
import NotificationCenter

class MMTTodayExtensionDataSource
{
    // MARK: Properties
    lazy var meteorogramImageView: UIImageView = {
        return prepare(view: UIImageView(frame: .zero))
    }()
    
    lazy var updateErrorView: MMTUpdateErrorView = {
        return prepare(view: MMTUpdateErrorView(frame: .zero))
    }()
    
    lazy var forecastDescriptionView: MMTForecastDescriptionView = {
        return prepare(view: MMTForecastDescriptionView(frame: .zero))
    }()
    
    // MARK: Interface methods
    func todayExtension(_ ext: NSExtensionContext, viewFor model: MMTTodayModelController) -> UIView
    {
        guard model.locationServicesEnabled else {
            return updateErrorView.updated(with: .locationServicesUnavailable)
        }
        
        guard let meteorogram = model.meteorogram else {
            return updateErrorView.updated(with: .meteorogramUpdateFailure)
        }
        
        switch ext.widgetActiveDisplayMode {
            case .compact: return forecastDescriptionView.updated(with: meteorogram)
            case .expanded: return meteorogramImageView.updated(with: meteorogram.image)
        }
    }
    
    func todayExtension(_ ext: NSExtensionContext, displayModeFor model: MMTTodayModelController) -> NCWidgetDisplayMode
    {
        return model.locationServicesEnabled ? .expanded : .compact
    }
    
    // MARK: Helper methods
    private func prepare<T: UIView>(view: T) -> T
    {
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }
}
