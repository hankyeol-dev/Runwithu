//
//  EpiloguePostCell.swift
//  runwithu
//
//  Created by 강한결 on 8/29/24.
//

import UIKit

import SnapKit

final class EpiloguePostCell: BaseTableViewCell {
   
   private let backView = RectangleView(backColor: .white, radius: 8)
   private let image = UIImageView()
   private let titleLabel = BaseLabel(for: "", font: .systemFont(ofSize: 18))
   private let contentLabel = BaseLabel(for: "", font: .systemFont(ofSize: 16))
   private let divider = RectangleView(backColor: .darkGray.withAlphaComponent(0.5), radius: 0)
   private let user = BaseUserImage(size: 20, borderW: 2, borderColor: .darkGray)
   private let username = BaseLabel(for: "", font: .systemFont(ofSize: 14))
   
   override func setSubviews() {
      contentView.addSubview(backView)
      backView.addSubviews(image, titleLabel, contentLabel, divider, user, username)
   }
   
   override func setLayout() {
      super.setLayout()
      backView.snp.makeConstraints { make in
         make.edges.equalTo(contentView.safeAreaLayoutGuide).inset(8)
      }
   }
   
   override func setUI() {
      super.setUI()
      contentView.backgroundColor = .systemGray6.withAlphaComponent(0.6)
      image.contentMode = .scaleToFill
      selectionStyle = .none
   }
   
   func bindView(for post: PostsOutput) {
      let files = post.files
      let guide = backView.safeAreaLayoutGuide
      
      titleLabel.bindText(post.title)
      contentLabel.bindText(post.content)
      
      if let userImageURL = post.creator.profileImage {
         Task {
            await getImageFromServer(for: user, by: userImageURL)
         }
      } else {
         user.image = .userSelected
      }
      username.bindText(post.creator.nick)
      
      if let file = files.first {
         bindImageLayout(by: file)
         image.snp.makeConstraints { make in
            make.top.equalTo(guide).inset(8)
            make.horizontalEdges.equalTo(guide).inset(16)
            make.height.equalTo(200)
         }
      }
      bindBasicLayout()
   }
   
   private func bindBasicLayout() {
      let guide = backView.safeAreaLayoutGuide
      titleLabel.snp.makeConstraints { make in
         make.top.equalTo(image.snp.bottom).offset(16)
         make.horizontalEdges.equalTo(guide).inset(16)
         make.height.equalTo(22)
      }
      contentLabel.snp.makeConstraints { make in
         make.top.equalTo(titleLabel.snp.bottom).offset(8)
         make.horizontalEdges.equalTo(guide).inset(16)
         make.height.equalTo(20)
      }
      divider.snp.makeConstraints { make in
         make.top.equalTo(contentLabel.snp.bottom).offset(12)
         make.height.equalTo(0.5)
         make.horizontalEdges.equalTo(guide).inset(8)
      }
      user.snp.makeConstraints { make in
         make.top.equalTo(divider.snp.bottom).offset(12)
         make.leading.equalTo(guide).inset(16)
         make.size.equalTo(20)
      }
      username.snp.makeConstraints { make in
         make.centerY.equalTo(user.snp.centerY)
         make.leading.equalTo(user.snp.trailing).offset(8)
         make.trailing.equalTo(guide).inset(16)
         make.bottom.equalTo(guide).inset(12)
      }
   }
   
   private func bindImageLayout(by file: String) {
      Task {
         await getImageFromServer(for: image, by: file)
      }
   }
   
}
