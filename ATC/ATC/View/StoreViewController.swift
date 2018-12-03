//
//  StoreViewController.swift
//  
//
//  Created by Rathinavel, Dhandapani on 30/11/18.
//

import UIKit

class StoreViewController: UIViewController, EntityProtocol {
    
    @IBOutlet weak var headerContainer: UIView!
    @IBOutlet weak var storeContainer: UIView!
    @IBOutlet weak var favoriteButton: UIButton!
    @IBOutlet weak var categoryContainer: UIView!
    @IBOutlet weak var categoryListContainer: UIView!
    @IBOutlet weak var categoryCollectionView: UICollectionView!
    
    var entityViewController: EntityViewController?
    
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
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ProductEntityViewController" {
            if let entityViewController = segue.destination as? EntityViewController {
                self.entityViewController = entityViewController
                self.entityViewController?.isFiltered = false
                self.entityViewController?.entityType = .Product
                if let _ = self.entityViewController?.view {
                    self.entityViewController?.collectionView.backgroundColor = grayColor
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
        
        self.categoryContainer.backgroundColor = grayColor
        self.categoryCollectionView.backgroundColor = grayColor
        self.headerContainer.backgroundColor = grayColor
        self.view.backgroundColor = grayColor
    }
    
    @IBAction func showStoreDetail() {
        self.performSegue(withIdentifier: "showStoreDetail", sender: nil)
    }
}



extension StoreViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 10
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = self.categoryCollectionView.dequeueReusableCell(withReuseIdentifier: kCATEGORY_HIGHLIGHT_CELL, for: indexPath) as? CategoryHighlightCell
        if indexPath.item == 0 {
            cell?.applySelection()
        }
        else {
            cell?.applyNormalState()
        }
        return cell ?? UICollectionViewCell()
    }
}

extension StoreViewController: UICollectionViewDelegate {
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
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.parent?.performSegue(withIdentifier: "showProductDetail", sender: nil)
    }
}

extension StoreViewController: UICollectionViewDelegateFlowLayout {
    
}
