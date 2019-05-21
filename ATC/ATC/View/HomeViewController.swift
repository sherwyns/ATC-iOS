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
import CoreLocation

class HomeViewController: UIViewController, EntityProtocol {
    
    @IBOutlet var HUD:MBProgressHUD!
    @IBOutlet weak var entityContainer: UIView!
    @IBOutlet weak var filterButton: UIButton!
    @IBOutlet weak var badgeViewLabel: UILabel!
    @IBOutlet weak var titleButton: UIButton!
    @IBOutlet weak var productButton: SegButton!
    @IBOutlet weak var storeButton: SegButton!
    
    var entityViewController: EntityViewController?
    weak var paginationPayloadable: PaginationPayloadable?
    
    var stores: [Store]?
    var isFirst:Bool = true
    var entityType: EntityType = .Store
    
    let grayColor = UIColor.init(red: 240.0/255.0, green: 240.0/255.0, blue: 240.0/255.0, alpha: 1)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = grayColor
        
        setupViews()
        productButton.highlightedStateColor()
        storeButton.normalStateColor()
        productButtonAction()
        locationAuthorizationUpdate()
        
        Downloader.retrieveStoreCategories()
        Downloader.retrieveProductCategories()
        Downloader.retrieveStoreNeighborhood()
        
        
        self.paginationPayloadable = self.entityViewController as? PaginationPayloadable
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(HomeViewController.getStoresByLocation), name: NotificationConstant.reloadHome, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(HomeViewController.locationAuthorizationUpdate), name: NotificationConstant.locationAuthorizationUpdate, object: nil)
    }
    
    @objc func locationAuthorizationUpdate() {
        if CLLocationManager.locationServicesEnabled() {
            
            let status = CLLocationManager.authorizationStatus()
            switch status {
            case .restricted, .denied, .notDetermined:
                titleButton.setTitle(entityType == .Product ? "All Products" : "Stores", for: .normal)
            case .authorizedWhenInUse, .authorizedAlways:
                titleButton.setTitle(entityType == .Product ? "All Products" : "Stores near you", for: .normal)
                break
            }
        } else {
            titleButton.setTitle(entityType == .Product ? "All Products" : "Stores", for: .normal)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if !ATCUserDefaults.isAppWalkthroughDone() {
            self.performSegue(withIdentifier: "AppIntro", sender: nil)
        } else {
            let locationManager = ATCLocation.shared
            locationManager.requestLocation()
            locationManager.delegate = SharedObjects.shared
        }
        
        if SharedObjects.shared.canReloadStore {
            getStores()
            SharedObjects.shared.products?.removeAll()
            
            self.entityViewController?.collectionView.dataSource = nil
            self.entityViewController?.collectionView.delegate = nil
            self.entityViewController?.collectionView.setContentOffset(CGPoint.init(x: 0, y: 0), animated: false)
  
            self.getEntity(withType: .Product, withLimit: "30", withOffset: String(0))
            
            self.entityViewController?.collectionView.dataSource = self.entityViewController
            self.entityViewController?.collectionView.delegate = self.entityViewController
            
            SharedObjects.shared.canReloadStore = false
        }
        else {
            self.entityViewController?.collectionView.reloadData()
        }
        
        updateBadgeView()
    }
    
    @IBAction func productButtonAction() {
        entityType = .Product
        updateBadgeView()
        locationAuthorizationUpdate()
        self.entityViewController?.isPaginatable = true
        productButton.highlightedStateColor()
        storeButton.normalStateColor()
        refreshEntityViewController()
        self.entityViewController?.resetScrollPosition()
    }
    
    @IBAction func storeButtonAction() {
        entityType = .Store
        updateBadgeView()
        locationAuthorizationUpdate()
        self.entityViewController?.isPaginatable = false
        storeButton.highlightedStateColor()
        productButton.normalStateColor()
        refreshEntityViewController()
        self.entityViewController?.resetScrollPosition()
        
    }
    
    func refreshEntityViewController() {
        self.entityViewController?.entityType = self.entityType
        self.entityViewController?.collectionView.reloadData()
    }
    
    func appliedFilterCount() -> Int {
        if entityType == .Store {
            return SharedObjects.shared.categoryIds.count + SharedObjects.shared.neighbourhoods.count
        } else {
            return SharedObjects.shared.productCategoryIds.count + SharedObjects.shared.productNeighbourhoods.count
        }
       
    }
    
    fileprivate func setupBadgeView() {
        badgeViewLabel.layer.cornerRadius = badgeViewLabel.frame.size.width / 2
        badgeViewLabel.layer.masksToBounds = true
        badgeViewLabel.backgroundColor = .orange
        badgeViewLabel.textColor = .white
        badgeViewLabel.isHidden = true
    }
    
    fileprivate func setupViews() {
        let backgroundGrayColor: UIColor = .clear
        storeButton.normalGradientColor = backgroundGrayColor
        productButton.normalGradientColor = backgroundGrayColor
        filterButton.imageEdgeInsets = UIEdgeInsets(top: 11, left:11, bottom: 11, right: 11)
        setupBadgeView()
    }
    
    fileprivate func updateBadgeView() {
        if appliedFilterCount() > 0 {
            self.badgeViewLabel.text = String(appliedFilterCount())
            self.badgeViewLabel.isHidden = false
        } else {
            self.badgeViewLabel.isHidden = true
        }
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "HomeEntityViewController" {
            if let entityViewController = segue.destination as? EntityViewController {
                self.entityViewController = entityViewController
                self.entityViewController?.isFiltered = false
                
            }
        }
        
        if segue.identifier == "showProductDetail" {
            if let productDetailViewController = segue.destination as? ProductDetailViewController {
                if let products = sender as? [Product] {
                    productDetailViewController.product = products.first
                    productDetailViewController.similarProducts = [Product]()
                }
                
            }
        }
        if segue.identifier == "showStore", let store = sender as? Store, let storeViewController = segue.destination as? StoreViewController  {
            storeViewController.store = store
        }
        
        if segue.identifier == "showFilter", let filterViewController = segue.destination as? FilterViewController {
            filterViewController.entityType = entityType
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
    
    @objc func getStoresByLocation() {
        locationAuthorizationUpdate()
        getStores()
    }
    
    @objc func getStores() {
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
                            //KSToastView.ks_showToast("No shops found", duration: 3.0)
                        }
                        self.entityViewController?.stores = SharedObjects.shared.storesWithFilter()
                    }
                    else {
                        if let stores = SharedObjects.shared.stores, stores.count == 0 {
                            //KSToastView.ks_showToast("No shops found", duration: 3.0)
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
    
    @objc func getProduct(url: URL?, offset: String = "0") {
        let storeUrl = url ?? URL.init(string: "https://api.aroundthecorner.store/api/products/getproductlist?neighbourhood=&category=&limit=30&offset=0")!
        print("storeUrl")
        print(storeUrl)
        DispatchQueue.main.async {
            UIApplication.shared.isNetworkActivityIndicatorVisible = true
        }
        Downloader.getStoreJSONUsingURLSession(serviceUrl: storeUrl) { (result, errorString) in
            if let error = errorString {
                KSToastView.ks_showToast(error)
            }
            else {
                print("product json \(result)")
                if let result = result, let productDictionaryArray = result["data"] as? Array<Dictionary<String, Any>> {
                    DispatchQueue.main.async {
                        var productArray = [Product]()
                        for productDictionary in productDictionaryArray {
                            let product = Product.init(dictionary: productDictionary)
                            print("no shop \(product.productId) \(product.name) \(product.storeId) \(product.shopName)")
                            
                            productArray.append(product)
                        }
                        
                        if var products:[Product] = SharedObjects.shared.products {
                            products = products + productArray
                            SharedObjects.shared.products = (Array(NSOrderedSet(array: products)) as! [Product])
                        } else {
                            SharedObjects.shared.products = productArray
                        }
                        self.entityViewController?.products = SharedObjects.shared.products
                        self.paginationPayloadable?.getProduct(withType: .Product, withOffset: offset)
                    }
                    
                }
            }
            
            DispatchQueue.main.async {
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
            }
        }
    }
}

extension HomeViewController: PaginationPaybackable {
    func getEntity(withType entityType: EntityType,  withLimit limit: String, withOffset offset: String) {
        switch entityType {
        case .Product:
            let url = ProductUrlBuilder.url( limit: limit, offset: offset)
            getProduct(url: url, offset: offset)
        case .Store:
            break
        }
    }
    
    
}

protocol PaginationPaybackable: class {
    func getEntity(withType entityType: EntityType,  withLimit limit: String, withOffset offset: String)
}

protocol PaginationPayloadable: class {
    func getProduct(withType entityType: EntityType, withOffset offset: String)
}

class ProductUrlBuilder {
    static func url(neighbourhood: String = String(), category: String = String(), limit: String = "20", offset: String = "0") -> URL? {
        var queryItems = [URLQueryItem]()
        
        let urlComponents = NSURLComponents()
        urlComponents.scheme = "https"
        urlComponents.host = "api.aroundthecorner.store"
        urlComponents.path = "/api/products/getproductlist"
        
        let tempNeighbourhoods = SharedObjects.shared.productNeighbourhoods.filter { $0 != "All"}
        let neighbourhood = concatenateString(array: tempNeighbourhoods)
        
        
        var tempCategoryIds = SharedObjects.shared.productCategoryIds.filter { $0 != "-1"}
        
        for productCategory in SharedObjects.shared.productCategories {
            if productCategory.subProductCategories.count > 0 {
                let subCategoryIds = productCategory.subProductCategories.map{return $0.productId}
                let setOfSubCategoryIds = Set.init(subCategoryIds)
                
                let intersectedSet = setOfSubCategoryIds.intersection(SharedObjects.shared.productCategoryIds)
                
                if (intersectedSet.count == subCategoryIds.count) {
                    tempCategoryIds.append(productCategory.productId)
                }
            }
        }
        
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
        
        let offsetQuery  = URLQueryItem(name: "offset", value: offset)
        queryItems.append(offsetQuery)
        
        let limitQuery  = URLQueryItem(name: "limit", value: limit)
        queryItems.append(limitQuery)
        
        urlComponents.queryItems = queryItems
        print("filter product url \(urlComponents.url)")
        return urlComponents.url
    }
    
    static func concatenateString(array : [String]) -> String {
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
}

