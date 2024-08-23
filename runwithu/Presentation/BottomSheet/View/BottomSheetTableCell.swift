//
//  BottomSheetTableCell.swift
//  runwithu
//
//  Created by 강한결 on 8/19/24.
//

import UIKit

import SnapKit

struct BottomSheetSelectedItem {
   let image: UIImage
   let title: String
   var isSelected: Bool
}

final class BottomSheetTableCell: BaseTableViewCell {
   private let image = UIImageView()
   private let label = BaseLabel(for: "", font: .systemFont(ofSize: 18))
   private let button = UIButton()
   
   override func setSubviews() {
      super.setSubviews()
      
      contentView.addSubview(image)
      contentView.addSubview(label)
   }
   
   override func setLayout() {
      super.setLayout()
      
      image.snp.makeConstraints { make in
         make.centerY.equalToSuperview()
         make.leading.equalTo(contentView.safeAreaLayoutGuide).inset(20)
         make.size.equalTo(24)
      }
      
      label.snp.makeConstraints { make in
         make.centerY.equalToSuperview()
         make.leading.equalTo(image.snp.trailing).offset(12)
         make.width.equalTo(200)
      }
   }
   
   override func setUI() {
      super.setUI()
      selectionStyle = .none
   }
   
   func bindView(for data: BottomSheetSelectedItem) {
      image.image = data.image
      label.text = data.title
   }
   
   func bindButton(isChecked: Bool) {
      contentView.addSubview(button)
      button.snp.makeConstraints { make in
         make.centerY.equalToSuperview()
         make.trailing.equalTo(contentView.safeAreaLayoutGuide).inset(20)
         make.size.equalTo(24)
      }
      
      let buttonImage = isChecked ? UIImage.checked : UIImage.unchecked
      button.setImage(buttonImage, for: .normal)
      button.tintColor = isChecked ? .darkGray : .systemGray5.withAlphaComponent(0.5)
   }
}
