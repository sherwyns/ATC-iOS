//
//  AccountViewController.swift
//  ATC
//
//  Created by Rathinavel, Dhandapani on 05/11/18.
//  Copyright © 2018 Rathinavel, Dhandapani. All rights reserved.
//

import UIKit

class AccountViewController: UIViewController {
    @IBOutlet weak var userLabel: UILabel!
    
    @IBOutlet weak var expand: UIButton!
    @IBOutlet weak var signOut: UIButton!
    @IBOutlet weak var closeButton: UIButton!
    
    @IBOutlet weak var newPasswordTextField: UITextField!
    @IBOutlet weak var oldPasswordTextField: UITextField!
    @IBOutlet weak var confirmPasswordTextField: UITextField!
    
    @IBOutlet weak var changePasswordStackView: UIStackView!

    override func viewDidLoad() {
        super.viewDidLoad()
        customizeViews()
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let userName = ATCUserDefaults.userInfo() {
            self.userLabel.text = userName
        }
        else {
            self.userLabel.text = "Dhandapani Rathinavel"
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
    func customizeViews() {
        newPasswordTextField.makeRoundedCorner()
        oldPasswordTextField.makeRoundedCorner()
        confirmPasswordTextField.makeRoundedCorner()
        signOut.makeRoundedCorner()
        signOut.applyGradient(withColours: [.lightOrange(), .darkOrange()], gradientOrientation: .horizontal)
    }
    
    @IBAction func showOrHideChangePassword() {
        changePasswordStackView.isHidden = !changePasswordStackView.isHidden
        if changePasswordStackView.isHidden {
            expand.setTitle("+", for: .normal)
        }
        else {
            expand.setTitle("-", for: .normal)
        }
    }
    
    @IBAction func signoutAction() {
        ATCUserDefaults.logoutApp()
        self.dismiss(animated: true) {}
    }

}
