//
//  ATCPageViewController.swift
//  ATC
//
//  Created by Rathinavel, Dhandapani on 05/04/19.
//  Copyright © 2019 Rathinavel, Dhandapani. All rights reserved.
//

import UIKit

class ATCPageViewController: UIPageViewController {
    
    weak var appIntroViewController: AppIntroViewController?
    
     var currentIndex = 0
    
    var pendingIndex: Int = 0
    
    fileprivate lazy var pages: [UIViewController] = {
        return [
            self.getViewController(withIdentifier: "IntroViewController", imageName: "ShopHome_Intro"),
            self.getViewController(withIdentifier: "IntroViewController", imageName: "ShopPageWithProducts_Intro"),
            self.getViewController(withIdentifier: "IntroViewController", imageName: "Favorites_Intro"),
            self.getViewController(withIdentifier: "IntroViewController", imageName: "ShopDetails_Intro"),
            self.getViewController(withIdentifier: "IntroViewController", imageName: "comingSoon_Intro")
        ]
    }()
    
    let images = ["ShopHome_Intro", "ShopPageWithProducts_Intro", "Favorites_Intro", "ShopDetails_Intro", "comingSoon_Intro"]
    
    fileprivate func getViewController(withIdentifier identifier: String, imageName: String) -> UIViewController {
        let introViewController = UIStoryboard(name: "AppIntro", bundle: nil).instantiateViewController(withIdentifier: identifier) as! IntroViewController
        
        let _ = introViewController.view
        
        introViewController.imageView.image = UIImage.init(named: imageName)
        return introViewController
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.dataSource = self
        self.delegate   = self
        
        if let firstVC = pages.first {
            setViewControllers([firstVC], direction: .forward, animated: true, completion: nil)
        }
    }
}

extension ATCPageViewController: UIPageViewControllerDataSource
{
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        
        guard let currentIndex = pages.index(of: viewController) else { return nil }
        if currentIndex == 0 {
            return nil
        }
        let previousIndex = abs((currentIndex - 1) % pages.count)
        return pages[previousIndex]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController?
    {
        guard let currentIndex = pages.index(of: viewController) else { return nil }
        
        if currentIndex == pages.count-1 {
            return nil
        }
        let nextIndex = abs((currentIndex + 1) % pages.count)
        return pages[nextIndex]
    }
}

extension ATCPageViewController: UIPageViewControllerDelegate {
    func pageViewController(_ pageViewController: UIPageViewController, willTransitionTo pendingViewControllers: [UIViewController]) {
         pendingIndex = pages.lastIndex(of: pendingViewControllers.first!)!
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        if completed {
            currentIndex = pendingIndex
            appIntroViewController?.pageControl.currentPage = currentIndex
            
            if currentIndex == 4 {
                appIntroViewController?.skipButton.setTitle("Done", for: .normal)
            } else {
                appIntroViewController?.skipButton.setTitle("Skip", for: .normal)
            }
            
        }
    }
}
