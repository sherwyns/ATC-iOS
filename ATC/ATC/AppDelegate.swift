//
//  AppDelegate.swift
//  ATC
//
//  Created by Rathinavel, Dhandapani on 20/10/18.
//  Copyright © 2018 Rathinavel, Dhandapani. All rights reserved.
//

import UIKit
import GoogleSignIn
import FBSDKCoreKit
import SlideMenuControllerSwift
import ESTabBarController_swift
import pop

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

  var window: UIWindow?
  var slideMenuController: SlideMenuController!
  var tabbarController:ATCTabBarViewController!

  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
    GIDSignIn.sharedInstance().clientID = "274395748043-r3sagataa6qui95vsuirn74eruvtur9i.apps.googleusercontent.com"
    FBSDKApplicationDelegate.sharedInstance()?.application(application, didFinishLaunchingWithOptions: launchOptions)
    self.window?.rootViewController = entryRootViewController()
    print("USERID \(ATCUserDefaults.userId())")
    print("Mail \(ATCUserDefaults.userInfo())")
    
    Downloader.retrieveStoreFavorites()
    Downloader.retrieveProductFavorites()
    self.window?.makeKeyAndVisible()
    return true
  }
  
  func entryRootViewController() -> UIViewController {
    tabbarController = tabBarController()
    let storyboard = UIStoryboard(name: "Main", bundle: nil)
    let settingViewController = storyboard.instantiateViewController(withIdentifier: "SettingViewController") as! SettingViewController
    slideMenuController = SlideMenuController.init(mainViewController: tabbarController, rightMenuViewController: settingViewController)
    return slideMenuController
  }
  
  func tabBarController() -> ATCTabBarViewController {
    let storyboard = UIStoryboard(name: "Main", bundle: nil)
    let tabBarController = storyboard.instantiateViewController(withIdentifier: "ATCTabBarViewController") as! ATCTabBarViewController
    if let tabBar = tabBarController.tabBar as? ESTabBar {
      tabBar.itemCustomPositioning = .fillIncludeSeparator
      tabBar.itemEdgeInsets = UIEdgeInsets.init(top: 0, left: 30, bottom: 0, right: 30)
      tabBar.backgroundColor = .white
      tabBar.barTintColor = .white
    }

    let searchViewController = storyboard.instantiateViewController(withIdentifier: "SearchViewController")
    let favoriteViewController = storyboard.instantiateViewController(withIdentifier: "FavoriteViewController")
    let homeViewController = storyboard.instantiateViewController(withIdentifier: "HomeViewController")
    
    searchViewController.tabBarItem = ESTabBarItem.init(ESTabBarItemContentView(), title: nil, image: UIImage(named: "icSearch32"), selectedImage: UIImage(named: "icSearch32"))
    homeViewController.tabBarItem = ESTabBarItem.init(IrregularityContentView(), title: nil, image: UIImage(named: "home"), selectedImage: UIImage(named: "home"))
    favoriteViewController.tabBarItem = ESTabBarItem.init(ESTabBarItemContentView(), title: nil, image: UIImage(named: "favor"), selectedImage: UIImage(named: "favor"))
    
    let homeNavigationController = UINavigationController.init(rootViewController: homeViewController)
    homeNavigationController.isNavigationBarHidden = true
    
    let favNavigationController = UINavigationController.init(rootViewController: favoriteViewController)
    favNavigationController.isNavigationBarHidden = true
    
    let searchNavigationController = UINavigationController.init(rootViewController: searchViewController)
    searchNavigationController.isNavigationBarHidden = true
    
    tabBarController.viewControllers = [searchNavigationController, homeNavigationController, favNavigationController]
    
    return tabBarController
  }
  

  func applicationWillResignActive(_ application: UIApplication) {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
  }

  func applicationDidEnterBackground(_ application: UIApplication) {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
  }

  func applicationWillEnterForeground(_ application: UIApplication) {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
  }

  func applicationDidBecomeActive(_ application: UIApplication) {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
  }

  func applicationWillTerminate(_ application: UIApplication) {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
  }

    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        
