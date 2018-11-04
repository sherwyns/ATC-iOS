//
//  SettingViewController.swift
//  ATC
//
//  Created by Rathinavel, Dhandapani on 02/11/18.
//  Copyright © 2018 Rathinavel, Dhandapani. All rights reserved.
//

import Foundation
import UIKit

class SettingViewController: UIViewController {
    
    @IBAction func myAccountAction() {
        if ATCUserDefaults.isUserLoggedIn() {
            
        }
        else {
            postShowRegistration()
            
        }
    }
    
    func postShowRegistration() {
        slideMenuController()?.toggleRight()
        NotificationCenter.default.post(name: NotificationConstant.showRegistration, object: nil)
    }
}
