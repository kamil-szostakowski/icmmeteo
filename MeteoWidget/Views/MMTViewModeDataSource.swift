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
        
        switch ext.widgetActiveDisplayMode {
            case .compact: return configureCompactView(for: model)
            case .expanded: return configureExpandedView(for: model)
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
    
    private func configureCompactView(for model: MMTTodayModelController) -> UIView
    {
        guard let meteorogram = model.meteorogram else {
            return updateErrorView.updated(with: .meteorogramUpdateFailure)
        }
        
        guard let viewModel = MMTForecastDescriptionView.ViewModel(meteorogram) else {
            return updateErrorView.updated(with: .meteorogramUpdateFailure)
        }
        
        return forecastDescriptionView.updated(with: viewModel)
    }
    
    private func configureExpandedView(for model: MMTTodayModelController) -> UIView
    {
        guard let meteorogram = model.meteorogram else {
            return updateErrorView.updated(with: .meteorogramUpdateFailure)
        }
        
        return meteorogramImageView.updated(with: meteorogram.image)
    }
}
