//
//  SearchViewController.swift
//  ATC
//
//  Created by Rathinavel, Dhandapani on 04/11/18.
//  Copyright © 2018 Rathinavel, Dhandapani. All rights reserved.
//

import UIKit
import KSToastView
enum SearchType {
    case Store
    case Product
}

class SearchViewController: UIViewController {
    
    @IBOutlet weak var searchContainer: UIView!
    @IBOutlet weak var searchShadowContainer: UIView!
    @IBOutlet weak var searchTextField: UITextField!
    @IBOutlet weak var searchButton: UIButton!
    @IBOutlet weak var heightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var tableView: UITableView!
    
    let kLEFT_INSET = 8.0
    let kRIGHT_INSET = 8.0
    let session = URLSession.shared
    
    var kWIDTH_CELL: CGFloat {
        let insettedWidth = Int((self.view.frame.size.width - 24))
        if (insettedWidth%2) == 0 {
            return CGFloat(insettedWidth / 2)
        }
        else {
            return CGFloat((insettedWidth - 1) / 2)
        }
        
    }
    let grayColor = UIColor.init(red: 240.0/255.0, green: 240.0/255.0, blue: 240.0/255.0, alpha: 1)
    let kSearchEntityCell = "SearchEntityCell"
    fileprivate let sectionInsets = UIEdgeInsets(top: 0.0, left: 7.0, bottom: 0.0, right: 7.0)
    
    var entityTypes = [EntityType]()
    var stores = [Store]()
    var products = [Product]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        customizeViews()
        searchButton.imageEdgeInsets = UIEdgeInsets.init(top: 10, left: 10, bottom: 10, right: 10)
        
        tableView.register(UINib.init(nibName: "TableHeader", bundle: nil), forHeaderFooterViewReuseIdentifier: "TableHeader")
        tableView.register(UINib.init(nibName: kSearchEntityCell, bundle: nil), forCellReuseIdentifier: kSearchEntityCell)
        tableView.keyboardDismissMode = .onDrag
        tableView.dataSource = self
        tableView.delegate = self
        tableView.backgroundColor = grayColor
        self.view.backgroundColor = grayColor
        //self.tableView.isHidden = true
        
        searchTextField.delegate = self
        

        searchTextField.addTarget(self, action: #selector(textFieldEditingDidChange), for: UIControl.Event.editingChanged)

    }
    
    func addTempProducts() {
        let productDictionary:Dictionary<String,Any> =    [
            "category_id": 241,
            "category_name": "Clothing Accessories",
            "description": "a fabric formed by weaving, felting, etc., from wool, hair, silk, flax, cotton, or other fiber, used for garments, upholstery, and many other items. a piece of such a fabric for a particular purpose",
            "id": 5,
            "price": "2.99",
            "product_image": "https://api.aroundthecorner.store/images/product_1547475588634.jpg",
            "store_id": 4,
            "title": "CC Custom cloths"
        ]
        
        let product = Product.init(dictionary: productDictionary)
        
        products.append(product)

    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.stores = SharedObjects.shared.updateIncomingStoresWithFavorite(stores: &stores)
    }

     // MARK: - Navigation
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
       
        
        if segue.identifier == "showStoreFromSearch", let store = sender as? Store, let storeViewController = segue.destination as? StoreViewController  {
            storeViewController.store = store
        }
        if segue.identifier == "showProductFromSearch", let product = sender as? Product, let productDetailViewController = segue.destination as? ProductDetailViewController  {
            productDetailViewController.product = product
            let tempProduct = products.filter { $0.productId != product.productId }
            productDetailViewController.similarProducts = tempProduct
        }
        
