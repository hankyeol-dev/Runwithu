//
//  CapsuledLabel.swift
//  runwithu
//
//  Created by 강한결 on 8/29/24.
//

import UIKit

import SnapKit

final class CapsuledLabel: BaseView {
   private let categoryView = RectangleView(backColor: .systemGray5, radius: 12)
   private let categoryLabel = BaseLabel(for: "", font: .systemFont(ofSize: 12), color: .darkGray)
   
   convenience init(backColor: UIColor = .systemGray5, foregoundColor: UIColor = .darkGray) {
      self.init(frame: .zero)
      categoryView.backgroundColor = backColor
      categoryLabel.textColor = foregoundColor
   }
   
   override func setSubviews() {
      super.setSubviews()
      addSubview(categoryView)
      categoryView.addSubview(categoryLabel)
   }
   
   override func setLayout() {
      super.setLayout()
      categoryView.snp.makeConstraints { make in
         make.edges.equalTo(safeAreaLayoutGuide)
      }
      categoryLabel.snp.makeConstraints { make in
         make.center.equalToSuperview()
      }
   }
   
   override func setUI() {
      super.setUI()
      categoryLabel.textAlignment = .center
   }
   
   func bindText(for brand: String?, type: String?) {
      if let brand, let type {
         categoryLabel.text = "\(brand) - \(type)"
      }
   }
}
