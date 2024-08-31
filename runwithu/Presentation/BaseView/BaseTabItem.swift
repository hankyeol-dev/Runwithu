//
//  BaseTabItem.swift
//  runwithu
//
//  Created by 강한결 on 8/23/24.
//

import UIKit

import SnapKit

final class BaseTabItem: BaseView {
   private let tabItem: TabItems
   let tabIndex: Int
   var isTapped: Bool = false {
      didSet {
         animatedTab()
      }
   }
   
   private let tabItemContainer = UIView()
   private let tabImage = UIImageView()
   private let tabName = BaseLabel(for: "", font: .systemFont(ofSize: 12), color: .black)
   
   init(tabItem: TabItems, tabIndex: Int) {
      self.tabItem = tabItem
      self.tabIndex = tabIndex
      super.init(frame: .zero)
   }
   
   override func setSubviews() {
      super.setSubviews()
      
      addSubview(tabItemContainer)
      tabItemContainer.addSubviews(tabImage, tabName)
   }
   
   override func setLayout() {
      super.setLayout()
      
      tabItemContainer.snp.makeConstraints { make in
         make.edges.equalToSuperview()
         make.center.equalToSuperview()
      }
      tabImage.snp.makeConstraints { make in
         make.centerX.top.equalToSuperview()
         make.bottom.equalTo(tabName.snp.top)
         make.size.equalTo(36)
      }
      tabName.snp.makeConstraints { make in
         make.horizontalEdges.bottom.equalToSuperview()
         make.height.equalTo(16)
      }
   }
   
   override func setUI() {
      super.setUI()
      
      tabImage.image = isTapped ? tabItem.selectedTabIcons : tabItem.unSelectedTabIcons
      tabName.text = tabItem.tabName
      tabName.textAlignment = .center
   }
   
   private func animatedTab() {
      UIView.animate(withDuration: 0.5) { [weak self] in
         guard let self else { return }
         self.tabName.alpha = self.isTapped ? 1.0 : 0.6
      }
      UIView.transition(
         with: tabImage,
         duration: 0.5) { [weak self] in
            guard let self else { return }
            self.tabImage.image = isTapped ? self.tabItem.selectedTabIcons : self.tabItem.unSelectedTabIcons
         }
   }
}
