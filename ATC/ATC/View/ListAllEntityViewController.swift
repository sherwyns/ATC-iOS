//
//  ListAllEntityViewController.swift
//  ATC
//
//  Created by Rathinavel, Dhandapani on 07/01/19.
//  Copyright © 2019 Rathinavel, Dhandapani. All rights reserved.
//

import UIKit
import MBProgressHUD
import KSToastView

class ListAllEntityViewController: UIViewController, EntityProtocol {
    
    @IBOutlet weak var headerLabelButton: UIButton!
    @IBOutlet weak var HUD:MBProgressHUD!
    @IBOutlet weak var entityContainer: UIView!
    @IBOutlet weak var backButton: UIButton!
    
    var entityViewController: EntityViewController?
    var stores: [Store]?
    var products: [Product]?
    var entityType = EntityType.Store
    
    let grayColor = UIColor.init(red: 240.0/255.0, green: 240.0/255.0, blue: 240.0/255.0, alpha: 1)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        backButton.imageEdgeInsets = UIEdgeInsets(top: 11, left:11, bottom: 11, right: 11)
        self.view.backgroundColor = grayColor
        if entityType == .Product {
            headerLabelButton.setTitle("Products", for: .normal)
        }
        if entityType == .Store {
            headerLabelButton.setTitle("Stores", for: .normal)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "listAllEntityViewContainer" {
            if let entityViewController = segue.destination as? EntityViewController {
                self.entityViewController = entityViewController
                self.entityViewController?.isFiltered = false
                self.entityViewController?.isFromSearch = true
                self.entityViewController?.entityType = self.entityType
                if entityType == .Product {
                   self.entityViewController?.products = products
                }
                if entityType == .Store {
                    self.entityViewController?.stores = stores
                }
            }
        }
        
        if segue.identifier == "showStore", let store = sender as? Store, let storeViewController = segue.destination as? StoreViewController  {
            storeViewController.store = store
        }
        
        if segue.identifier == "showProductDetail", let productDetailViewController = segue.destination as? ProductDetailViewController {
            if let products = sender as? [Product] {
                productDetailViewController.product = products.first
                var tempProduct = products
                tempProduct.removeFirst()
                productDetailViewController.similarProducts = tempProduct
            }
            
        }
    }
    
    @IBAction func logoutAction() {
        LoginManager.logout()
        
        if let parent = self.parent as? ATCTabBarViewController {
            parent.showRegistration(sender: nil)
        }
    }
}


extension ListAllEntityViewController {
    // MARK: - HUD
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
