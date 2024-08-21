//
//  BottomSheetTableCell.swift
//  runwithu
//
//  Created by 강한결 on 8/19/24.
//

import UIKit

import SnapKit

final class BottomSheetTableCell: BaseTableViewCell {
   
   private let label = BaseLabel(for: "", font: .systemFont(ofSize: 16))
   
   override func setSubviews() {
      super.setSubviews()
      
      contentView.addSubview(label)
   }
   
   override func setLayout() {
      super.setLayout()
      
      label.snp.makeConstraints { make in
         make.centerY.equalToSuperview()
         make.leading.equalTo(contentView.safeAreaLayoutGuide).inset(20)
         make.trailing.equalTo(contentView.safeAreaLayoutGuide).inset(20)
      }
   }
   
   func bindView(title: String) {
      label.text = title
   }
}
