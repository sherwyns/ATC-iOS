//
//  CredentialViewController.swift
//  ATC
//
//  Created by Rathinavel, Dhandapani on 22/10/18.
//  Copyright © 2018 Rathinavel, Dhandapani. All rights reserved.
//

import UIKit

class CredentialViewController: UIViewController {
    
    @IBOutlet weak var signupButton: UIButton!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var skipRegistrationButton: UIButton!
    
    var operationPayload: OperationPayload?
    
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
        if let segueIdentifier = segue.identifier {
            if segueIdentifier == "showLogin", let loginVC = segue.destination as? LoginViewController {
                loginVC.operationPayload = self.operationPayload
            }
            else if segueIdentifier == "showSignup", let signupVC = segue.destination as? SignUpViewController {
                signupVC.operationPayload = self.operationPayload
            }
        }
    }
    
    @IBAction func startShoppingAction() {
        self.performSegue(withIdentifier: "startShoppingSegue", sender: nil)
    }

}


extension CredentialViewController {
    func customizeViews() {
        signupButton.makeRoundedCorner()
        loginButton.makeRoundedCorner()
        skipRegistrationButton.makeRoundedCorner()
        skipRegistrationButton.applyGradient(withColours: [.lightOrange(), .darkOrange()], gradientOrientation: .horizontal)
        view.applyGradient(withColours: [.lightBlue(), .darkBlue()], gradientOrientation: .vertical)
    }
}
