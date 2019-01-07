//
//  FavoriteViewController.swift
//  ATC
//
//  Created by Rathinavel, Dhandapani on 19/11/18.
//  Copyright © 2018 Rathinavel, Dhandapani. All rights reserved.
//

import UIKit
import MBProgressHUD
import KSToastView

class FavoriteViewController: UIViewController, EntityProtocol {
    
    @IBOutlet weak var HUD:MBProgressHUD!
    @IBOutlet weak var productButton: SegButton!
    @IBOutlet weak var storeButton: SegButton!
    @IBOutlet weak var filterButton: UIButton!
    @IBOutlet weak var entityContainer: UIView!
    var entityViewController : EntityViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        storeButton.highlightedStateColor()
        productButton.normalStateColor()
        entityContainer.isHidden = false
        storeButtonAction()
        filterButton.imageEdgeInsets = UIEdgeInsets(top: 11, left:11, bottom: 11, right: 11)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if !ATCUserDefaults.isUserLoggedIn() {
            entityContainer.isHidden = true
            showLogInAlert()
        }
        else {
            entityContainer.isHidden = false
        }
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "FavoriteEntityViewController" {
            if let entityViewController = segue.destination as? EntityViewController {
                self.entityViewController = entityViewController
                self.entityViewController?.isFiltered = true
            }
        }
        
        if segue.identifier == "showStore", let store = sender as? Store, let storeViewController = segue.destination as? StoreViewController  {
            storeViewController.store = store
        }
    }
    
    
    
    
    @IBAction func storeButtonAction() {
        self.entityViewController?.entityType = .Store
        self.entityViewController?.collectionView.reloadData()
        self.storeButton.highlightedStateColor()
        self.productButton.normalStateColor()
    }
    
    @IBAction func productButtonAction() {
        self.entityViewController?.entityType = .Product
        self.entityViewController?.collectionView.reloadData()
        self.productButton.highlightedStateColor()
        self.storeButton.normalStateColor()
    }
}

extension FavoriteViewController {
    // MARK: - HUD
    func addHUDToView() {
        //        HUD = MBProgressHUD(view: self.view)
        //
        //        HUD.frame.origin = CGPoint(x: self.view.frame.origin.x/2, y: self.view.frame.origin.y/2)
        //        HUD.frame.size  = CGSize(width: 50, height: 50)
        //        self.view.addSubview(HUD)
        //        HUD.mode = MBProgressHUDMode.indeterminate
        //        HUD.isUserInteractionEnabled = true
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


extension FavoriteViewController {
    func getStores() {
        let urlString = ApiServiceURL.apiInterface(.getStores)
        DispatchQueue.main.async {
            self.showHUD()
        }
        Downloader.getStoreJSONUsingURLSession(url: urlString) { (result, errorString) in
            if let error = errorString {
                self.hideHUD()
                KSToastView.ks_showToast(error)
            }
            else {
                print(result)
                
                if let result = result, let storeDictionaryArray = result["data"] as? Array<Dictionary<String, Any>> {
                    
                    var storeArray = [Store]()
                    
                    for storeDictionary in storeDictionaryArray {
                        let store = Store.init(dictionary: storeDictionary)
                        storeArray.append(store)
                    }
                    self.entityViewController?.stores = storeArray
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


extension UIViewController {
    //MARK: - Custom Actions
    func showLogInAlert() {
//        let alertController = UIAlertController.init(title: "Alert", message: "Kindly log in to proceed furter", preferredStyle: .alert)
        
//        ?let okayAction = UIAlertAction.init(title: "Okay", style: .default) { (action) in
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            appDelegate.tabbarController.selectedViewController = appDelegate.tabbarController.viewControllers?[1]
            NotificationCenter.default.post(name: NotificationConstant.showRegistration, object: nil)
//        }
        
//        alertController.addAction(okayAction)
//
//        self.present(alertController, animated: true, completion: nil)
    }
}
