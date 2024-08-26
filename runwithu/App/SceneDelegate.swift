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
      
      //      let root = LoginViewController(
      //         bv: LoginView(),
      //         vm: LoginViewModel(),
      //         db: DisposeBag()
      //      )
//            let root = RunningGroupListViewController(
//               bv: RunningGroupListView(),
//               vm: RunningGroupListViewModel(),
//               db: DisposeBag()
//            )
      
//            let root = RunningInvitationCreateViewController(
//               bv: RunningInvitationCreateView(),
//               vm: RunningInvitationCreateViewModel(
//                  disposeBag: DisposeBag(), networkManager: NetworkService.shared
//               ),
//               db: DisposeBag())
      
//      let root = ProfileViewController(
//         bv: ProfileView(), 
//         vm: ProfileViewModel(
//            disposeBag: DisposeBag(),
//            networkManager: NetworkService.shared,
//            isUserProfile: true
//         ),
//         db: DisposeBag()
//      )
//      let root = UINavigationController(rootViewController: MainTabbarController())
      let root = QnaDetailViewController(
         bv: QnaDetailView(),
         vm: QnaDetailViewModel(disposeBag: DisposeBag(), networkManager: NetworkService.shared, qnaId: AppEnvironment.demoQnaId),
         db: DisposeBag())
//      let root = RunningEpiloguePostViewController(
//         bv: RunningEpiloguePostView(),
//         vm: RunningEpiloguePostViewModel(
//            disposeBag: DisposeBag(), 
//            networkManager: NetworkService.shared,
//            isInGroupSide: false
//         ),
//         db: DisposeBag()
//      )
//      let root = UINavigationController(
//         rootViewController: BottomeSheetViewController(
//            titleText: "커뮤니티 글 작성",
//            selectedItems: PostsCommunityType.allCases.map { $0.byKoreanTitle },
//            isScrolled: false,
//            disposeBag: DisposeBag()
//         )
//      )
      
      //       let root = UINavigationController(rootViewController: ViewController())
      //
      //      let vc = UINavigationController(
      //         rootViewController: root
      //      )
      
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

