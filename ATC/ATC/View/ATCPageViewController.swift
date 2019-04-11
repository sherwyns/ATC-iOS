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
            self.getViewController(withIdentifier: "MockHomeViewController"),
            self.getViewController(withIdentifier: "MockStoreViewController"),
            self.getViewController(withIdentifier: "MockStoreDetailViewController"),
            self.getViewController(withIdentifier: "MockFavoriteViewController"),
            self.getViewController(withIdentifier: "ComingSoonViewController")
        ]
    }()
    
    let images = ["ShopHome_Intro", "ShopPageWithProducts_Intro", "Favorites_Intro", "ShopDetails_Intro", "comingSoon_Intro"]
    
    fileprivate func getViewController(withIdentifier identifier: String) -> UIViewController {
       
        let mainStoryBoard = UIStoryboard.init(name: "Main", bundle: nil)
        let appIntroMainStoryBoard = UIStoryboard.init(name: "AppIntro", bundle: nil)
    
        var categoryDictionary =  Dictionary<String, Any>()
        categoryDictionary["id"] = 15
        categoryDictionary["image_url"] = "https://api.aroundthecorner.store/storecategory/speaker.png"
        categoryDictionary["name"] = "Audio Equipment"
        
        var storeDictionary = Dictionary<String, Any>()
        storeDictionary["business_type"] = 2
        storeDictionary["id"] = 23
        storeDictionary["image"] = "https://api.aroundthecorner.store/images/store_1549060043915.png"
        storeDictionary["neighbourhood"] = "South Lake Union"
        storeDictionary["business_type"] = 2
        storeDictionary["shop_name"] = "Lioz Clothiers"
        storeDictionary["store_url"] = "www.turntablestrails.com"
        storeDictionary["category"] = categoryDictionary
        storeDictionary["description"] = "Women's boutique carrying stylish apparel, jewelry & accessories from area designers. Many top brands are available at this thrift store."
        storeDictionary["phonenumber"] = "+91 1800 0000"
        
        let store = Store.init(dictionary: storeDictionary)
        
        if identifier == "ComingSoonViewController" {
            let comingSoonViewController = appIntroMainStoryBoard.instantiateViewController(withIdentifier: "ComingSoonViewController") as! ComingSoonViewController
            return comingSoonViewController
        }
        
        if identifier == "MockHomeViewController" {
            let mockHomeviewController = appIntroMainStoryBoard.instantiateViewController(withIdentifier: "MockHomeViewController") as! MockHomeViewController
            return mockHomeviewController
        }
        
        if identifier == "MockStoreViewController" {
            let mockStoreViewController = appIntroMainStoryBoard.instantiateViewController(withIdentifier: "MockStoreViewController") as! MockStoreViewController
            mockStoreViewController.store = store
            return mockStoreViewController
        }
        
        if identifier == "MockStoreDetailViewController" {
            let mockStoreDetailViewController = appIntroMainStoryBoard.instantiateViewController(withIdentifier: "MockStoreDetailViewController") as! MockStoreDetailViewController
            mockStoreDetailViewController.store = store
            return mockStoreDetailViewController
        }
        
        if identifier == "MockFavoriteViewController" {
            let mockFavoriteViewController = appIntroMainStoryBoard.instantiateViewController(withIdentifier: "MockFavoriteViewController") as! MockFavoriteViewController
            //mockFavoriteViewController.store = store
            return mockFavoriteViewController
        }
        
        return UIViewController()
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
