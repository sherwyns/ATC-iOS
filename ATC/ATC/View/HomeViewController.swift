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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        filterButton.imageEdgeInsets = UIEdgeInsets(top: 11, left:11, bottom: 11, right: 11)
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        getStores()
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
            parent.showRegistration()
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
            self.showHUD()
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
                    print("B4 \(SharedObjects.shared.favStores?.count)")
                    
                    SharedObjects.shared.stores = storeArray
                    
                    print("After \(SharedObjects.shared.favStores?.count)")
                    
                    SharedObjects.shared.stores = SharedObjects.shared.updateStoresWithFavorite()
                    self.entityViewController?.stores = SharedObjects.shared.stores
                    DispatchQueue.main.async {
                        self.entityViewController?.collectionView.reloadData()
                    }
                    
                }
            }
            
            DispatchQueue.main.async {
                self.hideHUD()
            }
        }
    }
}

