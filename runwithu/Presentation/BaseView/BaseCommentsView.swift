//
//  BaseCommentsView.swift
//  runwithu
//
//  Created by 강한결 on 8/26/24.
//

import UIKit

import SnapKit

final class BaseCommentsView: BaseTableViewCell {
   private let commentBox = RectangleView(backColor: .clear, radius: 0)
   private let creatorView = BaseCreatorView()
   private let comment = BaseLabel(for: "", font: .systemFont(ofSize: 12))
   private let bottom = BaseLabel()
   
   override func setSubviews() {
      super.setSubviews()
      contentView.addSubview(commentBox)
      commentBox.addSubviews(creatorView, comment, bottom)
   }
   
   override func setLayout() {
      super.setLayout()
      commentBox.snp.makeConstraints { make in
         make.edges.equalTo(contentView.safeAreaLayoutGuide).inset(8)
      }
      creatorView.snp.makeConstraints { make in
         make.top.equalTo(commentBox.safeAreaLayoutGuide).inset(12)
         make.horizontalEdges.equalTo(commentBox.safeAreaLayoutGuide).inset(8)
         make.height.equalTo(32)
      }
      comment.snp.makeConstraints { make in
         make.top.equalTo(creatorView.snp.bottom).offset(12)
         make.leading.equalTo(commentBox.safeAreaLayoutGuide).inset(24)
         make.trailing.equalTo(commentBox.safeAreaLayoutGuide).inset(8)
         make.height.equalTo(44)
      }
      bottom.snp.makeConstraints { make in
         make.top.equalTo(comment.snp.bottom).offset(8)
         make.horizontalEdges.equalTo(commentBox.safeAreaLayoutGuide).inset(8)
         make.bottom.equalTo(commentBox.safeAreaLayoutGuide).inset(8)
      }
   }
   
   override func setUI() {
      super.setUI()
      comment.numberOfLines = 0
   }
   
   func bindView(for output: CommentsOutput) {
      DispatchQueue.main.async { [weak self] in
         guard let self else { return }
         self.creatorView.bindViews(for: output.creator, createdAt: output.createdAt)
         self.creatorView.bindCreatedDate(date: output.createdAt)
         self.comment.text = output.content
      }
   }
}
