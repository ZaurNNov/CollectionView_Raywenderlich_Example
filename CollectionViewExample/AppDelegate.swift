//
//  AppDelegate.swift
//  CollectionViewExample
//
//  Created by Zaur Giyasov on 21/09/2018.
//  Copyright © 2018 Zaur Giyasov. All rights reserved.
//

import UIKit
let themeColor = UIColor(red: 0.01, green: 0.4, blue: 0.2, alpha: 1.0)

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        window?.tintColor = themeColor;
        
        return true
    }
}

