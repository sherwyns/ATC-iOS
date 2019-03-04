//
//  EntityViewController.swift
//  ATC
//
//  Created by Rathinavel, Dhandapani on 18/11/18.
//  Copyright © 2018 Rathinavel, Dhandapani. All rights reserved.
//

import UIKit
import SDWebImage

enum EntityType {
    case Store
    case Product
}

class EntityViewController: UIViewController {
    
    let kLEFT_INSET = 8.0
    let kRIGHT_INSET = 8.0
    
    var isFiltered = false
    var isFromSearch = false
    var kWIDTH_CELL: CGFloat {
        let insettedWidth = Int((self.view.frame.size.width - 24))
        if (insettedWidth%2) == 0 {
            return CGFloat(insettedWidth / 2)
        }
        else {
           return CGFloat((insettedWidth - 1) / 2)
        }
        
    }
    
    var entityType = EntityType.Store
    
    @IBOutlet var collectionView: UICollectionView!
    
    let kENTITY_VIEW = "EntityViewCell"
    let grayColor = UIColor.init(red: 240.0/255.0, green: 240.0/255.0, blue: 240.0/255.0, alpha: 1)
    
    fileprivate let sectionInsets = UIEdgeInsets(top: 10.0, left: 8.0, bottom: 50.0, right: 8.0)
    
    var stores: [Store]? {
        didSet {
            DispatchQueue.main.async { self.collectionView.reloadData()}
        }
    }
    
    var products: [Product]? {
        didSet {
            DispatchQueue.main.async { self.collectionView.reloadData()}
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.collectionView.dataSource = self
        self.collectionView.delegate = self
        self.collectionView.register(UINib.init(nibName: kENTITY_VIEW, bundle: nil), forCellWithReuseIdentifier: kENTITY_VIEW)
        self.collectionView.register(UINib.init(nibName: ProductEntityCell.kPRODUCT_ENTITY_CELL, bundle: nil), forCellWithReuseIdentifier: ProductEntityCell.kPRODUCT_ENTITY_CELL)
        self.collectionView.register(UINib.init(nibName: "FilterCell", bundle: nil), forCellWithReuseIdentifier: "FilterCell")
        self.view.backgroundColor = grayColor
        self.collectionView.backgroundColor = grayColor
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if !isFromSearch {
            if isFiltered {
                self.stores = SharedObjects.shared.storesWithFavorite
            }
            else {
                self.stores = SharedObjects.shared.stores
            }
        }
        self.collectionView.reloadData()
    }
}

extension EntityViewController: UICollectionViewDataSource {
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    switch entityType {
    case .Product:
        return products?.count ?? 0
    case .Store:
        return stores?.count ?? 0
    }
  }
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    
    
