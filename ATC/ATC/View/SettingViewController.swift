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

class SettingViewController: UIViewController {
    
    @IBAction func myAccountAction() {
        if ATCUserDefaults.isUserLoggedIn() {
            postShowMyAccount()
        }
        else {
            postShowRegistration()
        }
    }
    
    func postShowRegistration() {
        slideMenuController()?.toggleRight()
        NotificationCenter.default.post(name: NotificationConstant.showRegistration, object: nil)
    }
    
    func postShowMyAccount() {
        slideMenuController()?.toggleRight()
        NotificationCenter.default.post(name: NotificationConstant.showMyAccount, object: nil)
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
