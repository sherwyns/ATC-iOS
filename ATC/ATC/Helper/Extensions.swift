//
//  Extensions.swift
//  ATC
//
//  Created by Rathinavel, Dhandapani on 22/10/18.
//  Copyright © 2018 Rathinavel, Dhandapani. All rights reserved.
//

import Foundation
import UIKit

public extension UITableViewCell {
    func disableSelection() {
        self.selectionStyle = .none
    }
}

public extension UIImage {
    convenience init(color: UIColor, size: CGSize = CGSize(width: 1, height: 1)) {
        let rect = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        UIGraphicsBeginImageContextWithOptions(rect.size, false, 0)
        color.setFill()
        UIRectFill(rect)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        self.init(cgImage: (image?.cgImage!)!)
    }
}

public extension UIColor {
    class func normalBlueColorTranslateApp() -> UIColor {
        return UIColor(red: 40.0/255.0, green: 124.0/255.0, blue: 183.0/255.0, alpha: 1)
    }
    
    class func highlightedBlueColorTranslateApp() -> UIColor {
        return UIColor(red: 22.0/255.0, green: 87.0/255.0, blue: 131.0/255.0, alpha: 1)
    }
    class func goldColorTranslateApp() -> UIColor {
        return UIColor(red: 240.0/255.0, green: 195.0/255.0, blue: 48.0/255.0, alpha: 1)
    }
    
    class func waterBlueColorTranslateApp() -> UIColor {
        return UIColor(red: 144.0/255.0, green: 189.0/255.0, blue: 220.0/255.0, alpha: 1)
    }
}

public extension UIViewController {
    // MARK: Network Validation
    
//    func hasConnectivity() -> Bool {
//        let reachability: Reachability = Reachability.forInternetConnection()
//        let networkStatus: Int = reachability.currentReachabilityStatus().rawValue
//        return networkStatus != 0
//    }
    
    func setNavigationBarTintColor() {
        
        if let navController = self.navigationController {
            navController.navigationBar.tintColor = UIColor.white
        }
    }
    
    func showBackButton() {
        if let navItem = self.navigationItem as? UINavigationItem {
            let backButton = UIBarButtonItem(title: "", style: .plain, target: self, action: #selector(UIViewController.backAction))
            backButton.image = UIImage(named: "backButton")
            backButton.imageInsets.left = -10
            navItem.leftBarButtonItem = backButton
        }
    }
    
    @IBAction func backAction() {
        if let _ = self.navigationController {
            self.navigationController?.popViewController(animated: true)
        }
        else {
            self.dismiss(animated: true, completion: {})
        }
    }
}

extension String {
    func isEqualToString(_ find: String) -> Bool {
        return String(format: self) == find
    }
    
    func isValidEmail() -> Bool {
        // println("validate calendar: \(testStr)")
        let emailRegEx = "^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$"
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: self)
    }
    
    func isValidGmailAddress() -> Bool {
        // println("validate calendar: \(testStr)")
        let emailRegEx = "^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@gmail(?:\\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$"
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: self)
    }
    
    func isValidYahooAddress() -> Bool {
        // println("validate calendar: \(testStr)")
        let emailRegEx = "^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@yahoo(?:\\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$"
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: self)
    }
    
    func isValidOutlookAddress() -> Bool {
        // println("validate calendar: \(testStr)")
        let emailRegEx = "^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@(outlook|hotmail)(?:\\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$"
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: self)
    }
    
    func isValidPassword() throws -> Bool {
        let regex = try NSRegularExpression(pattern: "^(?=.*?[A-Z])(?=.*?[0-9])(?=.*?[a-z])(?=.*?[.!#$%&'*+/=?^_`{|}~-]).{8,100}$", options: .useUnixLineSeparators)
        return regex.firstMatch(in: self, options: NSRegularExpression.MatchingOptions(rawValue: 0), range: NSMakeRange(0, self.count)) != nil
    }
    
    func contains(_ find: String) -> Bool{
        return self.range(of: find) != nil
    }
    
    var capitalizeFirst: String {
        if isEmpty { return "" }
        var result = self
        result.replaceSubrange(startIndex...startIndex, with: String(self[startIndex]).uppercased())
        return result
    }
    
}

//UITextFieldExtensions
extension UITextField {
    func isTextEmpty() -> Bool {
        if let tempText = self.text {
            if tempText.count > 0 {
                return false
            }
            else {
                return true
            }
        }
        else {
            return true
        }
    }
}

class VerticallyCenteredTextView: UITextView {
    override var contentSize: CGSize {
        didSet {
            var topCorrection = (bounds.size.height - contentSize.height * zoomScale) / 2.0
            topCorrection = max(0, topCorrection)
            contentInset = UIEdgeInsets(top: topCorrection, left: 0, bottom: 0, right: 0)
        }
    }
    //
    //    override var text: String! {
    //        didSet {
    //
    //        }
    //    }
}



extension RangeReplaceableCollection where Iterator.Element : Equatable {
    
    // Remove first collection element that is equal to the given `object`:
    mutating func removeObject(_ object : Iterator.Element) {
        if let index = self.index(of: object) {
            self.remove(at: index)
        }
    }
}
