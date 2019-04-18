//
//  HomeViewController.swift
//  ATC
//
//  Created by Rathinavel, Dhandapani on 19/11/18.
//  Copyright © 2018 Rathinavel, Dhandapani. All rights reserved.
//

import UIKit
import MBProgressHUD
import KSToastView

class HomeViewController: UIViewController, EntityProtocol {
    
    @IBOutlet var HUD:MBProgressHUD!
    @IBOutlet weak var entityContainer: UIView!
    @IBOutlet weak var filterButton: UIButton!
    @IBOutlet weak var badgeViewLabel: UILabel!
    
    var entityViewController: EntityViewController?
    var stores: [Store]?
    var isFirst:Bool = true
    
    let grayColor = UIColor.init(red: 240.0/255.0, green: 240.0/255.0, blue: 240.0/255.0, alpha: 1)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        filterButton.imageEdgeInsets = UIEdgeInsets(top: 11, left:11, bottom: 11, right: 11)
        self.view.backgroundColor = grayColor
        
        Downloader.retrieveCategories()
        
        badgeViewLabel.layer.cornerRadius = badgeViewLabel.frame.size.width / 2
        badgeViewLabel.layer.masksToBounds = true
        badgeViewLabel.backgroundColor = .orange
        badgeViewLabel.textColor = .white
        badgeViewLabel.isHidden = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if !ATCUserDefaults.isAppWalkthroughDone() {
            self.performSegue(withIdentifier: "AppIntro", sender: nil)
        }
        
        if SharedObjects.shared.canReloadStore {
           getStores()
            SharedObjects.shared.canReloadStore = false
        }
        else {
            self.entityViewController?.collectionView.reloadData()
        }
        
        if appliedFilterCount() > 0 {
            self.badgeViewLabel.text = String(appliedFilterCount())
            self.badgeViewLabel.isHidden = false
        } else {
            self.badgeViewLabel.isHidden = true
        }
    }
    
    func appliedFilterCount() -> Int {
       return SharedObjects.shared.categoryIds.count + SharedObjects.shared.neighbourhoods.count
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "HomeEntityViewController" {
            if let entityViewController = segue.destination as? EntityViewController {
                self.entityViewController = entityViewController
                self.entityViewController?.isFiltered = false
            }
        }
        
        if segue.identifier == "showStore", let store = sender as? Store, let storeViewController = segue.destination as? StoreViewController  {
            storeViewController.store = store
        }
    }
    
    @IBAction func logoutAction() {
        LoginManager.logout()
        
        if let parent = self.parent as? ATCTabBarViewController {
            parent.showRegistration(sender: nil)
        }
    }
}


extension HomeViewController {
    // MARK: - HUD
    func addHUDToView() {
        //        HUD = MBProgressHUD(view: self.view)
        //
        //        HUD.frame.origin = CGPoint(x: self.view.frame.origin.x/2, y: self.view.frame.origin.y/2)
        //        HUD.frame.size  = CGSize(width: 50, height: 50)
        //        self.view.addSubview(HUD)
        //        HUD.mode = MBProgressHUDMode.indeterminate
        //        HUD.isUserInteractionEnabled = true
        
        HUD = MBProgressHUD(view: self.view)
        self.view.addSubview(HUD)
        HUD.frame.origin = CGPoint(x: self.view.frame.origin.x/2, y: self.view.frame.origin.y/2)
        HUD.frame.size  = CGSize(width: 50, height: 50)
        
        HUD.mode = MBProgressHUDMode.indeterminate
        HUD.isUserInteractionEnabled = true
    }
    func showHUD(){
        DispatchQueue.main.async(execute: { () -> Void in
            self.HUD.show(animated: true)
        })
    }
    
    func hideHUD(){
        DispatchQueue.main.async(execute: { () -> Void in
            self.HUD.hide(animated: true)
        })
    }
}

extension HomeViewController {
    
    func createGetStoreURLWithComponents() -> URL? {
        
        var queryItems = [URLQueryItem]()
        
        let urlComponents = NSURLComponents()
        urlComponents.scheme = "https"
        urlComponents.host = "api.aroundthecorner.store"
        urlComponents.path = "/api/store/getstores"
        
        let tempNeighbourhoods = SharedObjects.shared.neighbourhoods.filter { $0 != "All"}
        let neighbourhood = concatenateString(array: tempNeighbourhoods)
        
        
        let tempCategoryIds = SharedObjects.shared.categoryIds.filter { $0 != "-1"}
        let categoryIds =  concatenateString(array: tempCategoryIds)
        
        let neighbourhoodQuery = URLQueryItem(name: "neighbourhood", value: neighbourhood)
        queryItems.append(neighbourhoodQuery)
        
        let categoryIdQuery    = URLQueryItem(name: "category", value: categoryIds)
        queryItems.append(categoryIdQuery)
        
        
        if let latitude = SharedObjects.shared.location?.coordinate.latitude {
            let latitudeQuery      = URLQueryItem(name: "latitude", value: String(latitude))
            queryItems.append(latitudeQuery)
        }
        
        if let longitude = SharedObjects.shared.location?.coordinate.longitude {
            let longitudeQuery  = URLQueryItem(name: "longitude", value: String(longitude))
            queryItems.append(longitudeQuery)
        }
        
        urlComponents.queryItems = queryItems
        print("filter url \(urlComponents.url)")
        return urlComponents.url
    }
    
    func concatenateString(array : [String]) -> String {
        if array.count == 1 {
            return array[0]
        } else {
            var appendedString = String()
            
            for (index, element) in array.enumerated() {
                let total = array.count - 1
                
                if  total == index {
                    appendedString = appendedString + element
                } else {
                    appendedString = appendedString + element + ","
                }
            }
            return appendedString
        }
        
    }
    
    func getStores() {
        guard let url = createGetStoreURLWithComponents() else {
            return
        }
        
        DispatchQueue.main.async {
            UIApplication.shared.isNetworkActivityIndicatorVisible = true
        }
        Downloader.getStoreJSONUsingURLSession(serviceUrl: url) { (result, errorString) in
            if let error = errorString {
                KSToastView.ks_showToast(error)
            }
            else {
                if let result = result, let storeDictionaryArray = result["data"] as? Array<Dictionary<String, Any>> {
                    var storeArray = [Store]()
                    for storeDictionary in storeDictionaryArray {
                        let store = Store.init(dictionary: storeDictionary)
                        storeArray.append(store)
                    }
                    
                    SharedObjects.shared.stores = storeArray
                    SharedObjects.shared.stores = SharedObjects.shared.updateStoresWithFavorite()
                    
                    if let _ = SharedObjects.shared.categoryId {
                        if SharedObjects.shared.storesWithFilter().count == 0 {
                            KSToastView.ks_showToast("No shops found", duration: 3.0)
                        }
                        self.entityViewController?.stores = SharedObjects.shared.storesWithFilter()
                    }
                    else {
                        if let stores = SharedObjects.shared.stores, stores.count == 0 {
                            KSToastView.ks_showToast("No shops found", duration: 3.0)
                        }
                        self.entityViewController?.stores = SharedObjects.shared.stores
                    }
                    DispatchQueue.main.async {
                        self.entityViewController?.collectionView.reloadData()
                    } 
                }
            }
            
            DispatchQueue.main.async {
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
            }
        }
    }
}

