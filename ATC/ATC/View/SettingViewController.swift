//
//  SettingViewController.swift
//  ATC
//
//  Created by Rathinavel, Dhandapani on 02/11/18.
//  Copyright © 2018 Rathinavel, Dhandapani. All rights reserved.
//

import Foundation
import UIKit
import SafariServices
import CoreLocation

class SettingViewController: UIViewController {
    
    @IBOutlet weak var locationServiceButton: UIButton!
    
    @IBAction func myAccountAction() {
        if ATCUserDefaults.isUserLoggedIn() {
            postShowMyAccount()
        }
        else {
            postShowRegistration()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        NotificationCenter.default.addObserver(self, selector: #selector(SettingViewController.requestLocation), name: NotificationConstant.locationAuthorizationUpdate, object: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        requestLocation()
    }
    
    func postShowRegistration() {
        slideMenuController()?.toggleRight()
        NotificationCenter.default.post(name: NotificationConstant.showRegistration, object: nil)
    }
    
    func postShowMyAccount() {
        slideMenuController()?.toggleRight()
        NotificationCenter.default.post(name: NotificationConstant.showMyAccount, object: nil)
    }
    
    @objc func requestLocation() {
        if CLLocationManager.locationServicesEnabled() {
            locationServiceButton.isUserInteractionEnabled = true
            let status = CLLocationManager.authorizationStatus()
            switch status {
            case .restricted, .denied, .notDetermined:
                locationServiceButton.setTitle("  Enable Location Service", for: .normal)
            case .authorizedWhenInUse, .authorizedAlways:
                locationServiceButton.setTitle("  Disable Location Service", for: .normal)
                break
            }
        } else {
            locationServiceButton.setTitle("  Location Service", for: .normal)
            locationServiceButton.isUserInteractionEnabled = false
        }
    }
    
    
    @IBAction func helpButtonAction() {
        let helpString = "https://app.aroundthecorner.store/mobileappsupport"
        openLinkInSafariViewController(urlString: helpString)
    }
    
    @IBAction func termsButtonAction() {
        let privacyString = "https://app.aroundthecorner.store/termsofservice"
        openLinkInSafariViewController(urlString: privacyString)
    }
    
    @IBAction func privacyButtonAction() {
        let privacyString = "https://app.aroundthecorner.store/termsofservice#privacy_policy"
        openLinkInSafariViewController(urlString: privacyString)
    }
    
    @IBAction func aboutUsButtonAction() {
        let aboutUsString = "https://app.aroundthecorner.store/aboutus"
        openLinkInSafariViewController(urlString: aboutUsString)
    }
    
    @IBAction func openAppSettingsUrl() {
        if let url = URL.init(string: UIApplication.openSettingsURLString),  UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
    
    func openLinkInSafariViewController(urlString: String) {
        let safariVC = SFSafariViewController(url: URL.init(string: urlString)!)
        self.present(safariVC, animated: true, completion: nil)
        safariVC.delegate = self
    }
}


extension SettingViewController: SFSafariViewControllerDelegate {
    func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
        controller.dismiss(animated: true, completion: {})
    }
}
