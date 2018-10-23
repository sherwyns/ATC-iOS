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

        // Do any additional setup after loading the view.
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if ATCUserDefaults.isFirstTime() {
            self.performSegue(withIdentifier: credentialSegueId, sender: nil)
            //ATCUserDefaults.userOpenedApp()
        }
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
