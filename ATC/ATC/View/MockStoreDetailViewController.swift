//
//  MockStoreDetailViewController.swift
//  ATC
//
//  Created by Rathinavel, Dhandapani on 08/04/19.
//  Copyright © 2019 Rathinavel, Dhandapani. All rights reserved.
//

import UIKit
import SafariServices
import MapKit

class MockStoreDetailViewController: UIViewController {
    
    @IBOutlet weak var productButton: SegButton!
    
    @IBOutlet weak var topConstraint: NSLayoutConstraint!
    @IBOutlet weak var rightConstraint: NSLayoutConstraint!
    @IBOutlet weak var leftConstraint: NSLayoutConstraint!
    @IBOutlet weak var imageViewRightConstant: NSLayoutConstraint!
    @IBOutlet weak var imageViewHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var imageViewTopConstraint: NSLayoutConstraint!
    
    
    let cellArray: [StoreDetailCell] = [.Header, .Detail, .Map]
    let kStoreDetailHeaderCell = "StoreDetailHeaderCell"
    let kStoreDetailAboutCell = "StoreDetailAboutCell"
    let kStoreDetailMapCell = "StoreDetailMapCell"
    
    let grayColor = UIColor.init(red: 240.0/255.0, green: 240.0/255.0, blue: 240.0/255.0, alpha: 1)
    
    @IBOutlet weak var tableView: UITableView!
    
    var store:Store!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //registerCellForTableView()
        
        self.tableView.backgroundColor = grayColor
        self.view.backgroundColor = grayColor
        store.isFavorite = SharedObjects.shared.isStoreFavorited(store: self.store)
        productButton.makeRoundedCorner()
        productButton.backgroundColor = UIColor.orange
       // getStoreDetails()
        
        let height = (self.view.frame.size.width * 0.35) * 0.40
        let rightConstriant = (self.view.frame.size.width * 0.35) * 0.25
        self.imageViewHeightConstraint.constant = height
        self.topConstraint.constant = self.view.frame.size.height * 0.73
        self.imageViewTopConstraint.constant = self.view.frame.size.height * 0.65 - (height / 2)
        self.leftConstraint.constant = self.view.frame.size.width * 0.1576
        self.imageViewRightConstant.constant = rightConstriant
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
    
    @objc func callStore() {
        if store.phoneNumber.count > 0 {
            if let url = URL(string: "tel://\(store.phoneNumber)") {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        }
    }
}

extension MockStoreDetailViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cellArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellType = cellArray[indexPath.row]
        
