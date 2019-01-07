//
//  ProductDetailViewController.swift
//  ATC
//
//  Created by Rathinavel, Dhandapani on 30/11/18.
//  Copyright © 2018 Rathinavel, Dhandapani. All rights reserved.
//

import UIKit

enum ProductDetailCell {
    case Header
    case About
    case Similar
}

class ProductDetailViewController: UIViewController {
  
    @IBOutlet weak var tableView: UITableView!
    var similarProductsCollectionView: UICollectionView?
    let kPRODUCT_DETAIL_HEADER_CELL = "ProductDetailHeaderCell"
    let kPRODUCT_DETAIL_ABOUT_CELL = "ProductDetailAboutCell"
    let kPRODUCT_DETAIL_SIMILAR_CELL = "ProductDetailSimilarCell"
    
    let kLEFT_INSET = 8.0
    let kRIGHT_INSET = 8.0
    
    let grayColor = UIColor.init(red: 240.0/255.0, green: 240.0/255.0, blue: 240.0/255.0, alpha: 1)
    
    let cellArray = [ProductDetailCell.Header, ProductDetailCell.About, ProductDetailCell.Similar]
    
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
    
    //fileprivate let sectionInsets = UIEdgeInsets(top: 0.0, left: 8.0, bottom: 50.0, right: 8.0)
    
    var product: Product!
    
    var similarProducts: [Product]? {
        didSet {
            
            
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        registerCellForTableView()
        
        self.tableView.backgroundColor = grayColor
        self.view.backgroundColor = grayColor
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        DispatchQueue.main.async {self.tableView.reloadData()}
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
            return headerCell
        case .About:
            let aboutCell = self.tableView.dequeueReusableCell(withIdentifier: kPRODUCT_DETAIL_ABOUT_CELL) as! ProductDetailAboutCell
            aboutCell.nameLabel.text = product.name
            aboutCell.priceLabel.text = "$\(String(product.price))"
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
}

extension ProductDetailViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let cellType = cellArray[indexPath.row]
        switch cellType {
        case .Header:
            return 226
        case .About:
            let maxLabelWidth: CGFloat = self.view.frame.size.width - 16
            let aboutCell = self.tableView.dequeueReusableCell(withIdentifier: kPRODUCT_DETAIL_ABOUT_CELL) as! ProductDetailAboutCell
            aboutCell.descriptionLabel.text = productDescription
            let neededSize = aboutCell.descriptionLabel.sizeThatFits(CGSize(width: maxLabelWidth, height: CGFloat.greatestFiniteMagnitude))
            return 60 + neededSize.height
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
            cell?.priceLabel.text = "$\(String(product.price))"
            if let url = URL.init(string: product.imageUrl) {
                cell?.bannerImageView.setImageWith(url, placeholderImage: UIImage.init(named: "placeholder"))
            }
        }
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
