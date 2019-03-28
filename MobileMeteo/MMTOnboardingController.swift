//
//  MMTOnboardingController.swift
//  MobileMeteo
//
//  Created by szostakowskik on 16/03/2019.
//  Copyright © 2019 Kamil Szostakowski. All rights reserved.
//

import UIKit

enum MMTOnboardingSlide: String
{
    case widgetCompact
    case widgetExpanded
    case whatsNext
    case contact
}

class MMTOnboardingController: UIPageViewController, MTPartialCoverPresentationSizing
{
    // MARK: Properties
    lazy var onboardingDelegate: MMTOnboardingDelegate = {
        return MMTOnboardingDelegate(pages: [
            viewController(for: .widgetExpanded),
            viewController(for: .widgetCompact),
            viewController(for: .whatsNext),
            viewController(for: .contact),
        ])
    }()
    
    var desiredHeight: CGFloat = 500
    
    // MARK: Lifecycle methods
    override func viewDidLoad()
    {
        super.viewDidLoad()
        dataSource = onboardingDelegate
        delegate = onboardingDelegate
        
        setViewControllers([onboardingDelegate.pages.first!], direction: .forward, animated: true, completion: nil)
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
    
    // MARK: Helper methods
    func viewController(for slide: MMTOnboardingSlide) -> UIViewController
    {
        return storyboard!.instantiateViewController(withIdentifier: slide.rawValue)
    }
}

class MMTOnboardingDelegate: NSObject, UIPageViewControllerDelegate, UIPageViewControllerDataSource
{
    // MARK: Properties
    private(set) var pages: [UIViewController]
    
    // MARK: Initializers
    init(pages: [UIViewController])
    {
        self.pages = pages
        super.init()
    }
    
    // MARK: Delegate methods
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController?
    {
        guard let index = pages.firstIndex(of: viewController) else { return nil }
        guard index-1 >= 0 else { return nil }
        
        return pages[index-1]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController?
    {
        guard let index = pages.firstIndex(of: viewController) else { return nil }
        guard index+1 < pages.count else { return nil }
        
        return pages[index+1]
    }
    
    func presentationCount(for pageViewController: UIPageViewController) -> Int
    {
        return pages.count
    }
    
    func presentationIndex(for pageViewController: UIPageViewController) -> Int
    {
        guard let controllers = pageViewController.viewControllers else { return 0 }
        guard controllers.count > 0 else { return 0 }
        
        return pages.firstIndex(of: controllers.first!) ?? 0
    }
}