//        [[FBSDKApplicationDelegate sharedInstance] application:application
//            openURL:url
//            sourceApplication:options[UIApplicationOpenURLOptionsSourceApplicationKey]
//            annotation:options[UIApplicationOpenURLOptionsAnnotationKey]
//        ];
        print(" SourceUrl \(url)")
        
        
//        return true
        if url.absoluteString.contains("fb1928761557159871") {
            return FBSDKApplicationDelegate.sharedInstance()?.application(app, open: url, sourceApplication: options[UIApplication.OpenURLOptionsKey.sourceApplication] as! String, annotation: options[UIApplication.OpenURLOptionsKey.annotation]) ?? false
        }
        else {
            return GIDSignIn.sharedInstance().handle(url as URL?,
                                                     sourceApplication: options[UIApplication.OpenURLOptionsKey.sourceApplication] as! String,
                                                     annotation: options[UIApplication.OpenURLOptionsKey.annotation])
        }

        

    }

}

extension AppDelegate: GIDSignInDelegate {
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!,
              withError error: Error!) {
        if let error = error {
            print("\(error.localizedDescription)")
        } else {
            let _ = user.userID                  // For client-side use only!
            let idToken = user.authentication.idToken // Safe to send to the server
            let email = user.profile.email
            print("mail \(user.profile.email) \(user.authentication.idToken)")
        }
    }
}
//
//class ESTabBarBasicContentView: ESTabBarItemContentView {
//
//  override init(frame: CGRect) {
//    super.init(frame: frame)
//    textColor = UIColor.init(white: 175.0 / 255.0, alpha: 1.0)
//    highlightTextColor = UIColor.init(red: 254/255.0, green: 73/255.0, blue: 42/255.0, alpha: 1.0)
//    iconColor = UIColor.init(white: 175.0 / 255.0, alpha: 1.0)
//    highlightIconColor = UIColor.init(red: 254/255.0, green: 73/255.0, blue: 42/255.0, alpha: 1.0)
//  }
//
//  public required init?(coder aDecoder: NSCoder) {
//    fatalError("init(coder:) has not been implemented")
//  }
//
//
//}
//

