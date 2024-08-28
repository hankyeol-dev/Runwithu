//
//  SceneDelegate.swift
//  runwithu
//
//  Created by 강한결 on 8/14/24.
//

import UIKit
import RxSwift

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
   
   var window: UIWindow?
   
   func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
      guard let scene = (scene as? UIWindowScene) else { return }
      window = UIWindow(windowScene: scene)
      
      // MARK: MainTabBar
      let root0 = UINavigationController(rootViewController: MainTabbarController())
      
      
      // MARK: ProfileView
      let root1 = UINavigationController(
         rootViewController: ProfileViewController(
            bv: ProfileView(),
            vm: ProfileViewModel(
               disposeBag: DisposeBag(),
               networkManager: NetworkService.shared,
               isUserProfile: false, userId: AppEnvironment.demoUserId),
            db: DisposeBag())
      )
      
      // MARK: LoginView
      let root2 = UINavigationController(
         rootViewController: LoginViewController(
            bv: LoginView(),
            vm: LoginViewModel(
               disposeBag: DisposeBag(),
               networkManager: NetworkService.shared,
               tokenManager: TokenManager.shared),
            db: DisposeBag()
         )
      )
      
      window?.rootViewController = root1
      window?.makeKeyAndVisible()
   }
   
   func sceneDidDisconnect(_ scene: UIScene) { }
   
   func sceneDidBecomeActive(_ scene: UIScene) {   }
   
   func sceneWillResignActive(_ scene: UIScene) {
   }
   
   func sceneWillEnterForeground(_ scene: UIScene) {
   }
   
   func sceneDidEnterBackground(_ scene: UIScene) {
   }
   
   
}

