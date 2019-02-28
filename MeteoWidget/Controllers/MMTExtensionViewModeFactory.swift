//
//  MMTViewModeDataSource.swift
//  MeteoWidget
//
//  Created by szostakowskik on 05.07.2018.
//  Copyright © 2018 Kamil Szostakowski. All rights reserved.
//

import MeteoModel
import NotificationCenter

class MMTExtensionViewModeFactory
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
    func build(for model: MMTTodayModelController, with context: NSExtensionContext) -> (UIView, MMTAnalyticsAction)
    {
        guard model.locationServicesEnabled else {
            return (updateErrorView.updated(with: .locationServicesUnavailable), .WidgetDidDisplayErrorNoLocationServices)
        }
        
        guard let meteorogram = model.meteorogram else {
            return (updateErrorView.updated(with: .meteorogramUpdateFailure), .WidgetDidDisplayErrorFetchFailure)
        }
        
        switch context.widgetActiveDisplayMode {
            case .compact: return configureCompactView(for: meteorogram)
            case .expanded: return configureExpandedView(for: meteorogram)
        }
    }    
    
    // MARK: Helper methods
    private func prepare<T: UIView>(view: T) -> T
    {
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }
    
    private func configureCompactView(for meteorogram: MMTMeteorogram) -> (UIView, MMTAnalyticsAction)
    {
        let viewModel = MMTForecastDescriptionView.ViewModel(meteorogram)
        return (forecastDescriptionView.updated(with: viewModel), .WidgetDidDisplayCompact)
    }
    
    private func configureExpandedView(for meteorogram: MMTMeteorogram) -> (UIView, MMTAnalyticsAction)
    {
        return (meteorogramImageView.updated(with: meteorogram.image), .WidgetDidDisplayExpanded)
    }
}
