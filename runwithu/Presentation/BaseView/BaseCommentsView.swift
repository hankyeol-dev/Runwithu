//
//  BaseCommentsView.swift
//  runwithu
//
//  Created by 강한결 on 8/26/24.
//

import UIKit

import SnapKit

final class BaseCommentsView: BaseTableViewCell {
   private lazy var backView = UIView()
   private let creatorView = BaseCreatorView()
   private lazy var commentView = BaseLabel(for: "", font: .systemFont(ofSize: 13))
   
   override func setSubviews() {
      super.setSubviews()
      contentView.addSubview(backView)
      backView.addSubviews(creatorView, commentView)
   }
   
   override func setLayout() {
      super.setLayout()
      backView.snp.makeConstraints { make in
         make.edges.equalTo(contentView.safeAreaLayoutGuide).inset(4)
      }
      creatorView.snp.makeConstraints { make in
         make.top.horizontalEdges.equalTo(backView.safeAreaLayoutGuide).inset(8)
         make.height.equalTo(64)
      }
      commentView.snp.makeConstraints { make in
         make.top.equalTo(creatorView.snp.bottom).offset(4)
         make.leading.equalTo(backView.safeAreaLayoutGuide).inset(72)
         make.trailing.bottom.equalTo(backView.safeAreaLayoutGuide).inset(8)
      }
   }
   
   override func setUI() {
      super.setUI()
      commentView.numberOfLines = 0
   }
   
   func bindView(for output: CommentsOutput) {
      creatorView.bindViews(for: output.creator, createdAt: output.createdAt)
      creatorView.bindCreatedDate(date: output.createdAt)
      commentView.text = output.content
      setNeedsLayout()
   }
}
