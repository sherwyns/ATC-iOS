//
//  ViewController.swift
//  ATC
//
//  Created by Rathinavel, Dhandapani on 20/10/18.
//  Copyright © 2018 Rathinavel, Dhandapani. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var signout: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    @IBAction func logoutAction() {
        LoginManager.logout()
        
        if let parent = self.parent as? ATCTabBarViewController {
            parent.showRegistration()
        }
    }
    
}

