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
    
    var products: [Store]? {
        didSet {
            //self.collectionView.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        registerCellForTableView()
        
        self.tableView.backgroundColor = grayColor
        self.view.backgroundColor = grayColor
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
            return headerCell
        case .About:
            let aboutCell = self.tableView.dequeueReusableCell(withIdentifier: kPRODUCT_DETAIL_ABOUT_CELL) as! ProductDetailAboutCell
            return aboutCell
        case .Similar:
            let similarCell = self.tableView.dequeueReusableCell(withIdentifier: kPRODUCT_DETAIL_SIMILAR_CELL) as! ProductDetailSimilarCell
             similarCell.productCollectionView.dataSource = self
            similarCell.productCollectionView.delegate = self
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
        return 10
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ProductEntityCell.kPRODUCT_ENTITY_CELL, for: indexPath) as? ProductEntityCell
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
        self.performSegue(withIdentifier: "showProductDetail", sender: nil)
    }
}

extension ProductDetailViewController: UICollectionViewDelegateFlowLayout {
    
}
