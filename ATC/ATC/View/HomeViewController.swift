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
    
    @IBOutlet weak var HUD:MBProgressHUD!
    @IBOutlet weak var entityContainer: UIView!
    @IBOutlet weak var filterButton: UIButton!
    
    var entityViewController: EntityViewController?
    var stores: [Store]?
    var isFirst:Bool = true
    
    let grayColor = UIColor.init(red: 240.0/255.0, green: 240.0/255.0, blue: 240.0/255.0, alpha: 1)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        filterButton.imageEdgeInsets = UIEdgeInsets(top: 11, left:11, bottom: 11, right: 11)
        self.view.backgroundColor = grayColor
        
        Downloader.retrieveCategories()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if isFirst {
           getStores()
            isFirst = false
        }
        
//
//        SharedObjects.shared.getStoresWithFavorite { (completionStores) in
//            self.stores = completionStores
//            self.entityViewController?.stores = self.stores
//            DispatchQueue.main.async {
//                self.entityViewController?.collectionView.reloadData()
//            }
//        }
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
    func getStores() {
        let urlString = ApiServiceURL.apiInterface(.getStores)
        
        DispatchQueue.main.async {
            UIApplication.shared.isNetworkActivityIndicatorVisible = true
        }
        Downloader.getStoreJSONUsingURLSession(url: urlString) { (result, errorString) in
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

