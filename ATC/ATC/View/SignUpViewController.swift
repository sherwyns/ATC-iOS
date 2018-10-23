//
//  SignUpViewController.swift
//  ATC
//
//  Created by Rathinavel, Dhandapani on 22/10/18.
//  Copyright © 2018 Rathinavel, Dhandapani. All rights reserved.
//

import UIKit

class SignUpViewController: UIViewController {
    
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    
    @IBOutlet weak var facebookButton: UIButton!
    @IBOutlet weak var googleButton: UIButton!
    @IBOutlet weak var signupButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        customizeViews()
        signupButton.layer.borderColor = UIColor.clear.cgColor
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
 
    }

}

extension SignUpViewController {
    func customizeViews() {
        passwordTextField.makeRoundedCorner()
        emailTextField.makeRoundedCorner()
        facebookButton.makeRoundedCorner()
        googleButton.makeRoundedCorner()
        signupButton.makeRoundedCorner()
    }
    
    
}
