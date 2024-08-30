//
//  GroupListTableCell.swift
//  runwithu
//
//  Created by 강한결 on 8/30/24.
//

import UIKit

import SnapKit

final class GroupListTableCell: BaseTableViewCell {
   private let backView = RectangleView(backColor: .systemGray6, radius: 8)
   private let image = UIImageView()
   private let stack = UIStackView()
   private let groupName = BaseLabel(for: "", font: .boldSystemFont(ofSize: 16))
   private let groupDescript = BaseLabel(for: "", font: .systemFont(ofSize: 13))
   private let groupEtc = BaseLabel(for: "", font: .systemFont(ofSize: 13))
   private let groupHardType = CapsuledLabel(backColor: .systemPurple, foregoundColor: .systemGray6)
   
   override func setSubviews() {
      super.setSubviews()
      contentView.addSubview(backView)
      backView.addSubviews(image, stack, groupDescript, groupHardType)
      stack.addArrangedSubview(groupName)
      stack.addArrangedSubview(groupEtc)
   }
   
   override func setLayout() {
      super.setLayout()
      
      backView.snp.makeConstraints { make in
         make.verticalEdges.equalTo(contentView.safeAreaLayoutGuide).inset(8)
         make.horizontalEdges.equalTo(contentView.safeAreaLayoutGuide)
      }
      
      let guide = backView.safeAreaLayoutGuide
      image.snp.makeConstraints { make in
         make.top.equalTo(guide).inset(12)
         make.leading.equalTo(guide).inset(12)
         make.size.equalTo(44)
      }
      stack.snp.makeConstraints { make in
         make.leading.equalTo(image.snp.trailing).offset(12)
         make.centerY.equalTo(image.snp.centerY)
         make.trailing.equalTo(guide).inset(12)
      }
      groupDescript.snp.makeConstraints { make in
         make.top.equalTo(image.snp.bottom).offset(8)
         make.horizontalEdges.equalTo(guide).inset(12)
         make.height.equalTo(56)
      }
      groupHardType.snp.makeConstraints { make in
         make.top.equalTo(groupDescript.snp.bottom).offset(8)
         make.leading.equalTo(guide).inset(12)
         make.height.equalTo(24)
         make.width.equalTo(150)
         make.bottom.equalTo(guide).inset(12)
      }
   }
   
   override func setUI() {
      super.setUI()
      image.image = .runner
      groupDescript.numberOfLines = 3
      groupDescript.lineBreakMode = .byCharWrapping
      stack.axis = .vertical
      stack.spacing = 4
      stack.distribution = .fillProportionally
   }
   
   func bindView(for data: PostsOutput) {
      groupName.bindText(data.title)
      groupDescript.bindText(data.content)
      
      if let entryLimit = data.content1, let spot = data.content2 {
         groupEtc.bindText("\(data.likes.count) / \(entryLimit)명  ·  \(spot)")
      }
      if let hardType = data.content3 {
         groupHardType.bindText(for: hardType)
      }
   }
}