    switch entityType {
    case .Product:
        let cell = self.collectionView.dequeueReusableCell(withReuseIdentifier: ProductEntityCell.kPRODUCT_ENTITY_CELL, for: indexPath) as? ProductEntityCell
        cell?.nameLabel.text = products?[indexPath.item].name
        if let product = products?[indexPath.item] {
            cell?.priceLabel.text = "$\(String(format: "%.2f", product.price))"
            cell?.showPriceOrCallbutton(price: product.price)
            
            if let url = URL.init(string: product.imageUrl) {
                //cell?.bannerImageView.setImageWith(url, placeholderImage: UIImage.init(named: "placeholder"))
                cell?.bannerImageView.sd_setImage(with: url, placeholderImage: UIImage.init(named: "placeholder"), options: [SDWebImageOptions.retryFailed, .handleCookies, .scaleDownLargeImages, .transformAnimatedImage], completed:nil)
            }
            
            cell?.favoritebutton.tag = indexPath.item
            cell?.favoritebutton.addTarget(self, action: #selector(EntityViewController.updateFavorite(sender:)), for: .touchUpInside)
            if product.isFavorite {
                cell?.favoritebutton.setImage(UIImage.init(named: "favorite"), for: .normal)
            }
            else {
                cell?.favoritebutton.setImage(UIImage.init(named: "unfavorite"), for: .normal)
            }
        }
        return cell ?? UICollectionViewCell()
    case .Store:
        let cell = self.collectionView.dequeueReusableCell(withReuseIdentifier: kENTITY_VIEW, for: indexPath) as? EntityViewCell
        if let store = storeForIndexPath(indexPath.item) {
            print("category image url \(indexPath.row) \(store.name) \(store.storeCategoryImageUrlString())")
            cell?.name.text = store.name.capitalizeFirst
            cell?.subName.text = store.neighbourhood
            if let imageUrl = URL.init(string: store.imageUrl) {
                //cell?.bannerImageView.setImageWith(imageUrl, placeholderImage: UIImage.init(named: "placeholder"))
                cell?.bannerImageView.sd_setImage(with: imageUrl, placeholderImage: UIImage.init(named: "placeholder"), options: [SDWebImageOptions.retryFailed, .handleCookies, .scaleDownLargeImages, .transformAnimatedImage], completed:nil)
            }
            
            cell?.favoritebutton.tag = indexPath.item
            cell?.favoritebutton.addTarget(self, action: #selector(EntityViewController.updateFavorite(sender:)), for: .touchUpInside)
            if store.isFavorite {
                cell?.favoritebutton.setImage(UIImage.init(named: "favorite"), for: .normal)
            }
            else {
                cell?.favoritebutton.setImage(UIImage.init(named: "unfavorite"), for: .normal)
            }
            
            if let imageUrlString = store.categoryImageUrl, let imageUrl = URL.init(string: imageUrlString) {
                //cell?.categoryImageView.setImageWith(imageUrl, placeholderImage: UIImage.init(named: "placeholder"))
                cell?.categoryImageView.sd_setImage(with: imageUrl, placeholderImage: UIImage.init(named: "placeholder"), options: [SDWebImageOptions.retryFailed, .handleCookies, .scaleDownLargeImages, .transformAnimatedImage], completed:nil)
            }
            
        }
        else {
            cell?.name.text = "Product"
            cell?.subName.text = "neighbourhood"
        }
        return cell ?? UICollectionViewCell()
    }
  }
    
    @objc @IBAction func updateFavorite(sender: UIButton) {
        switch entityType {
        case .Store:
            if let stores = self.stores {
                let selectedStore = stores[sender.tag]
                if !ATCUserDefaults.isUserLoggedIn() {
                    let operationPayload = OperationPayload.init(payloadType: .Favorite, payloadData: selectedStore)
                    performLogIn(favoriteOperation: operationPayload)
                    return
                }
                else {
                    SharedObjects.shared.updateWithNewOrExistingStoreId(selectedStore: selectedStore)
                }
            }
            if isFiltered {
                self.stores = SharedObjects.shared.storesWithFavorite
            }
            else {
                self.stores = SharedObjects.shared.stores
            }
        case .Product:
            print("Hello Product")
            if let products = self.products {
                let selectedProduct = products[sender.tag]
                if !ATCUserDefaults.isUserLoggedIn() {
                    let operationPayload = OperationPayload.init(payloadType: .Favorite, payloadData: selectedProduct)
                    performLogIn(favoriteOperation: operationPayload)
                    return
                }
                else {
                    SharedObjects.shared.updateWithNewOrExistingProductId(selectedProduct: selectedProduct)
                    self.products = SharedObjects.shared.updateIncomingProductWithFavorite(products: &self.products!)
                }
            }
//            if isFiltered {
//                self.stores = SharedObjects.shared.storesWithFavorite
//            }
//            else {
//                self.stores = SharedObjects.shared.stores
//            }
        }
        
        self.collectionView.reloadData()
    }
  
    func storeForIndexPath(_ row: Int) -> Store? {
        if let stores = self.stores {
            return stores[row]
        }
        return nil
    }
    
    func productForIndexPath(_ indexPath: IndexPath) -> Store? {
        if let stores = self.stores {
            return stores[indexPath.item]
        }
        return nil
    }
}

extension EntityViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize.init(width: kWIDTH_CELL, height: kWIDTH_CELL)
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 8
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        return sectionInsets
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        switch entityType {
        case .Store:
            if let store = storeForIndexPath(indexPath.item) {
                self.parent?.performSegue(withIdentifier: "showStore", sender: store)
                
                if let categoryId = SharedObjects.shared.categoryId, categoryId != "-1" {
                    var analyticsStoreDictionary = Dictionary<String, Any>()
                    analyticsStoreDictionary["store_id"] = store.storeId
                    analyticsStoreDictionary["category_id"] = categoryId
                    let analyticsUrl = ApiServiceURL.apiInterface(.categoryimpression)
                    
                    Downloader.updateJSONUsingURLSessionPOSTRequestForAnalytics(url: analyticsUrl, parameters: analyticsStoreDictionary) { (result, errorString) in
                        
                    }
                }
            }
            
        case .Product:
            var newProduct = products
            if let  selectedProduct = newProduct?.remove(at: indexPath.item) {
                if (newProduct?.count)! > 0  {
                    newProduct?.insert(selectedProduct, at: 0)
                }
                else {
                    newProduct = [Product]()
                    newProduct?.append(selectedProduct)
                }
            }
            self.parent?.performSegue(withIdentifier: "showProductDetail", sender: newProduct)
        }
    }
}

extension EntityViewController: UICollectionViewDelegateFlowLayout {
  
}
