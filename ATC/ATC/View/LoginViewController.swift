//
//  LoginViewController.swift
//  ATC
//
//  Created by Rathinavel, Dhandapani on 22/10/18.
//  Copyright © 2018 Rathinavel, Dhandapani. All rights reserved.
//

import UIKit
import MBProgressHUD
import KSToastView
import GoogleSignIn
import FBSDKLoginKit

class LoginViewController: UIViewController {
    
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    
    @IBOutlet weak var facebookButton: UIButton!
    @IBOutlet weak var googleButton: GIDSignInButton!
    @IBOutlet weak var loginButton: UIButton!

    @IBOutlet weak var HUD:MBProgressHUD!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        customizeViews()
        loginButton.layer.borderColor = UIColor.clear.cgColor
        
        self.navigationController?.interactivePopGestureRecognizer?.delegate = self
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = true
        
        GIDSignIn.sharedInstance().uiDelegate = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        addHUDToView()
        
//        emailTextField.text = "testx@enqos.com"
//        passwordTextField.text = "enqos@123"
        
        
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
    }
    
    @IBAction func loginAction() {
        self.view.endEditing(true)

        if !emailTextField.isTextEmpty() {
            
            if !passwordTextField.isTextEmpty() {
               
                var parameterDictionary = Dictionary<String, String>()
                parameterDictionary["username"] = self.emailTextField.text
                parameterDictionary["password"]      = self.passwordTextField.text
                
                self.showHUD()
                
                let urlString = ApiServiceURL.apiInterface(.Login)
                
                Downloader.getJSONUsingURLSession(url: urlString, parameters: parameterDictionary) { (result, errorString) in
                    if let error = errorString {
                        self.hideHUD()
                        KSToastView.ks_showToast(error)
                    }
                    else {
                        print(parameterDictionary)
                        if let error = parameterDictionary["error"] as? Dictionary<String, AnyObject?> {
                            if let message = error["message"] as? String {
                                KSToastView.ks_showToast(message)
                            }
                        }
                        else {
                            DispatchQueue.main.async(execute: { () -> Void in
                                self.performSegue(withIdentifier: "startShoppingSegue", sender: nil)
                                KSToastView.ks_showToast("Welcome!")
                            })
                        }
                    }
                }
                
            }
            else {
                
                KSToastView.ks_showToast("Enter Password!")
            }
        }
        else {
            KSToastView.ks_showToast("Enter  User Name!")
        }
        self.hideHUD()
        return
    }
    
    @IBAction func googleLoginPressed() {
        GIDSignIn.sharedInstance()?.delegate = self
        GIDSignIn.sharedInstance()?.uiDelegate = self
        GIDSignIn.sharedInstance()?.signIn()
    }
    
    @IBAction func fbLoginPressed() {
        let loginManager = FBSDKLoginManager()
        
        loginManager.logIn(withReadPermissions: ["public_profile", "email"], from: self) { (result, error) in
            print(error)
            print(result)
            if let error = error {
                KSToastView.ks_showToast(error.localizedDescription)
            }
            else {
                FBSDKGraphRequest.init(graphPath: "me", parameters: ["fields":"email, first_name, last_name"])?.start(completionHandler: { (requestConnection, result, error) in
                    if let error = error {
                        KSToastView.ks_showToast(error.localizedDescription)
                    }
                    else {
                        let result = result as! Dictionary<String, String>
                        if let email = result["email"] as? String, let firstName = result["first_name"] as? String, let lastName = result["last_name"] as? String {
                            var parameterDictionary = Dictionary<String, String>()
                            parameterDictionary["email"] = email
                            parameterDictionary["externalid"]      = "user.userID"
                            parameterDictionary["provider"]      = "facebook"
                            self.showHUD()
                            
                            let urlString = ApiServiceURL.apiInterface(.socialSignUp)
                            
                            Downloader.getJSONUsingURLSession(url: urlString, parameters: parameterDictionary) { (result, errorString) in
                                if let error = errorString {
                                    KSToastView.ks_showToast(error)
                                }
                                else {
                                    DispatchQueue.main.async(execute: { () -> Void in
                                        self.hideHUD()
                                        self.performSegue(withIdentifier: "startShoppingSegue", sender: nil)
                                        KSToastView.ks_showToast("Welcome!")
                                    })
                                    
                                    print(" result \(parameterDictionary)")
                                }
                            }
                        }
                    }
                })
            }
        }
    }
    
}

extension LoginViewController {
    // MARK: - HUD
    func addHUDToView() {
//        HUD = MBProgressHUD(view: self.view)
//
//        HUD.frame.origin = CGPoint(x: self.view.frame.origin.x/2, y: self.view.frame.origin.y/2)
//        HUD.frame.size  = CGSize(width: 50, height: 50)
//        self.view.addSubview(HUD)
//        HUD.mode = MBProgressHUDMode.indeterminate
//        HUD.isUserInteractionEnabled = true
    }
    func showHUD(){
        DispatchQueue.main.async(execute: { () -> Void in
            self.HUD.show(animated: true)
        })
    }
    
    func hideHUD(){
        DispatchQueue.main.async(execute: { () -> Void in
            self.HUD.hide(animated: true)
        })
    }
}

extension LoginViewController {
    func customizeViews() {
        passwordTextField.makeRoundedCorner()
        emailTextField.makeRoundedCorner()
        facebookButton.makeRoundedCorner()
        googleButton.makeRoundedCorner()
        loginButton.makeRoundedCorner()
        loginButton.applyGradient(withColours: [.lightOrange(), .darkOrange()], gradientOrientation: .horizontal)
        view.applyGradient(withColours: [.lightBlue(), .darkBlue()], gradientOrientation: .vertical)
    }
}

extension LoginViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldBeRequiredToFailBy otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}

extension UIView {
    func makeRoundedCorner() {
        self.layer.cornerRadius = 30.0
        self.layer.borderColor = UIColor.white.cgColor
        self.layer.borderWidth = 0.5
        self.layer.masksToBounds = true
    }
}

extension LoginViewController: GIDSignInUIDelegate {
    
}

extension LoginViewController: GIDSignInDelegate {
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        if error != nil {
            
        }else {
            print(user.profile.email)
            
            var parameterDictionary = Dictionary<String, String>()
            parameterDictionary["email"] = user.profile.email!
            parameterDictionary["externalid"]      = user.userID
            parameterDictionary["provider"]      = "google"
            self.showHUD()
            
            let urlString = ApiServiceURL.apiInterface(.socialSignUp)
            
            Downloader.getJSONUsingURLSession(url: urlString, parameters: parameterDictionary) { (result, errorString) in
                if let error = errorString {
                    KSToastView.ks_showToast(error)
                }
                else {
                    DispatchQueue.main.async(execute: { () -> Void in
                      self.hideHUD()
                        self.performSegue(withIdentifier: "startShoppingSegue", sender: nil)
                        KSToastView.ks_showToast("Welcome!")
                    })
                    
                    print(" result \(parameterDictionary)")
                }
            }
        }
    }
}
