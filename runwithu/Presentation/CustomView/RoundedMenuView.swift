//
//  RoundedMenuView.swift
//  runwithu
//
//  Created by 강한결 on 8/21/24.
//

import UIKit

import SnapKit

final class RoundedMenuView: BaseView {
   private let titleLabel = BaseLabel(for: "", font: .systemFont(ofSize: 14, weight: .semibold), color: .darkGray)
   private let countLabel = BaseLabel(for: "", font: .boldSystemFont(ofSize: 20), color: .black)
   
   override func setSubviews() {
      super.setSubviews()
      
      [titleLabel, countLabel].forEach {
         addSubview($0)
      }
   }
   
   override func setLayout() {
      super.setLayout()
      titleLabel.snp.makeConstraints { make in
         make.centerX.equalToSuperview()
         make.top.equalTo(safeAreaLayoutGuide).inset(16)
         make.height.equalTo(20)
      }
      countLabel.snp.makeConstraints { make in
         make.centerX.equalToSuperview()
         make.top.equalTo(titleLabel.snp.bottom).offset(8)
         make.height.equalTo(24)
      }
   }
   
   override func setUI() {
      super.setUI()
      
      backgroundColor = .systemGray6
      layer.cornerRadius = 12
      titleLabel.textAlignment = .center
      countLabel.textAlignment = .center
   }
   
   func bindView(title: String, count: String) {
      titleLabel.text = title
      countLabel.text = count
   }
}
