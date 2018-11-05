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
    }
    //showMyAccountScreen
  
    override func viewWillAppear(_ animated: Bool) {
        NotificationCenter.default.addObserver(self, selector: #selector(ATCTabBarViewController.showRegistration), name: NotificationConstant.showRegistration, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(ATCTabBarViewController.showMyAccount), name: NotificationConstant.showMyAccount, object: nil)
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
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

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
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

