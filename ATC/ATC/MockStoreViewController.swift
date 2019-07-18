//
//  MockStoreViewController.swift
//  ATC
//
//  Created by Rathinavel, Dhandapani on 05/04/19.
//  Copyright © 2019 Rathinavel, Dhandapani. All rights reserved.
//

import UIKit

class MockStoreViewController: UIViewController {
    
    @IBOutlet weak var headerContainer: UIView!
    @IBOutlet weak var storeContainer: UIView!
    @IBOutlet weak var favoriteButton: UIButton!
    @IBOutlet weak var categoryContainer: UIView!
    @IBOutlet weak var categoryListContainer: UIView!
    @IBOutlet weak var categoryCollectionView: UICollectionView!
    @IBOutlet weak var storeName: UILabel!
    @IBOutlet weak var storeNeighbourhood: UILabel!
    @IBOutlet weak var headerStoreLabel: UIButton!
    @IBOutlet weak var productCategoryLabel: UILabel!
    @IBOutlet weak var categoryImageView: UIImageView!
    
    @IBOutlet weak var topConstraint: NSLayoutConstraint!
    @IBOutlet weak var rightConstraint: NSLayoutConstraint!
    @IBOutlet weak var leftConstraint: NSLayoutConstraint!
    @IBOutlet weak var imageViewRightConstant: NSLayoutConstraint!
    @IBOutlet weak var imageViewHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var imageViewTopConstraint: NSLayoutConstraint!
    
    
    var entityViewController: EntityViewController?
    var store:Store!
    var selectedIndex = 0
    
    let kCATEGORY_CELL = "CategoryCell"
    let kCATEGORY_HIGHLIGHT_CELL = "CategoryHighlightCell"
    
    let grayColor = UIColor.init(red: 240.0/255.0, green: 240.0/255.0, blue: 240.0/255.0, alpha: 1)
    
    fileprivate let sectionInsets = UIEdgeInsets(top: 10.0, left: 8.0, bottom: 10.0, right: 8.0)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        customizeViews()
        registerCollectionViewCells()
        self.categoryCollectionView.dataSource = self
        self.categoryCollectionView.delegate = self
        
        self.storeName.text = store.name
        self.headerStoreLabel.setTitle(store.name, for: .normal)
        self.storeNeighbourhood.text = store.neighbourhood
        
        self.hideOrShowCategory()
        
        var analyticsStoreDictionary = Dictionary<String, Any>()
        analyticsStoreDictionary["store_id"] = store.storeId
        let analyticsUrl = ApiServiceURL.apiInterface(.storeimpression)
        
        Downloader.updateJSONUsingURLSessionPOSTRequestForAnalytics(url: analyticsUrl, parameters: analyticsStoreDictionary) { (result, errorString) in
            
        }
        
        self.getProductByStore()
        
        let height = (self.view.frame.size.width * 0.35) * 0.40
        let rightConstriant = (self.view.frame.size.width * 0.35) * 0.25
        self.imageViewHeightConstraint.constant = height
        self.topConstraint.constant = self.view.frame.size.height * 0.73
        self.imageViewTopConstraint.constant = self.view.frame.size.height * 0.65 - (height / 2)
        self.leftConstraint.constant = self.view.frame.size.width * 0.1576
        self.imageViewRightConstant.constant = rightConstriant
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        updateStoreFavorite()
        self.updateFavoriteButton()
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.store.categories = Array<Category>( self.store.categories.dropFirst()) as Array<Category>
    }
    
    func updateStoreFavorite() {
        if let favStores = SharedObjects.shared.favStores {
            for storeFavorite in favStores {
                if storeFavorite.storeId == self.store.storeId {
                    self.store.isFavorite = storeFavorite.isFavorite
                    break
                }
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ProductEntityViewController" {
            if let entityViewController = segue.destination as? EntityViewController {
                self.entityViewController = entityViewController
                self.entityViewController?.isFiltered = false
                self.entityViewController?.entityType = .Product
                self.entityViewController?.isMock = true
                if let _ = self.entityViewController?.view {
                    self.entityViewController?.collectionView.backgroundColor = grayColor
                }
            }
        }
        
        if segue.identifier == "showStoreDetail" {
            if let storeDetailViewController = segue.destination as? StoreDetailViewController {
                storeDetailViewController.store = self.store
            }
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
    
    func registerCollectionViewCells() {
        self.categoryCollectionView.register(UINib.init(nibName: kCATEGORY_CELL, bundle: nil), forCellWithReuseIdentifier: kCATEGORY_CELL)
        self.categoryCollectionView.register(UINib.init(nibName: kCATEGORY_HIGHLIGHT_CELL, bundle: nil), forCellWithReuseIdentifier: kCATEGORY_HIGHLIGHT_CELL)
    }
    
    func customizeViews() {
        let color = UIColor.init(red: 144.0/255.0, green: 144.0/255.0, blue: 144.0/255.0, alpha: 0.21)
        
        storeContainer.layer.cornerRadius = 5.0
        storeContainer.layer.borderColor = UIColor.lightGray.cgColor
        storeContainer.layer.applySketchShadow(color: color, alpha: 1, x: 0.0, y: 3.0, blur: 14.9, spread: 1.1)
        
        favoriteButton.layer.cornerRadius = 35.0 / 2
        favoriteButton.layer.backgroundColor = UIColor.white.cgColor
        favoriteButton.imageEdgeInsets = UIEdgeInsets(top: 8, left:8, bottom: 8, right: 8)
        favoriteButton.layer.borderColor = UIColor.lightGray.cgColor
        favoriteButton.layer.applySketchShadow(color: color, alpha: 1, x: 0.0, y: 3.0, blur: 14.9, spread: 1.1)
        
        if self.store.isFavorite {
            favoriteButton.setImage(UIImage.init(named: "favorite"), for: .normal)
        }else {
            favoriteButton.setImage(UIImage.init(named: "unfavorite"), for: .normal)
        }
        
        self.categoryContainer.backgroundColor = grayColor
        self.categoryCollectionView.backgroundColor = grayColor
        self.headerContainer.backgroundColor = grayColor
        self.view.backgroundColor = grayColor
    }
    
    @IBAction func showStoreDetail() {
        self.performSegue(withIdentifier: "showStoreDetail", sender: nil)
    }
    
    @IBAction func updateFavoriteAction() {
        if !ATCUserDefaults.isUserLoggedIn() {
            let operationPayload = OperationPayload.init(payloadType: .Favorite, payloadData: self.store)
            performLogIn(favoriteOperation: operationPayload)
            return
        }
        else {
            SharedObjects.shared.updateWithNewOrExistingStoreId(selectedStore: self.store)
            updateFavoriteButton()
        }
        
    }
    
    func updateFavoriteButton() {
        if SharedObjects.shared.isStoreFavorited(store: self.store) {
            favoriteButton.setImage(UIImage.init(named: "favorite"), for: .normal)
        }
        else {
            favoriteButton.setImage(UIImage.init(named: "unfavorite"), for: .normal)
        }
    }
}



extension MockStoreViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.store.categories.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = self.categoryCollectionView.dequeueReusableCell(withReuseIdentifier: kCATEGORY_HIGHLIGHT_CELL, for: indexPath) as? CategoryHighlightCell
        let name = self.store.categories[indexPath.item].name
        cell?.typeLabel.text = name
        
        if indexPath.item == selectedIndex {
            cell?.applySelection()
        }
        else {
            cell?.applyNormalState()
        }
        return cell ?? UICollectionViewCell()
    }
}

