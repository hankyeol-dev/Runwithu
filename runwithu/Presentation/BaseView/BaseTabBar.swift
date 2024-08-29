//
//  BaseTabBar.swift
//  runwithu
//
//  Created by 강한결 on 8/23/24.
//

import UIKit

import RxSwift
import RxCocoa
import RxGesture

final class BaseTabBar: BaseView {
   private let disposeBag = DisposeBag()
   private let tabItemTapped = PublishSubject<Int>()
   var tabItemTap: PublishSubject<Int> {
      return tabItemTapped
   }
   
   private let tabItemStack = UIStackView()
   private let communityTab = BaseTabItem(tabItem: .community, tabIndex: 0)
   private let runningGroupTab = BaseTabItem(tabItem: .runningGroup, tabIndex: 1)
   private let myPageTab = BaseTabItem(tabItem: .mypage, tabIndex: 2)
   private lazy var tabItems: [BaseTabItem] = [communityTab, runningGroupTab, myPageTab]
   
   init() {
      super.init(frame: .zero)
      bindView()
      tapTabItem(for: 0)
   }
   
   override func setSubviews() {
      super.setSubviews()
      addSubviews(tabItemStack)
      tabItems.forEach {
         tabItemStack.addArrangedSubview($0)
      }
   }
   
   override func setLayout() {
      super.setLayout()
      tabItemStack.snp.makeConstraints { make in
         make.edges.equalToSuperview()
      }
   }
   
   override func setUI() {
      super.setUI()
      tabItemStack.distribution = .fillEqually
      tabItemStack.alignment = .center
      tabItemStack.backgroundColor = .systemGray5
      tabItemStack.layer.cornerRadius = 16
      tabItemStack.clipsToBounds = true
      tabItems.forEach {
         $0.translatesAutoresizingMaskIntoConstraints = false
         $0.clipsToBounds = true
      }
   }
}

extension BaseTabBar {
   private func tapTabItem(for index: Int) {
      tabItems.forEach {
         $0.isTapped = $0.tabIndex == index
      }
      tabItemTapped.onNext(index)
   }
   
   private func bindView() {
      tabItems.enumerated().forEach { idx, tabItem in
         tabItem.rx.tapGesture()
            .bind(with: self) { v, _ in
               v.tapTabItem(for: v.tabItems[idx].tabIndex)
            }
            .disposed(by: disposeBag)
      }
   }
}
