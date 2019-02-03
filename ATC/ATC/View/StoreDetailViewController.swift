//
//  StoreDetailViewController.swift
//  ATC
//
//  Created by Rathinavel, Dhandapani on 30/11/18.
//  Copyright © 2018 Rathinavel, Dhandapani. All rights reserved.
//

import UIKit
import SafariServices
import MapKit

enum StoreDetailCell {
    case Header
    case Detail
    case Map
}

class StoreDetailViewController: UIViewController {
    
    @IBOutlet weak var productButton: SegButton!
    
    let cellArray: [StoreDetailCell] = [.Header, .Detail, .Map]
    let kStoreDetailHeaderCell = "StoreDetailHeaderCell"
    let kStoreDetailAboutCell = "StoreDetailAboutCell"
    let kStoreDetailMapCell = "StoreDetailMapCell"
    
    let grayColor = UIColor.init(red: 240.0/255.0, green: 240.0/255.0, blue: 240.0/255.0, alpha: 1)
    
    @IBOutlet weak var tableView: UITableView!
    
    var store:Store!

    override func viewDidLoad() {
        super.viewDidLoad()
        registerCellForTableView()
        
        self.tableView.backgroundColor = grayColor
        self.view.backgroundColor = grayColor
        store.isFavorite = SharedObjects.shared.isStoreFavorited(store: self.store)
        productButton.makeRoundedCorner()
        productButton.backgroundColor = UIColor.orange
        getStoreDetails()
    }
    
    func registerCellForTableView() {
        self.tableView.register(UINib.init(nibName: kStoreDetailHeaderCell, bundle: nil), forCellReuseIdentifier: kStoreDetailHeaderCell)
        self.tableView.register(UINib.init(nibName: kStoreDetailAboutCell, bundle: nil), forCellReuseIdentifier: kStoreDetailAboutCell)
        self.tableView.register(UINib.init(nibName: kStoreDetailMapCell, bundle: nil), forCellReuseIdentifier: kStoreDetailMapCell)
        
        self.tableView.dataSource = self
        self.tableView.delegate = self
        
        self.tableView.contentInset = UIEdgeInsets.init(top: 5, left: 0, bottom: 100, right: 0)
    }
    
    @IBAction func showProducts()  {
        self.backAction()
    }
    
    @objc func updateFavorite(sender : UIButton) {
        if !ATCUserDefaults.isUserLoggedIn() {
            let operationPayload = OperationPayload.init(payloadType: .Favorite, payloadData: self.store)
            performLogIn(favoriteOperation: operationPayload)
            return
        }
        SharedObjects.shared.updateWithNewOrExistingStoreId(selectedStore: self.store)
        updateFavoriteButton(sender: sender)
        store.isFavorite = SharedObjects.shared.isStoreFavorited(store: self.store)
    }
    
    func updateFavoriteButton(sender: UIButton) {
        if SharedObjects.shared.isStoreFavorited(store: self.store) {
            sender.setImage(UIImage.init(named: "favorite"), for: .normal)
        }
        else {
            sender.setImage(UIImage.init(named: "unfavorite"), for: .normal)
        }
    }
    
    @objc func openStoreUrl() {
        let storeUrl = self.store.storeUrl
        openLinkInSafariViewController(urlString: storeUrl)
    }
}

