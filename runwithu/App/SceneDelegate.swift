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
      
      //      let root = UINavigationController(
      //         rootViewController: InvitationDetailViewController(
      //            bv: InvitationDetailView(),
      //            vm: InvitationDetailViewModel(disposeBag: DisposeBag(), networkManager: NetworkService.shared, invitationId: AppEnvironment.demoInvitationId),
      //            db: DisposeBag())
      //      )
//            let root = UINavigationController(rootViewController: MainTabbarController())
      //            let root = UINavigationController(
      //               rootViewController: LoginViewController(
      //                  bv: LoginView(),
      //                  vm: LoginViewModel(disposeBag: DisposeBag(),
      //                                     networkManager: NetworkService.shared,
      //                                     tokenManager: TokenManager.shared),
      //                  db: DisposeBag()))
      let root = UINavigationController(
         rootViewController: RunningEpilogueDetailViewController(
            bv: RunningEpilogueDetailView(),
            vm: RunningEpilogueDetailViewModel(disposeBag: DisposeBag(), networkManager: NetworkService.shared, epilogueId: AppEnvironment.demoEpilogueId),
            db: DisposeBag())
      )
      
      
      window?.rootViewController = root
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