        switch cellType {
        case .Header:
            let headerCell = self.tableView.dequeueReusableCell(withIdentifier: kStoreDetailHeaderCell) as! StoreDetailHeaderCell
            headerCell.shopImageView.image = UIImage.init(named: "watch")
            if self.store.isFavorite {
                headerCell.favoriteButton.setImage(UIImage.init(named: "favorite"), for: .normal)
            }else {
                headerCell.favoriteButton.setImage(UIImage.init(named: "unfavorite"), for: .normal)
            }
            headerCell.shopSubLabel.text = "South Lake Union"
            self.store.workingHours()
            headerCell.favoriteButton.addTarget(self, action: #selector(StoreDetailViewController.updateFavorite(sender:)), for: .touchUpInside)
            headerCell.shopLabel.text = store.name
            
            headerCell.shopCategoryImageView.image = UIImage.init(named: "clothing")
            
            return headerCell
        case .Detail:
            let aboutCell = self.tableView.dequeueReusableCell(withIdentifier: kStoreDetailAboutCell) as! StoreDetailAboutCell
            aboutCell.globeButton.addTarget(self, action: #selector(StoreDetailViewController.openStoreUrl), for: .touchUpInside)
            aboutCell.callButton.addTarget(self, action: #selector(StoreDetailViewController.callStore), for: .touchUpInside)
            aboutCell.descriptionLabel.text = store.description
            
            if let _ = URL.init(string: store.storeUrl) {
                aboutCell.globeButton.isHidden = false
            }
            else {
                aboutCell.globeButton.isHidden = true
            }
            
            if store.phoneNumber.count > 0 {
                aboutCell.callButton.isHidden = false
            }
            else {
                aboutCell.callButton.isHidden = true
            }
            
            aboutCell.workingHourLabel.text = self.store.workingHours()
            
            aboutCell.mailButton.isHidden = false
            
            aboutCell.toolsLeftConstraint.isActive = true
            aboutCell.toolsRightConstraint.isActive = false
            
            return aboutCell
        case .Map:
            let mapCell = self.tableView.dequeueReusableCell(withIdentifier: kStoreDetailMapCell) as! StoreDetailMapCell
            
            var coordinate = CLLocationCoordinate2D.init(latitude: CLLocationDegrees(0), longitude: CLLocationDegrees(0))
            
            if self.store.latitude != 0 && self.store.longitude != 0 {
                coordinate = CLLocationCoordinate2D.init(latitude: CLLocationDegrees(self.store.latitude), longitude: CLLocationDegrees(self.store.longitude))
            }
            else {
                coordinate = CLLocationCoordinate2D.init(latitude: CLLocationDegrees( 47.608013), longitude: CLLocationDegrees(-122.335167))
            }
            
            mapCell.mapView.setCenter(coordinate, animated: true)
            
            let annotation = MKPointAnnotation()
            annotation.title = self.store.name
            annotation.coordinate = coordinate
            let region = MKCoordinateRegion(center: annotation.coordinate, latitudinalMeters: CLLocationDistance(exactly: 1000)!, longitudinalMeters: CLLocationDistance(exactly: 1000)!)
            mapCell.mapView.setRegion(region, animated: true)
            mapCell.mapView.addAnnotation(annotation)
            mapCell.mapButton.addTarget(self, action: #selector(StoreDetailViewController.openMaps), for: .touchUpInside)
            return mapCell
        }
    }
}

extension MockStoreDetailViewController: UITableViewDelegate {
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

extension MockStoreDetailViewController {
    func getStoreDetails() {
        let urlString = "\(ApiServiceURL.apiInterface(.storeDetail))\(self.store.storeId)"
        
        DispatchQueue.main.async {
            UIApplication.shared.isNetworkActivityIndicatorVisible = true
        }
        Downloader.getStoreJSONUsingURLSession(url: urlString) { (result, errorString) in
            if let _ = errorString {
                
            }
            else {
                if let result = result, let data = result["data"] as? Array<Dictionary<String,Any?>>, data.count > 0, let storeDictionary = data.first {
                    if let storeDescription = storeDictionary["description"] as? String {
                        self.store.description = storeDescription
                    }
                    
                    if let latitude = storeDictionary["latitude"] as? Float {
                        self.store.latitude = latitude
                    } else if let latitude = storeDictionary["latitude"] as? Double {
                        self.store.latitude = Float(latitude)
                    } else if let latitude = storeDictionary["latitude"] as? Int {
                        self.store.latitude = Float(latitude)
                    }
                    
                    if let longitude = storeDictionary["longitude"] as? Float {
                        self.store.longitude = longitude
                    } else if let longitude = storeDictionary["longitude"] as? Double {
                        self.store.longitude = Float(longitude)
                    } else if let longitude = storeDictionary["longitude"] as? Int {
                        self.store.longitude = Float(longitude)
                    }
                    
                    if let phoneNumber = storeDictionary["phonenumber"] as? String {
                        self.store.phoneNumber = phoneNumber
                    }
                    
                    if let storeUrl = storeDictionary["store_url"] as? String {
                        self.store.storeUrl = storeUrl
                    }
                    
                    self.store = Store.init(dictionary: storeDictionary)
                    self.store.isFavorite = SharedObjects.shared.isStoreFavorited(store: self.store)
                    
                }
                DispatchQueue.main.async {
                    self.registerCellForTableView()
//                    self.tableView.reloadData()
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


extension MockStoreDetailViewController: SFSafariViewControllerDelegate {
    func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
        controller.dismiss(animated: true, completion: {})
    }
}

extension MockStoreDetailViewController {
    @objc func openMaps() {
        // Open and show coordinate
        //        let url = "http://maps.apple.com/maps?saddr=\(self.store.latitude),\(self.store.longitude)"
        //        UIApplication.shared.openURL(URL(string:url)!)
        
        var latitude: CLLocationDegrees = CLLocationDegrees(self.store.latitude)
        var longitude: CLLocationDegrees = CLLocationDegrees(self.store.longitude)
        
        if self.store.latitude != 0 && self.store.longitude != 0 {
            latitude = CLLocationDegrees(self.store.latitude)
            longitude = CLLocationDegrees(self.store.longitude)
        }
        else {
            latitude = 47.608013
            longitude = -122.335167
        }
        
        let regionDistance:CLLocationDistance = 100
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

