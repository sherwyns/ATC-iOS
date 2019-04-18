//
//  MockFavoriteViewController.swift
//  ATC
//
//  Created by Rathinavel, Dhandapani on 08/04/19.
//  Copyright © 2019 Rathinavel, Dhandapani. All rights reserved.
//

import UIKit



class MockFavoriteViewController: UIViewController, EntityProtocol {
    
    @IBOutlet weak var productButton: SegButton!
    @IBOutlet weak var storeButton: SegButton!
    @IBOutlet weak var filterButton: UIButton!
    @IBOutlet weak var entityContainer: UIView!
    var entityViewController : EntityViewController?
    
    @IBOutlet weak var topConstraint: NSLayoutConstraint!
    @IBOutlet weak var rightConstraint: NSLayoutConstraint!
    @IBOutlet weak var leftConstraint: NSLayoutConstraint!
    @IBOutlet weak var imageViewRightConstant: NSLayoutConstraint!
    @IBOutlet weak var imageViewHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var imageViewTopConstraint: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        storeButton.highlightedStateColor()
        productButton.normalStateColor()
        entityContainer.isHidden = false
        productButtonAction()
        
        let height = (self.view.frame.size.width * 0.35) * 0.40
        let rightConstriant = (self.view.frame.size.width * 0.35) * 0.25
        self.imageViewHeightConstraint.constant = height
        self.topConstraint.constant = self.view.frame.size.height * 0.69
        self.imageViewTopConstraint.constant = self.view.frame.size.height * 0.65 - (height / 2)
        self.leftConstraint.constant = self.view.frame.size.width * 0.1576
        self.imageViewRightConstant.constant = rightConstriant
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "FavoriteEntityViewController" {
            if let entityViewController = segue.destination as? EntityViewController {
                self.entityViewController = entityViewController
                var stores = SharedObjects.shared.updateStoresWithFavorite()
                
                stores = stores?.filter{$0.isFavorite == true}
                
                if let path = Bundle.main.path(forResource: "product", ofType: "json") {
                    do {
                        let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
                        let jsonResult = try JSONSerialization.jsonObject(with: data, options: [.allowFragments]) as? Dictionary<String, AnyObject?>
                        if let result = jsonResult, let productDictionaryArray = result["data"] as? Array<Dictionary<String, Any>> {
                            var productArray = [Product]()
                            for productDictionary in productDictionaryArray {
                                let product = Product.init(dictionary: productDictionary)
                                product.isFavorite = true
                                productArray.append(product)
                            }

                             self.entityViewController?.products = productArray

                            DispatchQueue.main.async {
                                //self.entityViewController?.collectionView.reloadData()
                            }
                        }
                    } catch {
                        // handle error
                    }
                }
                self.entityViewController?.isMock = true
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

