//
//  ForgotPasswordViewController.swift
//  ATC
//
//  Created by Rathinavel, Dhandapani on 03/02/19.
//  Copyright © 2019 Rathinavel, Dhandapani. All rights reserved.
//

import UIKit
import MBProgressHUD
import KSToastView

class ForgotPasswordViewController: UIViewController {

    @IBOutlet weak var submitButton: UIButton!
    
    @IBOutlet weak var mailTextField: UITextField!
    
    @IBOutlet weak var HUD:MBProgressHUD!
    
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        customizeViews()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard), name: UIResponder.keyboardWillHideNotification, object: nil)
        notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard), name: UIResponder.keyboardWillShowNotification, object: nil)
    }
    
    func customizeViews() {
        mailTextField.layer.cornerRadius = 22.0
        mailTextField.layer.borderColor = UIColor.white.cgColor
        mailTextField.layer.borderWidth = 0.5
        mailTextField.layer.masksToBounds = true
        
        submitButton.layer.cornerRadius = 22.0
        submitButton.layer.borderColor = UIColor.white.cgColor
        submitButton.layer.borderWidth = 0.5
        submitButton.layer.masksToBounds = true
    
        submitButton.applyGradient(withColours: [.lightOrange(), .darkOrange()], gradientOrientation: .horizontal)
        mailTextField.delegate = self
    }

    @objc func adjustForKeyboard(notification: Notification) {
        let userInfo = notification.userInfo!
        
        let keyboardScreenEndFrame = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        let keyboardViewEndFrame = view.convert(keyboardScreenEndFrame, from: view.window)
        
        if notification.name == UIResponder.keyboardWillHideNotification {
            self.bottomConstraint.constant = 50
        } else {
            self.bottomConstraint.constant = 50 + keyboardViewEndFrame.size.height
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

    @IBAction func forgotPasswordAction() {
        self.view.endEditing(true)
        if !mailTextField.isTextEmpty() {
            if let mailText = mailTextField.text, mailText.isValidEmail() {
                let urlString = ApiServiceURL.apiInterface(.forgotPassword)
                
                var parameterDictionary = Dictionary<String, Any>()
                parameterDictionary["email"] = mailText
                parameterDictionary["url"]   =  "https://app.aroundthecorner.store/" as? AnyObject
                self.showHUD()
                Downloader.getJSONUsingURLSessionPOSTRequest(url: urlString, parameters: parameterDictionary) { (forgotPasswordDictionary, errorString) in
                    self.hideHUD()
                    if let errorString = errorString {
                        KSToastView.ks_showToast(errorString)
                        return
                    }
                    else {
                        KSToastView.ks_showToast("Please check your mail inbox to reset the password!")
                        return
                    }
                }
            }
            else {
                KSToastView.ks_showToast("Please enter valid email address")
            }
        }
        else {
            KSToastView.ks_showToast("Please enter valid email address")
        }
    }
}

extension ForgotPasswordViewController {
    // MARK: - HUD
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

extension ForgotPasswordViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        
    }
}
