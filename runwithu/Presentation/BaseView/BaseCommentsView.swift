//
//  BaseCommentsView.swift
//  runwithu
//
//  Created by 강한결 on 8/26/24.
//

import UIKit

import SnapKit

final class BaseCommentsView: BaseTableViewCell {
   private let creatorView = BaseCreatorView()
   private let commentView = BaseLabel(for: "", font: .systemFont(ofSize: 13))
   
   override func setSubviews() {
      super.setSubviews()
      contentView.addSubviews(creatorView, commentView)
   }
   
   override func setLayout() {
      super.setLayout()
      creatorView.snp.makeConstraints { make in
         make.top.horizontalEdges.equalTo(self.contentView.safeAreaLayoutGuide).inset(8)
         make.height.equalTo(64)
         make.bottom.equalTo(self.commentView.snp.top).offset(-4)
      }
      commentView.snp.makeConstraints { make in
         make.leading.equalTo(self.contentView.safeAreaLayoutGuide).inset(24)
         make.trailing.greaterThanOrEqualTo(self.contentView.safeAreaLayoutGuide).inset(12)
         
      }
   }
   
   override func setUI() {
      super.setUI()
      commentView.numberOfLines = 0
   }
   
   func bindView(for output: CommentsOutput) {
      DispatchQueue.main.async { [weak self] in
         guard let self else { return }
         self.creatorView.bindViews(for: output.creator, createdAt: output.createdAt)
         self.creatorView.bindCreatedDate(date: output.createdAt)
         self.commentView.text = output.content
         
      }
   }
}