class IrregularityContentView: ESTabBarItemContentView {
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    self.imageView.backgroundColor = .white
    if #available(iOS 11.0, *) {
        self.imageView.directionalLayoutMargins = NSDirectionalEdgeInsets.init(top: -30, leading: 5, bottom: 5, trailing: 5)
    } else {
        // Fallback on earlier versions
    }
    self.insets = UIEdgeInsets.init(top: -22, left: 0, bottom: 0, right: 0)
    self.superview?.bringSubviewToFront(self)
    
    textColor = UIColor.init(white: 255.0 / 255.0, alpha: 1.0)
    highlightTextColor = UIColor.init(white: 255.0 / 255.0, alpha: 1.0)
    iconColor = .orange
    highlightIconColor = UIColor.init(white: 255.0 / 255.0, alpha: 1.0)
    backdropColor = .clear
    highlightBackdropColor = .clear
  }
  
  public required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
    let p = CGPoint.init(x: point.x - imageView.frame.origin.x, y: point.y - imageView.frame.origin.y)
    return sqrt(pow(imageView.bounds.size.width / 2.0 - p.x, 2) + pow(imageView.bounds.size.height / 2.0 - p.y, 2)) < imageView.bounds.size.width / 2.0
  }
  
  override func updateLayout() {
    super.updateLayout()
    let height = (1.25 / 1) * frame.size.height
    self.imageView.frame.size = CGSize.init(width: height, height: height)
    self.imageView.contentMode = .center
    self.imageView.backgroundColor = UIColor.white
    self.imageView.layer.cornerRadius = height / 2 
    self.imageView.center = CGPoint.init(x: self.bounds.size.width / 2.0, y: (self.bounds.size.height / 2.0)
      + 10)
    let color = UIColor.init(red: 0, green: 0, blue: 0, alpha: 0.21)
    self.imageView.layer.applySketchShadow(color: color, alpha: 1, x: 0.0, y: -2.0, blur: 0, spread: 0)
    
  }
  
  public override func selectAnimation(animated: Bool, completion: (() -> ())?) {
    let view = UIView.init(frame: CGRect.init(origin: CGPoint.zero, size: CGSize(width: 2.0, height: 2.0)))
    view.layer.cornerRadius = 1.0
    view.layer.opacity = 0.5
    view.backgroundColor = UIColor.init(red: 10/255.0, green: 66/255.0, blue: 91/255.0, alpha: 1.0)
    self.addSubview(view)
    playMaskAnimation(animateView: view, target: self.imageView, completion: {
      [weak view] in
      view?.removeFromSuperview()
      completion?()
    })
  }
  
  public override func reselectAnimation(animated: Bool, completion: (() -> ())?) {
    completion?()
  }
  
  public override func deselectAnimation(animated: Bool, completion: (() -> ())?) {
    completion?()
  }
  
  public override func highlightAnimation(animated: Bool, completion: (() -> ())?) {
    UIView.beginAnimations("small", context: nil)
    UIView.setAnimationDuration(0.2)
    let transform = self.imageView.transform.scaledBy(x: 0.8, y: 0.8)
    self.imageView.transform = transform
    UIView.commitAnimations()
    completion?()
  }
  
  public override func dehighlightAnimation(animated: Bool, completion: (() -> ())?) {
    UIView.beginAnimations("big", context: nil)
    UIView.setAnimationDuration(0.2)
    let transform = CGAffineTransform.identity
    self.imageView.transform = transform
    UIView.commitAnimations()
    completion?()
  }
  
  private func playMaskAnimation(animateView view: UIView, target: UIView, completion: (() -> ())?) {
    view.center = CGPoint.init(x: target.frame.origin.x + target.frame.size.width / 2.0, y: target.frame.origin.y + target.frame.size.height / 2.0)
    
    let scale = POPBasicAnimation.init(propertyNamed: kPOPLayerScaleXY)
    scale?.fromValue = NSValue.init(cgSize: CGSize.init(width: 1.0, height: 1.0))
    scale?.toValue = NSValue.init(cgSize: CGSize.init(width: 36.0, height: 36.0))
    scale?.beginTime = CACurrentMediaTime()
    scale?.duration = 0.3
    scale?.timingFunction = CAMediaTimingFunction.init(name: CAMediaTimingFunctionName.easeOut)
    scale?.removedOnCompletion = true
    
    let alpha = POPBasicAnimation.init(propertyNamed: kPOPLayerOpacity)
    alpha?.fromValue = 0.6
    alpha?.toValue = 0.6
    alpha?.beginTime = CACurrentMediaTime()
    alpha?.duration = 0.25
    alpha?.timingFunction = CAMediaTimingFunction.init(name: CAMediaTimingFunctionName.easeOut)
    alpha?.removedOnCompletion = true
    
    view.layer.pop_add(scale, forKey: "scale")
    view.layer.pop_add(alpha, forKey: "alpha")
    
    scale?.completionBlock = ({ animation, finished in
      completion?()
    })
  }
  
}

extension CALayer {
  func applySketchShadow(
    color: UIColor = .black,
    alpha: Float = 0.5,
    x: CGFloat = 0,
    y: CGFloat = 2,
    blur: CGFloat = 4,
    spread: CGFloat = 0)
  {
    shadowColor = color.cgColor
    shadowOpacity = alpha
    shadowOffset = CGSize(width: x, height: y)
    shadowRadius = blur / 2.0
    if spread == 0 {
      shadowPath = nil
    } else {
      let dx = -spread
      let rect = bounds.insetBy(dx: dx, dy: dx)
      shadowPath = UIBezierPath(rect: rect).cgPath
    }
  }
}
