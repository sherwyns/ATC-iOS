//
//  ProductDetailViewController.swift
//  ATC
//
//  Created by Rathinavel, Dhandapani on 30/11/18.
//  Copyright © 2018 Rathinavel, Dhandapani. All rights reserved.
//

import UIKit
import MBProgressHUD
import AFNetworking

enum ProductDetailCell {
    case Header
    case About
    case Similar
}

class ProductDetailViewController: UIViewController {
  
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet var HUD:MBProgressHUD!
    
    var similarProductsCollectionView: UICollectionView?
    let kPRODUCT_DETAIL_HEADER_CELL = "ProductDetailHeaderCell"
    let kPRODUCT_DETAIL_ABOUT_CELL = "ProductDetailAboutCell"
    let kPRODUCT_DETAIL_SIMILAR_CELL = "ProductDetailSimilarCell"
    
    let kLEFT_INSET = 8.0
    let kRIGHT_INSET = 8.0
    
    let grayColor = UIColor.init(red: 240.0/255.0, green: 240.0/255.0, blue: 240.0/255.0, alpha: 1)
    
    var cellArray = [ProductDetailCell.Header, ProductDetailCell.About, ProductDetailCell.Similar]
    
    var kWIDTH_CELL: CGFloat {
        let insettedWidth = Int((self.view.frame.size.width - 24))
        if (insettedWidth%2) == 0 {
            return CGFloat(insettedWidth / 2)
        }
        else {
            return CGFloat((insettedWidth - 1) / 2)
        }
        
    }
    
     var productDescription = "Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmodtempor incididunt ut labore et doloreincididunt ut labore et dolore Lorem ipsum dolor sit amet, consectetur "

    var entityType = EntityType.Product
    
    let kENTITY_VIEW = "EntityViewCell"
    
    var headerCellHeight = 226
    
    //fileprivate let sectionInsets = UIEdgeInsets(top: 0.0, left: 8.0, bottom: 50.0, right: 8.0)
    
    var product: Product!
    