        if segue.identifier == "showListAllEntity", let listAllEntityViewController = segue.destination as? ListAllEntityViewController {
            if let entityType = sender as? EntityType {
                switch entityType {
                case .Product:
                    listAllEntityViewController.products = self.products
                    listAllEntityViewController.entityType = .Product
                case .Store:
                    listAllEntityViewController.stores = self.stores
                    listAllEntityViewController.entityType = .Store
                }
            }
        }
        
    }
    
    @IBAction func logoutAction() {
        LoginManager.logout()
        
        if let parent = self.parent as? ATCTabBarViewController {
            parent.showRegistration(sender: nil)
        }
    }
    
    func customizeViews() {
        searchShadowContainer.layer.cornerRadius = 37/2
        searchContainer.layer.cornerRadius = 37/2
        searchContainer.layer.backgroundColor = UIColor.white.cgColor
        searchShadowContainer.layer.backgroundColor = UIColor.clear.cgColor
        searchContainer.layer.masksToBounds = true
        
        let color = UIColor.init(red: 144.0/255.0, green: 144.0/255.0, blue: 144.0/255.0, alpha: 0.21)
        searchShadowContainer.layer.applySketchShadow(color: color, alpha: 1, x: 0, y: 3, blur: 14.9, spread: 1.1)
    }
    
}

extension SearchViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return entityTypes.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let searchCell = self.tableView.dequeueReusableCell(withIdentifier: kSearchEntityCell) as! SearchEntityCell
        searchCell.collectionView.dataSource = self
        searchCell.collectionView.delegate = self
        searchCell.backgroundColor = grayColor
        searchCell.collectionView.backgroundColor = grayColor
        searchCell.collectionView.tag = entityTypes[indexPath.section] == EntityType.Store ? 1 : 0
        DispatchQueue.main.async {
            searchCell.collectionView.reloadData()
        }
        searchCell.collectionView.isScrollEnabled = false
        return searchCell
    }
    
    
}

extension SearchViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerCell = self.tableView.dequeueReusableHeaderFooterView(withIdentifier: "TableHeader") as! TableHeader
        headerCell.button.imageEdgeInsets = UIEdgeInsets.init(top: 10, left: 10, bottom: 10, right: 10)
        
        headerCell.button.tag = entityTypes[section] == EntityType.Store ? 1 : 0
        headerCell.button.addTarget(self, action: #selector(SearchViewController.showAllEntity(sender:)), for: .touchUpInside)
        
        let entityType = self.entityTypes[section]
        switch entityType {
        case .Product:
            headerCell.label.text = "Products"
        case .Store:
            headerCell.label.text = "Stores"
        }
        return headerCell
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 55
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let entityType = self.entityTypes[indexPath.row]
        switch entityType {
        case .Product:
            let count = self.products.count
            if count > 2 {
                return (kWIDTH_CELL * 2) + 10
            }
            else {
                return (kWIDTH_CELL) + 10
            }
        case .Store:
            let count = self.stores.count
            if count > 2 {
                 return (kWIDTH_CELL * 2) //+ 16
            }
            else {
                return (kWIDTH_CELL) //+ 16
            }
        }
        //return (kWIDTH_CELL * 2) + 16
    }
    
    @objc func showAllEntity(sender: UIButton) {
        var entityType = EntityType.Product
        if sender.tag == 0 {
            entityType = .Product
        }
        if sender.tag == 1 {
            entityType = .Store
        }
        self.performSegue(withIdentifier: "showListAllEntity", sender: entityType)
    }
    
    @objc func updateStoreFavorite(sender : UIButton) {
        if !ATCUserDefaults.isUserLoggedIn() {
            //entityContainer.isHidden = true
            showLogInAlert()
            return
        }
        SharedObjects.shared.updateWithNewOrExistingStoreId(selectedStore: self.stores[sender.tag])
        updateFavoriteButton(sender: sender)
    }
    
    @objc func updateProductFavorite(sender: UIButton) {
        
        
        let selectedProduct = products[sender.tag]
        if !ATCUserDefaults.isUserLoggedIn() {
            let operationPayload = OperationPayload.init(payloadType: .Favorite, payloadData: selectedProduct)
            performLogIn(favoriteOperation: operationPayload)
            return
        }
        else {
            SharedObjects.shared.updateWithNewOrExistingProductId(selectedProduct: selectedProduct)
            self.products = SharedObjects.shared.updateIncomingProductWithFavorite(products: &self.products)
            
            let isFavorite = SharedObjects.shared.isProductFavorited(product: self.products[sender.tag])
            if isFavorite {
                sender.setImage(UIImage.init(named: "favorite"), for: .normal)
            }
            else {
                sender.setImage(UIImage.init(named: "unfavorite"), for: .normal)
            }
        }
    }
    
    func updateFavoriteButton(sender: UIButton) {
        if SharedObjects.shared.isStoreFavorited(store: self.stores[sender.tag]) {
            sender.setImage(UIImage.init(named: "favorite"), for: .normal)
        }
        else {
            sender.setImage(UIImage.init(named: "unfavorite"), for: .normal)
        }
    }
    
    @IBAction func showHomeViewController(){
        if let parent = self.parent?.parent as? ATCTabBarViewController {
            parent.selectedViewController = parent.viewControllers![1]
        }
    }
   
}

