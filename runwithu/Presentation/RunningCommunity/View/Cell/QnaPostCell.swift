//
//  QnaPostCell.swift
//  runwithu
//
//  Created by 강한결 on 8/28/24.
//

import UIKit

import SnapKit

final class QnaPostCell: BaseTableViewCell {
   private let back = RectangleView(backColor: .white, radius: 8)
   private let categoryUnderbar = RectangleView(backColor: .darkGray, radius: 1)
   private let categoryLabel = BaseLabel(for: "", font: .boldSystemFont(ofSize: 10), color: .darkGray)
   private let titleLabel = BaseLabel(for: "", font: .boldSystemFont(ofSize: 15))
   private let contentLabel = BaseLabel(for: "", font: .systemFont(ofSize: 13))
   private let commentCountLabel = BaseLabel(for: "", font: .systemFont(ofSize: 13), color: .systemGray)
   private let emptyRect = RectangleView(backColor: .clear, radius: 0)
   
   override func setSubviews() {
      super.setSubviews()
      contentView.addSubview(back)
      back.addSubviews(categoryUnderbar, categoryLabel, titleLabel, contentLabel, commentCountLabel, emptyRect)
   }
   
   override func setLayout() {
      super.setLayout()
      let guide = back.safeAreaLayoutGuide
      back.snp.makeConstraints { make in
         make.top.equalTo(contentView.safeAreaLayoutGuide).inset(2)
         make.horizontalEdges.bottom.equalTo(contentView.safeAreaLayoutGuide)
      }
      categoryLabel.snp.makeConstraints { make in
         make.top.equalTo(guide).inset(16)
         make.leading.equalTo(guide).inset(24)
         make.height.equalTo(16)
      }
      categoryUnderbar.snp.makeConstraints { make in
         make.top.equalTo(categoryLabel.snp.bottom).offset(4)
         make.leading.equalTo(guide).inset(24)
         make.width.equalTo(categoryLabel.snp.width)
         make.height.equalTo(2)
      }
      titleLabel.snp.makeConstraints { make in
         make.top.equalTo(categoryUnderbar.snp.bottom).offset(12)
         make.horizontalEdges.equalTo(guide).inset(24)
         make.height.equalTo(24)
      }
      contentLabel.snp.makeConstraints { make in
         make.top.equalTo(titleLabel.snp.bottom).offset(4)
         make.horizontalEdges.equalTo(guide).inset(24)
         make.height.equalTo(20)
      }
      commentCountLabel.snp.makeConstraints { make in
         make.top.equalTo(contentLabel.snp.bottom).offset(8)
         make.leading.equalTo(guide).inset(24)
         make.trailing.equalTo(guide).inset(32)
         make.height.equalTo(16)
      }
      emptyRect.snp.makeConstraints { make in
         make.top.equalTo(commentCountLabel.snp.bottom).offset(8)
         make.horizontalEdges.equalTo(guide).inset(16)
         make.bottom.equalTo(guide).inset(8)
      }
   }
   
   override func setUI() {
      super.setUI()
      contentView.backgroundColor = .systemGray6.withAlphaComponent(0.6)
      commentCountLabel.textAlignment = .right
   }
   
   func bindView(for cellItem: PostsOutput) {
      DispatchQueue.main.async { [weak self] in
         guard let self else { return }
         self.titleLabel.bindText("Q. " + cellItem.title)
         self.contentLabel.bindText(cellItem.content)
         
         if let category = cellItem.content2 {
            self.categoryLabel.bindText(category)
         }
         self.commentCountLabel.bindText("댓글 - \(cellItem.comments.count)개")
         
         self.setNeedsLayout()
      }
   }
}
