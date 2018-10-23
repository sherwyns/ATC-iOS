//
//  CredentialViewController.swift
//  ATC
//
//  Created by Rathinavel, Dhandapani(AWF) on 22/10/18.
//  Copyright © 2018 Rathinavel, Dhandapani. All rights reserved.
//

import UIKit

class CredentialViewController: UIViewController {
    
    @IBOutlet weak var signupButton: UIButton!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var skipRegistrationButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        customizeViews()
        skipRegistrationButton.layer.borderColor = UIColor.clear.cgColor
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     
    }

}


extension CredentialViewController {
    func customizeViews() {
        signupButton.makeRoundedCorner()
        loginButton.makeRoundedCorner()
        skipRegistrationButton.makeRoundedCorner()
    }
    
    
}
