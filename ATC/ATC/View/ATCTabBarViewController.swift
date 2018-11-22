//
//  ATCTabBarViewController.swift
//  ATC
//
//  Created by Rathinavel, Dhandapani on 21/10/18.
//  Copyright © 2018 Rathinavel, Dhandapani. All rights reserved.
//

import UIKit
import ESTabBarController_swift
import SlideMenuControllerSwift

class ATCTabBarViewController: ESTabBarController {
    
    let credentialSegueId = "credentialSegue"
    let showMyAccountScreen = "showMyAccountScreen"
    override func viewDidLoad() {
        super.viewDidLoad()
        customizeViews()
        
//        self.tabBar(self.tabBar, didSelect: self.tabBar.items[1])
//        if let tabbar = self.tabBar as? ESTabBar {
//            tabBar.select(itemAtIndex: 1, animated: false)
//        }
        
    }
    //showMyAccountScreen
  
    override func viewWillAppear(_ animated: Bool) {
        NotificationCenter.default.addObserver(self, selector: #selector(ATCTabBarViewController.showRegistration), name: NotificationConstant.showRegistration, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(ATCTabBarViewController.showMyAccount), name: NotificationConstant.showMyAccount, object: nil)
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.selectedViewController = self.viewControllers?[1]
        if ATCUserDefaults.isFirstTime() {
            showRegistration()
            //ATCUserDefaults.userOpenedApp()
        }
    }
    
    @objc func showRegistration() {
        self.performSegue(withIdentifier: credentialSegueId, sender: nil)
    }
    
    @objc func showMyAccount() {
        self.performSegue(withIdentifier: showMyAccountScreen, sender: nil)
    }
    
    @IBAction func startShopping(segue: UIStoryboardSegue) {
        ATCUserDefaults.userOpenedApp()
    }

}

extension ATCTabBarViewController {
    func customizeViews() {
        view.applyGradient(withColours: [.lightBlue(), .darkBlue()], gradientOrientation: .vertical)
    }
}

extension ATCTabBarViewController : SlideMenuControllerDelegate {
  
}