    var similarProducts: [Product]? {
        didSet {
            if let similarProducts = similarProducts, similarProducts.count == 0 {
                if let lastCell = cellArray.last, lastCell == ProductDetailCell.Similar {
                    cellArray.removeLast()
                }
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        self.tableView.backgroundColor = grayColor
        self.view.backgroundColor = grayColor
        
        var analyticsProductDictionary = Dictionary<String, Any>()
        analyticsProductDictionary["store_id"] = product.storeId
        analyticsProductDictionary["product_id"] = product.productId
        analyticsProductDictionary["name"] = product.name
        let analyticsUrl = ApiServiceURL.apiInterface(.productimpression)
        
        Downloader.updateJSONUsingURLSessionPOSTRequestForAnalytics(url: analyticsUrl, parameters: analyticsProductDictionary) { (result, errorString) in
            
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        downloadImage()
    }
    
    func downloadImage() {
        if let imageUrl = URL.init(string: product.imageUrl) {
            
            let urlRequest = URLRequest.init(url: imageUrl)
            showHUD()
            AFImageDownloader.defaultInstance().downloadImage(for: urlRequest, success: { (urlRequest, urlResponse, image) in
                if let cgImage = image.cgImage {
                    let width = cgImage.width
                    let height = cgImage.height
                    let screenWidth = UIScreen.main.bounds.size.width
                    
                    let tempheight = screenWidth * (CGFloat(height) / CGFloat(width))
                    
                    self.headerCellHeight = Int(tempheight) + 80
                    self.reloadTableView()
                }
            }) { (urlRequest, urlResponse, error) in
                print("failure")
                self.reloadTableView()
            }
        } else {
            self.reloadTableView()
        }
    }
    
    func reloadTableView() {
        self.registerCellForTableView()
        self.hideHUD()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
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
        
        if segue.identifier == "showStoreDetailViewController" {
            if let storeDetailViewController = segue.destination as? StoreDetailViewController {
                //stor\\\eDetailViewController.store = self.store
              let store = SharedObjects.shared.stores?.first{return $0.storeId == product.storeId}
              if let store = store {
                storeDetailViewController.store = store
              }
            }
        }
    }

    func registerCellForTableView() {
        self.tableView.register(UINib.init(nibName: kPRODUCT_DETAIL_HEADER_CELL, bundle: nil), forCellReuseIdentifier: kPRODUCT_DETAIL_HEADER_CELL)
        self.tableView.register(UINib.init(nibName: kPRODUCT_DETAIL_ABOUT_CELL, bundle: nil), forCellReuseIdentifier: kPRODUCT_DETAIL_ABOUT_CELL)
        self.tableView.register(UINib.init(nibName: kPRODUCT_DETAIL_SIMILAR_CELL, bundle: nil), forCellReuseIdentifier: kPRODUCT_DETAIL_SIMILAR_CELL)
        
        self.tableView.dataSource = self
        self.tableView.delegate = self
        
        self.tableView.contentInset = UIEdgeInsets.init(top: 5, left: 0, bottom: 100, right: 0)
    }
}

extension ProductDetailViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cellArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellType = cellArray[indexPath.row]
        
        switch cellType {
        case .Header:
            let headerCell = self.tableView.dequeueReusableCell(withIdentifier: kPRODUCT_DETAIL_HEADER_CELL) as! ProductDetailHeaderCell
            if let url = URL.init(string: product.imageUrl) {
                headerCell.productImageView.setImageWith(url, placeholderImage: UIImage.init(named: "placeholder"))
            }
            if product.isFavorite {
                headerCell.favoritebutton.setImage(UIImage.init(named: "favorite"), for: .normal)
            }
            else {
                headerCell.favoritebutton.setImage(UIImage.init(named: "unfavorite"), for: .normal)
            }
            
            headerCell.favoritebutton.addTarget(self, action: #selector(ProductDetailViewController.updateProductFavorite(sender:)), for: .touchUpInside)
            return headerCell
        case .About:
            let aboutCell = self.tableView.dequeueReusableCell(withIdentifier: kPRODUCT_DETAIL_ABOUT_CELL) as! ProductDetailAboutCell
            aboutCell.nameLabel.text = product.name
            aboutCell.priceLabel.text = "$\(String(format: "%.2f", product.price))"
            aboutCell.showPriceOrCallbutton(price: product.price)
            aboutCell.descriptionLabel.text = product.description
            
            let shopCategoryImageUrl = SharedObjects.shared.stores?.first {return $0.storeId == product.storeId}?.categoryImageUrl
            let shopName = SharedObjects.shared.stores?.first {return $0.storeId == product.storeId}?.name
            
            if let shopCategoryImageUrl = shopCategoryImageUrl, let url = URL.init(string: shopCategoryImageUrl) {
                aboutCell.shopCAtegoryImageView.setImageWith(url, placeholderImage: UIImage.init(named: "placeholder"))
            }else {
                aboutCell.shopCAtegoryImageView.image = UIImage.init(named: "placeholder")
            }
            
            if let shopName = shopName {
                aboutCell.shopLabel.text = shopName
            } else {
                aboutCell.shopLabel.text = ""
            }
            
            aboutCell.shopButton.addTarget(self, action: #selector(ProductDetailViewController.showStoreViewController), for: .touchUpInside)
            return aboutCell
        case .Similar:
            let similarCell = self.tableView.dequeueReusableCell(withIdentifier: kPRODUCT_DETAIL_SIMILAR_CELL) as! ProductDetailSimilarCell
            similarCell.productCollectionView.dataSource = self
            similarCell.productCollectionView.delegate = self
            self.similarProductsCollectionView = similarCell.productCollectionView
            DispatchQueue.main.async{ self.similarProductsCollectionView?.reloadData() }
            
            return similarCell
        }
    }
    
    @objc func showStoreViewController() {
        let store = SharedObjects.shared.stores?.first{return $0.storeId == product.storeId}
        if let _ = store {
            self.performSegue(withIdentifier: "showStoreDetailViewController", sender: nil)
        }
    }
    
    
    @objc func updateProductFavorite(sender : UIButton) {
        if !ATCUserDefaults.isUserLoggedIn() {
            //entityContainer.isHidden = true
            showLogInAlert()
            return
        }
        SharedObjects.shared.updateWithNewOrExistingProductId(selectedProduct: self.product)
        
        updateProductFavoriteButton(sender: sender)
    }
    
    @objc func updateSimilarProductFavorite(sender : UIButton) {
        if !ATCUserDefaults.isUserLoggedIn() {
            //entityContainer.isHidden = true
            showLogInAlert()
            return
        }
        SharedObjects.shared.updateWithNewOrExistingProductId(selectedProduct: similarProducts![sender.tag])
        
        
        self.similarProducts = SharedObjects.shared.updateIncomingProductWithFavorite(products: &similarProducts!)
        updateProductFavoriteButton(sender: sender)
    }
    
    
    func updateProductFavoriteButton(sender: UIButton) {
        self.product.isFavorite = SharedObjects.shared.isProductFavorited(product: self.product)
        if self.product.isFavorite {
            sender.setImage(UIImage.init(named: "favorite"), for: .normal)
        }
        else {
            sender.setImage(UIImage.init(named: "unfavorite"), for: .normal)
        }
    }
}

extension ProductDetailViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let cellType = cellArray[indexPath.row]
        switch cellType {
        case .Header:
            return CGFloat(headerCellHeight)
        case .About:
            let maxLabelWidth: CGFloat = self.view.frame.size.width - 16
            let aboutCell = self.tableView.dequeueReusableCell(withIdentifier: kPRODUCT_DETAIL_ABOUT_CELL) as! ProductDetailAboutCell
            aboutCell.descriptionLabel.text = self.product.description
            let neededSize = aboutCell.descriptionLabel.sizeThatFits(CGSize(width: maxLabelWidth, height: CGFloat.greatestFiniteMagnitude))
            return 60 + neededSize.height + 35
        case .Similar:
            return 176 + 60
        }
    }
    
    
}


extension ProductDetailViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return similarProducts?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ProductEntityCell.kPRODUCT_ENTITY_CELL, for: indexPath) as? ProductEntityCell
        cell?.nameLabel.text = similarProducts?[indexPath.item].name
        if let product = similarProducts?[indexPath.item] {
            cell?.priceLabel.text = "$\(String(format: "%.2f", product.price))"
            cell?.showPriceOrCallbutton(price: product.price)
            if let url = URL.init(string: product.imageUrl) {
                cell?.bannerImageView.setImageWith(url, placeholderImage: UIImage.init(named: "placeholder"))
            }
        }
        
        if similarProducts![indexPath.item].isFavorite {
            cell?.favoritebutton.setImage(UIImage.init(named: "favorite"), for: .normal)
        }
        else {
            cell?.favoritebutton.setImage(UIImage.init(named: "unfavorite"), for: .normal)
        }
        
        cell?.favoritebutton.addTarget(self, action: #selector(ProductDetailViewController.updateProductFavorite(sender:)), for: .touchUpInside)
        return cell ?? UICollectionViewCell()
    }
    
    
}

extension ProductDetailViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize.init(width: 176, height: 176)
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 8
    }
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        var newProduct = similarProducts
        if let  selectedProduct = newProduct?.remove(at: indexPath.item) {
            if (newProduct?.count)! > 0  {
                newProduct?.insert(selectedProduct, at: 0)
                newProduct?.append(self.product)
            }
            else {
                newProduct = [Product]()
                newProduct?.append(selectedProduct)
                newProduct?.append(self.product)
            }
        }
        self.performSegue(withIdentifier: "showProductDetail", sender: newProduct)
    }
}

extension ProductDetailViewController: UICollectionViewDelegateFlowLayout {
    
}

extension ProductDetailViewController {
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
    
    func addHUDToView() {
        HUD = MBProgressHUD(view: self.view)
        self.view.addSubview(HUD)
        HUD.frame.origin = CGPoint(x: self.view.frame.origin.x/2, y: self.view.frame.origin.y/2)
        HUD.frame.size  = CGSize(width: 50, height: 50)
        
        HUD.mode = MBProgressHUDMode.indeterminate
        HUD.isUserInteractionEnabled = true
    }
}
