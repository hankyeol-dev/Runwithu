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
      
//      Task {
//         let checkLoginState = await checkLoginState()
//         
//         // MARK: MainTabBar
//         let mainTabbar = UINavigationController(rootViewController: MainTabbarController())
//         
//         // MARK: LoginView
//         let login = UINavigationController(
//            rootViewController: LoginViewController(
//               bv: LoginView(),
//               vm: LoginViewModel(
//                  disposeBag: DisposeBag(),
//                  networkManager: NetworkService.shared,
//                  tokenManager: TokenManager.shared,
//                  userDefaultsManager: UserDefaultsManager.shared
//               ),
//               db: DisposeBag()
//            )
//         )
//         
//         window?.rootViewController = checkLoginState ? mainTabbar : login
//         window?.makeKeyAndVisible()
//      }
      
      window?.rootViewController = UINavigationController(rootViewController: TestViewController())
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
   
   func checkLoginState() async -> Bool {
      do {
         let result = try await NetworkService.shared.request(
            by: UserEndPoint.readMyProfile,
            of: ProfileUserIdOutput.self
         )
         if !result.user_id.isEmpty {
            return true
         } else {
            return false
         }
      } catch NetworkErrors.needToRefreshRefreshToken {
         return false
      } catch {
         return false
      }
   }
}

