//
//  ProductPostCell.swift
//  runwithu
//
//  Created by 강한결 on 8/29/24.
//

import UIKit

import SnapKit

final class ProductPostCell: BaseTableViewCell {
   private let backView = RectangleView(backColor: .white, radius: 8)
   private let user = BaseUserImage(size: 20, borderW: 2, borderColor: .darkGray)
   private let username = BaseLabel(for: "", font: .systemFont(ofSize: 14))
   private let divider = RectangleView(backColor: .darkGray.withAlphaComponent(0.5), radius: 0)
   private let image = UIImageView()
   private let typeLabel = CapsuledLabel()
   private let titleLabel = BaseLabel(for: "", font: .boldSystemFont(ofSize: 18))
   private let contentLabel = BaseLabel(for: "", font: .systemFont(ofSize: 14))
   private let commentCountLabel = BaseLabel(for: "", font: .systemFont(ofSize: 13), color: .systemGray)
   
   override func setSubviews() {
      super.setSubviews()
      contentView.addSubview(backView)
      backView.addSubviews(user, username, image, typeLabel, titleLabel, contentLabel, commentCountLabel, divider)
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
      commentCountLabel.textAlignment = .right
   }
   
   func bindView(by post: PostsOutput) {
      if let profileURL = post.creator.profileImage {
         Task {
            await getImageFromServer(for: user, by: profileURL)
         }
      } else {
         user.image = .userSelected
      }
      username.bindText(post.creator.nick)
      titleLabel.bindText(post.title)
      contentLabel.bindText(post.content)
      typeLabel.bindText(for: post.content2, type: post.content3)
      commentCountLabel.bindText("댓글 - \(post.comments.count)개")
      if let file = post.files.first {
         Task {
            await getImageFromServer(for: image, by: file)
            image.snp.makeConstraints { make in
               make.top.equalTo(backView.safeAreaLayoutGuide).inset(12)
               make.horizontalEdges.equalTo(backView.safeAreaLayoutGuide).inset(16)
               make.height.equalTo(200)
            }
         }
      }
      
      bindBasicLayout()
   }
   
   private func bindBasicLayout() {
      let guide = backView.safeAreaLayoutGuide
      user.snp.makeConstraints { make in
         make.top.equalTo(image.snp.bottom).offset(16)
         make.leading.equalTo(guide).inset(16)
         make.size.equalTo(20)
      }
      username.snp.makeConstraints { make in
         make.centerY.equalTo(user.snp.centerY)
         make.leading.equalTo(user.snp.trailing).offset(8)
         make.trailing.equalTo(guide).inset(16)
      }
      typeLabel.snp.makeConstraints { make in
         make.top.equalTo(user.snp.bottom).offset(16)
         make.leading.equalTo(guide).inset(16)
         make.width.equalTo(100)
         make.height.equalTo(24)
      }
      titleLabel.snp.makeConstraints { make in
         make.top.equalTo(typeLabel.snp.bottom).offset(12)
         make.horizontalEdges.equalTo(guide).inset(16)
         make.height.equalTo(24)
      }
      contentLabel.snp.makeConstraints { make in
         make.top.equalTo(titleLabel.snp.bottom).offset(8)
         make.horizontalEdges.equalTo(guide).inset(16)
         make.height.equalTo(20)
      }
      divider.snp.makeConstraints { make in
         make.top.equalTo(contentLabel.snp.bottom).offset(12)
         make.height.equalTo(0.5)
         make.horizontalEdges.equalTo(guide).inset(16)
      }
      commentCountLabel.snp.makeConstraints { make in
         make.top.equalTo(divider).offset(12)
         make.horizontalEdges.equalTo(guide).inset(16)
         make.bottom.equalTo(guide).inset(16)
      }
   }
}
