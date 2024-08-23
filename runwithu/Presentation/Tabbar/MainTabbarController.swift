//
//  MainTabbarController.swift
//  runwithu
//
//  Created by 강한결 on 8/23/24.
//

import UIKit

import SnapKit
import RxSwift

final class MainTabbarController: UITabBarController {
   private let disposeBag = DisposeBag()
   
   private let mainTabbar = BaseTabBar()
   
   override func viewDidLoad() {
      super.viewDidLoad()
      setView()
      bindView()
   }
   
   override func viewWillAppear(_ animated: Bool) {
      super.viewWillAppear(animated)
      navigationController?.isNavigationBarHidden = true
   }
   
   private func setView() {
      view.addSubview(mainTabbar)
      mainTabbar.snp.makeConstraints { make in
         make.horizontalEdges.bottom.equalTo(view.safeAreaLayoutGuide).inset(8)
         make.height.equalTo(80)
      }
      
      tabBar.isHidden = true
      selectedIndex = 0
      mainTabbar.translatesAutoresizingMaskIntoConstraints = false
      setViewControllers(TabItems.allCases.map { $0.viewController }, animated: true)
   }
   
   private func bindIndex(for index: Int) {
      selectedIndex = index
   }
   
   private func bindView() {
      mainTabbar.tabItemTap
         .bind(with: self) { tb, index in
            tb.bindIndex(for: index)
         }
         .disposed(by: disposeBag)
   }
}
