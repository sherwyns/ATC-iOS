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

class LoginViewController: UIViewController {
    
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    
    @IBOutlet weak var facebookButton: UIButton!
    @IBOutlet weak var googleButton: UIButton!
    @IBOutlet weak var loginButton: UIButton!

    var HUD:MBProgressHUD!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        customizeViews()
        loginButton.layer.borderColor = UIColor.clear.cgColor
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        addHUDToView()
        
//        emailTextField.text = "testx@enqos.com"
//        passwordTextField.text = "enqos@123"
        
        self.navigationController?.interactivePopGestureRecognizer?.delegate = self
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = true
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
                
                guard let serviceUrl = URL(string: ApiServiceURL.apiInterface(.Login)) else { return }
                var request = URLRequest(url: serviceUrl)
                request.httpMethod = "POST"
                request.setValue("Application/json", forHTTPHeaderField: "Content-Type")
                guard let httpBody = try? JSONSerialization.data(withJSONObject: parameterDictionary, options: []) else {
                    return
                }
                request.httpBody = httpBody
                
                let session = URLSession.shared
                session.dataTask(with: request) { (data, response, error) in
                    if let response = response {
                        print(response)
                    }
                    if let data = data {
                        do {
                            let json = try JSONSerialization.jsonObject(with: data, options: []) as? Dictionary<String, AnyObject>
                            print(json!)
                            if let json = json {
                                if let error = json["error"] as? Dictionary<String, AnyObject>, let message = error["message"]  as? String {
                                    KSToastView.ks_showToast(message)
                                }
                                else if let id = json["id"] as? String{
                                    UserDefaults.standard.setValue(true, forKey: ATCUserDefaults.kIsUserLoggedIn)
                                }
                                else {
                                    
                                }
                            }
                        }catch {
                            print(error)
                        }
                    }
                    }.resume()
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
}

extension LoginViewController {
    // MARK: - HUD
    func addHUDToView() {
        HUD = MBProgressHUD(view: self.view)
        self.view.addSubview(HUD)
        HUD.frame.origin = CGPoint(x: self.view.frame.origin.x/2, y: self.view.frame.origin.y/2)
        HUD.frame.size  = CGSize(width: 50, height: 50)
        
        HUD.mode = MBProgressHUDMode.indeterminate
        HUD.isUserInteractionEnabled = true
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
