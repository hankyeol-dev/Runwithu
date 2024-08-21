//
//  RunningInvitedUserCell.swift
//  runwithu
//
//  Created by 강한결 on 8/21/24.
//

import UIKit

import SnapKit

final class RunningInvitedUserCell: BaseCollectionViewCell {
   private let username = BaseLabel(for: "", font: .systemFont(ofSize: 13))
   
   override func setSubviews() {
      super.setSubviews()
      contentView.addSubview(username)
   }
   
   override func setLayout() {
      super.setLayout()
      username.snp.makeConstraints { make in
         make.edges.equalTo(contentView.safeAreaLayoutGuide).inset(8)
      }
   }
   
   override func setUI() {
      super.setUI()
      contentView.layer.cornerRadius = 16
      contentView.layer.borderWidth = 1
      contentView.layer.borderColor = UIColor.darkGray.cgColor
      contentView.backgroundColor = .systemGray5
      contentView.clipsToBounds = true
      username.textColor = .darkGray
      username.textAlignment = .center
   }
   
   func bindView(with text: String) {
      username.text = text
   }
}