extension SearchViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        var entityType = EntityType.Product
        if collectionView.tag == 0 {
            entityType = .Product
        }
        if collectionView.tag == 1 {
            entityType = .Store
        }
        switch entityType {
        case .Store:
            let store = stores[indexPath.item]
            let entityCell = collectionView.dequeueReusableCell(withReuseIdentifier: "EntityViewCell", for: indexPath) as! EntityViewCell
            entityCell.name.text = store.name.capitalizeFirst
            entityCell.subName.text = store.neighbourhood
            entityCell.favoritebutton.tag = indexPath.item
            entityCell.favoritebutton.addTarget(self, action: #selector(SearchViewController.updateStoreFavorite(sender:)), for: .touchUpInside)
            
            if let imageUrl = URL.init(string: store.imageUrl) {
                entityCell.bannerImageView.setImageWith(imageUrl, placeholderImage: UIImage.init(named: "placeholder"))
            }else {
                entityCell.bannerImageView.image = UIImage.init(named: "placeholder")
            }
            
            if store.isFavorite {
                entityCell.favoritebutton.setImage(UIImage.init(named: "favorite"), for: .normal)
            }
            else {
                entityCell.favoritebutton.setImage(UIImage.init(named: "unfavorite"), for: .normal)
            }
            
            if let imageUrl = URL.init(string: store.storeCategoryImageUrlString()) {
                entityCell.categoryImageView.setImageWith(imageUrl, placeholderImage: UIImage.init(named: "placeholder"))
            } else {
                entityCell.categoryImageView.image = UIImage.init(named: "placeholder")
            }
            
            return entityCell
        case .Product:
            let productCell = collectionView.dequeueReusableCell(withReuseIdentifier: ProductEntityCell.kPRODUCT_ENTITY_CELL, for: indexPath) as! ProductEntityCell
            
            let product = products[indexPath.item]
            
            productCell.nameLabel.text = products[indexPath.item].name
            productCell.priceLabel.text = "$\(String(format: "%.2f", product.price))"
            productCell.showPriceOrCallbutton(price: product.price)
            productCell.favoritebutton.tag = indexPath.item
            productCell.favoritebutton.addTarget(self, action: #selector(SearchViewController.updateProductFavorite(sender:)), for: .touchUpInside)
            
            if let url = URL.init(string: product.imageUrl) {
                productCell.bannerImageView.setImageWith(url, placeholderImage: UIImage.init(named: "placeholder"))
            } else {
                productCell.bannerImageView.image = UIImage.init(named: "placeholder")
            }
            return productCell
        }
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        var entityType = EntityType.Product
        if collectionView.tag == 0 {
            entityType = .Product
        }
        if collectionView.tag == 1 {
            entityType = .Store
        }
        switch entityType {
        case .Store:
            return self.stores.count
        case .Product:
            return self.products.count
        }
    }
}

extension SearchViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize.init(width: kWIDTH_CELL, height: kWIDTH_CELL)
    }
  
    func collectionView(_ collectionView: UICollectionView,
                      layout collectionViewLayout: UICollectionViewLayout,
                      insetForSectionAt section: Int) -> UIEdgeInsets {
    return sectionInsets
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        var entityType = EntityType.Product
        if collectionView.tag == 0 {
            entityType = .Product
        }
        if collectionView.tag == 1 {
            entityType = .Store
        }
        switch entityType {
        case .Store:
            self.performSegue(withIdentifier: "showStoreFromSearch", sender: stores[indexPath.item])
        case .Product:
            self.performSegue(withIdentifier: "showProductFromSearch", sender: products[indexPath.item])
        }
    }
}

