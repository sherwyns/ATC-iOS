//
//  ATCTabBarViewController.swift
//  ATC
//
//  Created by Rathinavel, Dhandapani on 21/10/18.
//  Copyright © 2018 Rathinavel, Dhandapani. All rights reserved.
//

import UIKit
import ESTabBarController_swift

class ATCTabBarViewController: ESTabBarController {
    
    let credentialSegueId = "credentialSegue"

    override func viewDidLoad() {
        super.viewDidLoad()
        customizeViews()
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if ATCUserDefaults.isFirstTime() {
            showRegistration()
            //ATCUserDefaults.userOpenedApp()
        }
    }
    
    func showRegistration() {
        self.performSegue(withIdentifier: credentialSegueId, sender: nil)
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

