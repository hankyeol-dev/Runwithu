//
//  GroupListCollectionCell.swift
//  runwithu
//
//  Created by 강한결 on 8/30/24.
//

import UIKit

import SnapKit

final class GroupListCollectionCell: BaseCollectionViewCell {
   private let backView = RectangleView(backColor: .systemGray6, radius: 8)
   private let contentStackView = UIStackView()
   private let titleLabel = BaseLabel(for: "", font: .boldSystemFont(ofSize: 18))
   private let contentLabel = BaseLabel(for: "", font: .systemFont(ofSize: 15))
   private let image = UIImageView()
   
   override func setSubviews() {
      super.setSubviews()
      contentView.addSubview(backView)
      backView.addSubviews(contentStackView, image)
      contentStackView.addArrangedSubview(titleLabel)
      contentStackView.addArrangedSubview(contentLabel)
   }
   
   override func setLayout() {
      super.setLayout()
      backView.snp.makeConstraints { make in
         make.leading.equalTo(contentView.safeAreaLayoutGuide)
         make.trailing.equalTo(contentView.safeAreaLayoutGuide).inset(8)
         make.verticalEdges.equalTo(contentView.safeAreaLayoutGuide).inset(8)
      }
      image.snp.makeConstraints { make in
         make.centerY.equalToSuperview()
         make.size.equalTo(80)
         make.trailing.equalTo(backView.safeAreaLayoutGuide).inset(16)
      }
      contentStackView.snp.makeConstraints { make in
         make.centerY.equalTo(image.snp.centerY)
         make.leading.equalTo(backView.safeAreaLayoutGuide).inset(16)
         make.trailing.equalTo(image.snp.leading).offset(-12)
      }
   }
   
   override func setUI() {
      super.setUI()
      image.image = .runner
      contentStackView.axis = .vertical
      contentStackView.distribution = .fillProportionally
      contentStackView.spacing = 4
      contentLabel.numberOfLines = 2
   }
   
   func bindView(for data: PostsOutput) {
      titleLabel.bindText(data.title)
      contentLabel.bindText(data.content)
   }
}