extension StoreDetailViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cellArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellType = cellArray[indexPath.row]
        
        switch cellType {
        case .Header:
            let headerCell = self.tableView.dequeueReusableCell(withIdentifier: kStoreDetailHeaderCell) as! StoreDetailHeaderCell
            if let imageUrl = URL.init(string: store.imageUrl) {
                headerCell.shopImageView.setImageWith(imageUrl, placeholderImage: UIImage.init(named: "placeholder"))
            }
            
            if self.store.isFavorite {
                headerCell.favoriteButton.setImage(UIImage.init(named: "favorite"), for: .normal)
            }else {
                headerCell.favoriteButton.setImage(UIImage.init(named: "unfavorite"), for: .normal)
            }
            headerCell.favoriteButton.addTarget(self, action: #selector(StoreDetailViewController.updateFavorite(sender:)), for: .touchUpInside)
            headerCell.shopLabel.text = store.name
            return headerCell
        case .Detail:
            let aboutCell = self.tableView.dequeueReusableCell(withIdentifier: kStoreDetailAboutCell) as! StoreDetailAboutCell
            aboutCell.globeButton.addTarget(self, action: #selector(StoreDetailViewController.openStoreUrl), for: .touchUpInside)
            aboutCell.descriptionLabel.text = store.description
            return aboutCell
        case .Map:
            let mapCell = self.tableView.dequeueReusableCell(withIdentifier: kStoreDetailMapCell) as! StoreDetailMapCell
            
//            13.0827° N, 80.2707° E
            self.store.latitude = 13.0827
            self.store.longitude = 80.2707
            let coordinate = CLLocationCoordinate2D.init(latitude: CLLocationDegrees(self.store.latitude), longitude: CLLocationDegrees(self.store.longitude))
            mapCell.mapView.setCenter(coordinate, animated: true)
            mapCell.mapButton.addTarget(self, action: #selector(StoreDetailViewController.openMaps), for: .touchUpInside)
            return mapCell
        }
    }
}

extension StoreDetailViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let cellType = cellArray[indexPath.row]
        
        switch cellType {
        case .Header:
            return 263
        case .Detail:
            let maxLabelWidth: CGFloat = self.view.frame.size.width - 16
            let aboutCell = self.tableView.dequeueReusableCell(withIdentifier: kStoreDetailAboutCell) as! StoreDetailAboutCell
            aboutCell.descriptionLabel.text = store.description
            let neededSize = aboutCell.descriptionLabel.sizeThatFits(CGSize(width: maxLabelWidth, height: CGFloat.greatestFiniteMagnitude))
            return 115 + neededSize.height
        case .Map:
            return 173
        }
    }
}

extension StoreDetailViewController {
    func getStoreDetails() {
        let urlString = "\(ApiServiceURL.apiInterface(.storeDetail))\(self.store.storeId)"
        
        DispatchQueue.main.async {
            UIApplication.shared.isNetworkActivityIndicatorVisible = true
        }
        Downloader.getStoreJSONUsingURLSession(url: urlString) { (result, errorString) in
            if let error = errorString {
                
            }
            else {
                if let result = result {
                    if let storeDescription = result["description"] as? String {
                        self.store.description = storeDescription
                    }
                    
                    if let latitude = result["latitude"] as? Float {
                        self.store.latitude = latitude
                    } else if let latitude = result["latitude"] as? Double {
                        self.store.latitude = Float(latitude)
                    } else if let latitude = result["latitude"] as? Int {
                        self.store.latitude = Float(latitude)
                    }
                    
                    if let longitude = result["longitude"] as? Float {
                        self.store.longitude = longitude
                    } else if let longitude = result["longitude"] as? Double {
                        self.store.longitude = Float(longitude)
                    } else if let longitude = result["longitude"] as? Int {
                        self.store.longitude = Float(longitude)
                    }
                }
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }
            
            DispatchQueue.main.async {
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
            }
        }
    }
    func openLinkInSafariViewController(urlString: String) {
        
        let urlString = urlString.contains("http") ? urlString : "https://\(urlString)"
        
        if let url = URL.init(string: urlString) {
            let safariVC = SFSafariViewController(url: url)
            self.present(safariVC, animated: true, completion: nil)
            safariVC.delegate = self
        } else {
            
        }
        
    }
}


extension StoreDetailViewController: SFSafariViewControllerDelegate {
    func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
        controller.dismiss(animated: true, completion: {})
    }
}

extension StoreDetailViewController {
    @objc func openMaps() {
        // Open and show coordinate
//        let url = "http://maps.apple.com/maps?saddr=\(self.store.latitude),\(self.store.longitude)"
//        UIApplication.shared.openURL(URL(string:url)!)
        
        let latitude: CLLocationDegrees = CLLocationDegrees(self.store.latitude)
        let longitude: CLLocationDegrees = CLLocationDegrees(self.store.longitude)
        
        let regionDistance:CLLocationDistance = 10000
        let coordinates = CLLocationCoordinate2DMake(latitude, longitude)
        let regionSpan = MKCoordinateRegion(center: coordinates, latitudinalMeters: regionDistance, longitudinalMeters: regionDistance)
        let options = [
            MKLaunchOptionsMapCenterKey: NSValue(mkCoordinate: regionSpan.center),
            MKLaunchOptionsMapSpanKey: NSValue(mkCoordinateSpan: regionSpan.span)
        ]
        let placemark = MKPlacemark(coordinate: coordinates, addressDictionary: nil)
        let mapItem = MKMapItem(placemark: placemark)
        mapItem.name = self.store.name
        mapItem.openInMaps(launchOptions: options)
    }
}

