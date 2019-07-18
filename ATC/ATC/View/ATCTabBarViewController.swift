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
    
    var isFirst:Bool = true
    override func viewDidLoad() {
        super.viewDidLoad()
        customizeViews()
    }
  
    override func viewWillAppear(_ animated: Bool) {
        NotificationCenter.default.addObserver(self, selector: #selector(ATCTabBarViewController.showRegistration(sender:)), name: NotificationConstant.showRegistration, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(ATCTabBarViewController.showMyAccount), name: NotificationConstant.showMyAccount, object: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if isFirst {
            self.selectedViewController = self.viewControllers?[1]
            isFirst = !isFirst
        }
        if ATCUserDefaults.isFirstTime() {
            showRegistration(sender: nil)
        }
    }
    
    @objc func showRegistration(sender: Any?) {
        if let notificationObject = sender as? NSNotification,  let operationPayload = notificationObject.object as? OperationPayload {
            self.performSegue(withIdentifier: credentialSegueId, sender: operationPayload)
        }
        else {
            self.performSegue(withIdentifier: credentialSegueId, sender: nil)
        }
    }
    
    @objc func showMyAccount() {
        self.performSegue(withIdentifier: showMyAccountScreen, sender: nil)
    }
    
    @IBAction func startShopping(segue: UIStoryboardSegue) {
        ATCUserDefaults.userOpenedApp()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let segueIdentifier = segue.identifier {
            if segueIdentifier == credentialSegueId, let favorite = sender as? OperationPayload {
                if let navController = segue.destination as? UINavigationController, let credentialVC = navController.viewControllers.first as? CredentialViewController {
                    credentialVC.operationPayload = favorite
                }
            }
        }
    }
}

extension ATCTabBarViewController {
    func customizeViews() {
        view.applyGradient(withColours: [.lightBlue(), .darkBlue()], gradientOrientation: .vertical)
    }
}

extension ATCTabBarViewController : SlideMenuControllerDelegate {
  
}

extension ATCTabBarViewController {
    open override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        guard let index = tabBar.items?.index(of: item) else { return }
        
        if index == 1 {
            NotificationCenter.default.post(name: NotificationConstant.reloadHome, object: nil)
        }
        super.tabBar(tabBar, didSelect: item)
    }
}