extension MockStoreViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize.init(width: 85, height: 27)
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 8
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        return sectionInsets
    }
    
    fileprivate func didSelectCategory(_ item: Int) {
        if self.store.categories.count > item {
            let category = self.store.categories[item]
            if category != nil {
                var tempProducts = category.products
                self.entityViewController?.products = SharedObjects.shared.updateIncomingProductWithFavorite(products: &tempProducts)
                selectedIndex = item
                reloadCategory()
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        didSelectCategory(indexPath.item)
    }
    
    func reloadCategory() {
        DispatchQueue.main.async { self.categoryCollectionView.reloadData() }
    }
}

extension MockStoreViewController: UICollectionViewDelegateFlowLayout {
    
}

extension MockStoreViewController {
    // MARK: - HUD
    func hideOrShowCategory() {
        DispatchQueue.main.async {
            if self.store.categories.count == 0 {
                self.productCategoryLabel.isHidden = true
            }
            else {
                self.productCategoryLabel.isHidden = false
            }
        }
    }
}

extension MockStoreViewController {
    func getProductByStore() {
        
        if let path = Bundle.main.path(forResource: "product", ofType: "json") {
            do {
                let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
                let jsonResult = try JSONSerialization.jsonObject(with: data, options: [.allowFragments]) as? Dictionary<String, AnyObject?>
                if let result = jsonResult, let productDictionaryArray = result["data"] as? Array<Dictionary<String, Any>> {
                    var uncategorisedProduct = [Product]()
                    
                    // get categoryId only
                    var categoryIdSet:Set = Set<Int>()
                    for productDictionary in productDictionaryArray {
                        let product = Product.init(dictionary: productDictionary)
                        categoryIdSet.insert(product.categoryId)
                        uncategorisedProduct.append(product)
                    }
                    
                    var categoryArray = [Category]()
                    
                    for categoryId in categoryIdSet {
                        
                        let products = uncategorisedProduct.filter{$0.categoryId == categoryId}
                        var dictionary = Dictionary<String, Any>()
                        
                        if let product = products.first {
                            dictionary["name"] = product.categoryName
                        }
                        else {
                            dictionary["name"] = "Category"
                        }
                        
                        dictionary["id"] = categoryId
                        dictionary["products"] = products
                        
                        let category = Category.init(dictionary: dictionary)
                        categoryArray.append(category)
                    }
                    
                    categoryArray = categoryArray.sorted{$0.name < $1.name}
                    
                    if categoryArray.count > 0 {
                        var dictionary = Dictionary<String, Any>()
                        dictionary["name"] = "All"
                        dictionary["id"] = "-1"
                        dictionary["products"] = uncategorisedProduct
                        categoryArray.insert(Category.init(dictionary: dictionary), at: 0)
                    }
                    
                    self.store.categories = categoryArray
                    
                    self.hideOrShowCategory()
                    
                    self.didSelectCategory(self.selectedIndex)
                    
                }
                else {
                    //print("Parsing failed")
                }
            } catch {
                // handle error
            }
        }
    }
}
