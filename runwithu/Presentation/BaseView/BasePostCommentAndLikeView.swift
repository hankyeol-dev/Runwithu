//
//  BasePostCommentAndLikeView.swift
//  runwithu
//
//  Created by 강한결 on 9/2/24.
//

import UIKit

import SnapKit

final class BasePostCommentAndLikeView: BaseView {
   private let likeImage = UIImageView(image: .heart)
   private let commentImage = UIImageView(image: .comment)
   private let likeCount = BaseLabel(for: "", font: .systemFont(ofSize: 12), color: .systemGray)
   private let commentCount = BaseLabel(for: "", font: .systemFont(ofSize: 12), color: .systemGray)
   
   override func setSubviews() {
      super.setSubviews()
      addSubviews(likeImage, likeCount, commentImage, commentCount)
   }
   
   override func setLayout() {
      super.setLayout()
      likeImage.snp.makeConstraints { make in
         make.centerY.equalToSuperview()
         make.leading.equalTo(safeAreaLayoutGuide)
         make.size.equalTo(16)
      }
      likeCount.snp.makeConstraints { make in
         make.centerY.equalToSuperview()
         make.leading.equalTo(likeImage.snp.trailing).offset(8)
         make.width.equalTo(32)
      }
      commentImage.snp.makeConstraints { make in
         make.centerY.equalToSuperview()
         make.leading.equalTo(likeCount.snp.trailing).offset(8)
         make.size.equalTo(16)
      }
      commentCount.snp.makeConstraints { make in
         make.centerY.equalToSuperview()
         make.leading.equalTo(commentImage.snp.trailing).offset(8)
         make.width.equalTo(32)
      }
   }
   
   override func setUI() {
      super.setUI()
      [likeImage, commentImage].forEach {
         $0.contentMode = .center
      }
   }
   
   func bindView(like: Int, comment: Int) {
      likeCount.bindText(String(like))
      commentCount.bindText(String(comment))
   }
}
