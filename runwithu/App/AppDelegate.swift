//
//  AppDelegate.swift
//  runwithu
//
//  Created by 강한결 on 8/14/24.
//

import UIKit

import IQKeyboardManagerSwift
import iamport_ios

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
   
   func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
      IQKeyboardManager.shared.enable = true
      return true
   }
   
   func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
      return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
   }
   
   func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {  }
   
   func application(_ application: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
      Iamport.shared.receivedURL(url)
      return true
   }
}

