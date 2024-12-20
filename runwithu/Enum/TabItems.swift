//
//  TabItems.swift
//  runwithu
//
//  Created by 강한결 on 8/23/24.
//

import UIKit

import RxSwift

enum TabItems: CaseIterable {
   case community
   case runningGroup
   case mypage
}

extension TabItems {
   var viewController: UINavigationController {
      switch self {
      case .community:
         let vc = UINavigationController(
            rootViewController: RunningCommunityViewController(
               bv: RunningCommunityView(),
               vm: RunningCommunityViewModel(disposeBag: DisposeBag(), networkManager: NetworkService.shared),
               db: DisposeBag()
            )
         )
         vc.hidesBottomBarWhenPushed = true
         return vc
      case .runningGroup:
         let vc = UINavigationController(
            rootViewController: RunningGroupListViewController(
               bv: RunningGroupListView(),
               vm: RunningGroupListViewModel(disposeBag: DisposeBag(), networkManager: NetworkService.shared),
               db: DisposeBag()
            )
         )
         vc.hidesBottomBarWhenPushed = true
         return vc
      case .mypage:
         let vc = UINavigationController(
            rootViewController: ProfileViewController(
               bv: ProfileView(),
               vm: ProfileViewModel(disposeBag: DisposeBag(), networkManager: NetworkService.shared, isUserProfile: true),
               db: DisposeBag()
            )
         )
         vc.hidesBottomBarWhenPushed = true
         return vc
      }
   }
   
   var unSelectedTabIcons: UIImage {
      switch self {
      case .community:
         return .communityUnselected
      case .runningGroup:
         return .runninggroupUnselected
      case .mypage:
         return .userUnselected
      }
   }
   
   var selectedTabIcons: UIImage {
      switch self {
      case .community:
         return .communitySelected
      case .runningGroup:
         return .runninggroupSelected
      case .mypage:
         return .userSelected
      }
   }
   
   var tabName: String {
      switch self {
      case .community:
         return "커뮤니티"
      case .runningGroup:
         return "러닝 그룹"
      case .mypage:
         return "나의"
      }
   }
   
}