extension SearchViewController: UICollectionViewDelegateFlowLayout {
  
}

extension SearchViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.tableView.isHidden = false
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        //self.tableView.isHidden = true
        textField.textAlignment = .left
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        textField.resignFirstResponder()
        textField.textAlignment = .center
        if let text = textField.text, text.count > 0 {
            self.searchStoreAndProduct(text: text)
        }
        
    }
}

extension UIViewController {
    @IBAction func openSettings() {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.slideMenuController.openRight()
    }
}

extension SearchViewController {
    @objc func textFieldEditingDidChange(sender: UITextField) {
        if let text = sender.text {
            if text.count >= 1 {
                DispatchQueue.main.async {
                    self.searchStoreAndProduct(text: text)
                }
            }
            if text.count == 0 {
                
                
                
                self.entityTypes = [EntityType]()
                self.products = [Product]()
                self.stores = [Store]()
                self.tableView.reloadData()
            }
            
            
        }
    }
    
    func searchStoreAndProduct(text: String) {
        
        let urlString = "\(ApiServiceURL.apiInterface(.search))\(text)"
        
        guard let finalString = urlString.addingPercentEncoding( withAllowedCharacters: CharacterSet.urlQueryAllowed), let url = URL.init(string: finalString) else  {
            return
        }
        let taskDelegate = TaskDelegate()
        
        DispatchQueue.main.async {
            UIApplication.shared.isNetworkActivityIndicatorVisible = true
        }
        
        let session = URLSession.init(configuration: URLSessionConfiguration.default, delegate: taskDelegate, delegateQueue: nil)
        
        let dataTask = session.dataTask(with: url) { (data, urlResponse, error) in
            if let error = error {
                print(error.localizedDescription)
                DispatchQueue.main.async {
                    UIApplication.shared.isNetworkActivityIndicatorVisible = false
                }
                return
            }
            if let data = data {
                do {
                    if let json = try JSONSerialization.jsonObject(with: data, options: .mutableLeaves) as? Dictionary<String,Array<Dictionary<String,Any>>> {
                        print(json)
                            DispatchQueue.main.async {
                                self.entityTypes = [EntityType]()
                                var stores = [Store]()
                                var products = [Product]()
                                self.products = [Product]()
                                self.stores = [Store]()
                                if let array = json["data"] {
                                    for dictionary in array {
                                        if let storeArray = dictionary["stores"] as? Array<Dictionary<String, Any>>{
                                            for storeDictionary in storeArray {
                                                let store = Store.init(dictionary: storeDictionary)
                                                stores.append(store)
                                            }
                                        }
                                        if let productArray = dictionary["products"] as? Array<Dictionary<String, Any>>{
                                            for productDictionary in productArray {
                                                let product = Product.init(dictionary: productDictionary)
                                                products.append(product)
                                            }
                                        }
                                    }
                                }
                                //print("\(stores.count) \(products.count)")
                                
                                
                                self.stores = stores
                                self.stores = SharedObjects.shared.updateIncomingStoresWithFavorite(stores: &stores)
                                self.products = products
                                //self.addTempProducts()
                                if self.products.count > 0 {
                                    self.entityTypes.append(EntityType.Product)
                                }
                                if self.stores.count > 0 {
                                    self.entityTypes.append(EntityType.Store)
                                }
                                self.tableView.reloadData()
                            }
                            DispatchQueue.main.async {
                                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                            }
                    }
                    else {
                        DispatchQueue.main.async {
                            self.tableView.reloadData()
                        }
                    }
                }
                catch {
                    //print("Please try again")
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                    }
                    DispatchQueue.main.async {
                        UIApplication.shared.isNetworkActivityIndicatorVisible = false
                    }
                }
            }
        }
        
        dataTask.resume()
    }
}
