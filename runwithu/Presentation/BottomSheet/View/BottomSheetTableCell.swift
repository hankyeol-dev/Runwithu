//
//  BottomSheetTableCell.swift
//  runwithu
//
//  Created by 강한결 on 8/19/24.
//

import UIKit

import SnapKit

final class BottomSheetTableCell: BaseTableViewCell {
   
   private let emojiLabel = BaseLabel(for: "", font: .systemFont(ofSize: 16))
   private let titleLabel = BaseLabel(for: "", font: .systemFont(ofSize: 16))
   
   override func setSubviews() {
      super.setSubviews()
      
      contentView.addSubview(emojiLabel)
      contentView.addSubview(titleLabel)
   }
   
   override func setLayout() {
      super.setLayout()
      
      emojiLabel.snp.makeConstraints { make in
         make.centerY.equalToSuperview()
         make.leading.equalTo(contentView.safeAreaLayoutGuide).inset(20)
         make.size.equalTo(48)
      }
      titleLabel.snp.makeConstraints { make in
         make.centerY.equalToSuperview()
         make.leading.equalTo(emojiLabel.snp.trailing)
         make.trailing.equalTo(contentView.safeAreaLayoutGuide).inset(16)
      }
   }
   
   func bindView(emoji: String, title: String) {
      emojiLabel.text = emoji
      titleLabel.text = title
   }
}
