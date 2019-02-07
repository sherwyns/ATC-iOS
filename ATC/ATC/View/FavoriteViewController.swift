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
        productButtonAction()
        filterButton.imageEdgeInsets = UIEdgeInsets(top: 11, left:11, bottom: 11, right: 11)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        getProducts() 
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
                var stores = SharedObjects.shared.updateStoresWithFavorite()
                
                stores = stores?.filter{$0.isFavorite == true}
                self.entityViewController?.stores = stores
                self.entityViewController?.isFiltered = true
            }
        }
        
        if segue.identifier == "showStore", let store = sender as? Store, let storeViewController = segue.destination as? StoreViewController  {
            storeViewController.store = store
        }
        
        
        if segue.identifier == "showProductDetail" {
            if let productDetailViewController = segue.destination as? ProductDetailViewController {
                if let products = sender as? [Product] {
                    productDetailViewController.product = products.first
                    var tempProduct = products
                    tempProduct.removeFirst()
                    productDetailViewController.similarProducts = tempProduct
                }
                
            }
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
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.tabbarController.selectedViewController = appDelegate.tabbarController.viewControllers?[1]
        NotificationCenter.default.post(name: NotificationConstant.showRegistration, object: nil)
    }
    
    func performLogIn(favoriteOperation: ATCOperationPayLoad) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.tabbarController.selectedViewController = appDelegate.tabbarController.viewControllers?[1]
        NotificationCenter.default.post(name: NotificationConstant.showRegistration, object: favoriteOperation)
    }
}

extension FavoriteViewController {
    func getProducts() {
        let urlString = ApiServiceURL.apiInterface(.products)
        
        DispatchQueue.main.async {
            UIApplication.shared.isNetworkActivityIndicatorVisible = true
        }
        Downloader.getAnyJSONUsingURLSession(url: urlString) { (result, errorString) in
            if let error = errorString {
                KSToastView.ks_showToast(error)
            }
            else {
                if let result = result, let productDictionaryArray = result as? Array<Dictionary<String, Any>> {
                    var productArray = [Product]()
                    for productDictionary in productDictionaryArray {
                        let product = Product.init(dictionary: productDictionary)
                        productArray.append(product)
                    }
                    
                    //SharedObjects.shared.stores = productArray
                    var products = SharedObjects.shared.updateProductWithFavorite(productsWithoutFavorite: productArray)
                    
                    products = products?.filter{$0.isFavorite == true}
                    
                    self.entityViewController?.products = products
                    
                    var stores = SharedObjects.shared.updateStoresWithFavorite()
                    stores = stores?.filter{$0.isFavorite == true}
                    
                    self.entityViewController?.stores = stores
                    
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
