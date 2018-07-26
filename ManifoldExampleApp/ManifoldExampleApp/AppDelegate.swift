//
//  AppDelegate.swift
//  ManifoldExampleApp
//
//  Created by pivotal on 7/21/18.
//  Copyright © 2018 Pivotal Labs. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

  var window: UIWindow?

  func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions
    launchOptions: [UIApplicationLaunchOptionsKey: Any]?
  ) -> Bool {
    let assetsViewController = AssetsViewController()
    let rootViewController = UINavigationController(
      rootViewController: assetsViewController
    )

    window = UIWindow()
    window?.rootViewController = rootViewController
    window?.makeKeyAndVisible()
    return true
  }

}

