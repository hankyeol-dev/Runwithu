//
//  RoundedMenuView.swift
//  runwithu
//
//  Created by 강한결 on 8/21/24.
//

import UIKit

import SnapKit

final class RoundedMenuView: BaseView {
   private let menuTitle = BaseLabel(for: "", font: .systemFont(ofSize: 14, weight: .semibold), color: .darkGray)
   private let menuCount = BaseLabel(for: "", font: .boldSystemFont(ofSize: 18), color: .black)
   
   convenience init(title: String, count: Int = 0) {
      self.init(frame: .zero)
      menuTitle.bindText(title)
      menuCount.bindText(String(count))
   }
   
   override func setSubviews() {
      super.setSubviews()
      addSubviews(menuTitle, menuCount)
   }
   
   override func setLayout() {
      super.setLayout()
      menuTitle.snp.makeConstraints { make in
         make.top.equalTo(safeAreaLayoutGuide).offset(16)
         make.centerX.equalToSuperview()
      }
      menuCount.snp.makeConstraints { make in
         make.centerX.equalToSuperview()
         make.top.equalTo(menuTitle.snp.bottom).offset(8)
         make.bottom.equalTo(safeAreaLayoutGuide).inset(16)
      }
   }
   
   
   override func setUI() {
      super.setUI()
      
      backgroundColor = .systemGray6
      layer.cornerRadius = 12
      menuTitle.textAlignment = .center
      menuCount.textAlignment = .center
   }
   
   func bindView(count: Int) {
      menuCount.text = String(count)
   }
}
