//
//  SearchViewController.swift
//  ATC
//
//  Created by Rathinavel, Dhandapani on 04/11/18.
//  Copyright © 2018 Rathinavel, Dhandapani. All rights reserved.
//

import UIKit

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
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.backgroundColor = grayColor
        self.view.backgroundColor = grayColor
        self.tableView.isHidden = true
        
        searchTextField.delegate = self
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
            parent.showRegistration()
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
        searchCell.collectionView.reloadData()
        return searchCell
    }
    
    
}

extension SearchViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerCell = self.tableView.dequeueReusableHeaderFooterView(withIdentifier: "TableHeader") as! TableHeader
        headerCell.button.imageEdgeInsets = UIEdgeInsets.init(top: 10, left: 10, bottom: 10, right: 10)
        if section == 0 {
            headerCell.label.text = "Products"
        }
        else {
            headerCell.label.text = "Stores"
        }
        headerCell.button.tag = entityTypes[section] == EntityType.Store ? 1 : 0
        headerCell.button.addTarget(self, action: #selector(SearchViewController.showAllEntity(sender:)), for: .touchUpInside)
        return headerCell
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return (kWIDTH_CELL * 2) + 16
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
            let entityCell = collectionView.dequeueReusableCell(withReuseIdentifier: "EntityViewCell", for: indexPath) as! EntityViewCell
            
            let store = stores[indexPath.item]
            entityCell.name.text = store.name.capitalizeFirst
            entityCell.subName.text = store.neighbourhood
            if let imageUrl = URL.init(string: store.imageUrl) {
                entityCell.bannerImageView.setImageWith(imageUrl, placeholderImage: UIImage.init(named: "placeholder"))
            }
            
            entityCell.favoritebutton.tag = indexPath.item
            entityCell.favoritebutton.addTarget(self, action: #selector(EntityViewController.updateFavorite(sender:)), for: .touchUpInside)
            if store.isFavorite {
                entityCell.favoritebutton.setImage(UIImage.init(named: "favorite"), for: .normal)
            }
            else {
                entityCell.favoritebutton.setImage(UIImage.init(named: "unfavorite"), for: .normal)
            }
            return entityCell
        case .Product:
            let productCell = collectionView.dequeueReusableCell(withReuseIdentifier: ProductEntityCell.kPRODUCT_ENTITY_CELL, for: indexPath) as! ProductEntityCell
            productCell.nameLabel.text = products[indexPath.item].name
            let product = products[indexPath.item]
                productCell.priceLabel.text = "$\(String(product.price))"
            if let url = URL.init(string: product.imageUrl) {
                productCell.bannerImageView.setImageWith(url, placeholderImage: UIImage.init(named: "placeholder"))
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
        self.tableView.isHidden = true
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
    func searchStoreAndProduct(text: String) {
        
        let urlString = "http://34.209.125.112/api/search/by/\(text)"
        
        let url = URL.init(string: urlString)!
        
        let taskDelegate = TaskDelegate()
        
        let session = URLSession.init(configuration: URLSessionConfiguration.default, delegate: taskDelegate, delegateQueue: nil)
        
        let dataTask = session.dataTask(with: url) { (data, urlResponse, error) in
          if let error = error {
            print(error.localizedDescription)
            return
          }
          if let data = data {
            do {
              if let json = try JSONSerialization.jsonObject(with: data, options: .mutableLeaves) as? Dictionary<String,Array<Dictionary<String,Any>>> {
               // print(json)
                self.entityTypes = [EntityType]()
                var stores = [Store]()
                var products = [Product]()
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
                print("\(stores.count) \(products.count)")
                self.stores = stores
                self.products = products
                if products.count > 0 {
                    self.entityTypes.append(EntityType.Product)
                }
                if stores.count > 0 {
                    self.entityTypes.append(EntityType.Store)
                }
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
                
              }
            }
            catch {
              print("Catch from \(error.localizedDescription)")
            }
          }
        }
        
        dataTask.resume()
    }
}
