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
    @IBOutlet weak var productButton: SegButton!
    @IBOutlet weak var storeButton: SegButton!
    
    var entityViewController: EntityViewController?
    weak var paginationPayloadable: PaginationPayloadable?
    
    var stores: [Store]?
    var isFirst:Bool = true
    var entityType: EntityType = .Product
    
    let grayColor = UIColor.init(red: 240.0/255.0, green: 240.0/255.0, blue: 240.0/255.0, alpha: 1)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = grayColor
        
        setupViews()
        productButton.highlightedStateColor()
        storeButton.normalStateColor()
        productButtonAction()
        
        Downloader.retrieveCategories()
        
        self.paginationPayloadable = self.entityViewController as? PaginationPayloadable
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(HomeViewController.getStores), name: NotificationConstant.reloadHome, object: nil)
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
            getProduct(url: nil)
            SharedObjects.shared.canReloadStore = false
        }
        else {
            self.entityViewController?.collectionView.reloadData()
        }
        
        updateBadgeView()
    }
    
    @IBAction func productButtonAction() {
        entityType = .Product
        self.entityViewController?.isPaginatable = true
        productButton.highlightedStateColor()
        storeButton.normalStateColor()
        refreshEntityViewController()
        self.entityViewController?.resetScrollPosition()
    }
    
    @IBAction func storeButtonAction() {
        entityType = .Store
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
       return SharedObjects.shared.categoryIds.count + SharedObjects.shared.neighbourhoods.count
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
    
    @objc func getProduct(url: URL?, offset: String = "0") {
        let storeUrl = url ?? URL.init(string: "https://api.aroundthecorner.store/api/products/getproductlist?neighbourhood=&category=&limit=30&offset=0")!
        
        DispatchQueue.main.async {
            UIApplication.shared.isNetworkActivityIndicatorVisible = true
        }
        Downloader.getStoreJSONUsingURLSession(serviceUrl: storeUrl) { (result, errorString) in
            if let error = errorString {
                KSToastView.ks_showToast(error)
            }
            else {
                if let result = result, let productDictionaryArray = result["data"] as? Array<Dictionary<String, Any>> {
                    var productArray = [Product]()
                    for productDictionary in productDictionaryArray {
                        let product = Product.init(dictionary: productDictionary)
                        productArray.append(product)
                    }
                    
                    if var products:[Product] = SharedObjects.shared.products {
                        products = products + productArray
                        
                        SharedObjects.shared.products = Array(NSOrderedSet(array: products)) as! [Product]
                    }
                    else {
                        SharedObjects.shared.products = productArray
                    }
                    
                    
                    self.entityViewController?.products = SharedObjects.shared.products
                    if let stores = SharedObjects.shared.stores, stores.count == 0 {
                        KSToastView.ks_showToast("No stores found", duration: 3.0)
                    }
                    self.paginationPayloadable?.getProduct(withType: .Product, withOffset: offset)
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
//https://api.aroundthecorner.store/api/products/getproductlist?neighbourhood=Capitol%20Hill&category=3040&limit=2&offset=0
class ProductUrlBuilder {
    static func url(neighbourhood: String = String(), category: String = String(), limit: String = "20", offset: String = "0") -> URL? {
        var queryItems = [URLQueryItem]()
        
        let urlComponents = NSURLComponents()
        urlComponents.scheme = "https"
        urlComponents.host = "api.aroundthecorner.store"
        urlComponents.path = "/api/products/getproductlist"
        
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
        
        let offsetQuery  = URLQueryItem(name: "offset", value: offset)
        queryItems.append(offsetQuery)
        
        let limitQuery  = URLQueryItem(name: "limit", value: limit)
        queryItems.append(limitQuery)
        
        urlComponents.queryItems = queryItems
        print("filter url \(urlComponents.url)")
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

