//
//  RunningGroupEntryCell.swift
//  runwithu
//
//  Created by 강한결 on 8/26/24.
//

import UIKit

import SnapKit

final class RunningGroupEntryCell: BaseTableViewCell {
   private let image = UIImageView()
   private let label = BaseLabel(for: "", font: .systemFont(ofSize: 18))
   
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
   
   func bindView(for data: BaseProfileType) {
      label.text = data.nick
      if let images = data.profileImage {
         Task {
            await getImageFromServer(for: image, by: images)
         }
      } else {
         image.image = .userSelected
      }
   }
}
