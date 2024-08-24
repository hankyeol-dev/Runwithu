//
//  BaseWithImageCollectionViewCell.swift
//  runwithu
//
//  Created by 강한결 on 8/24/24.
//

import UIKit

import SnapKit

final class BaseWithImageCollectionViewCell: UICollectionViewCell {
   private let imageViewWrapper = UIView()
   private let imageView = UIImageView()
   let imageDeleteButton = UIButton()
   
   override init(frame: CGRect) {
      super.init(frame: .zero)
      
      setSubviews()
      setLayout()
      setUI()
   }
   
   required init?(coder: NSCoder) {
      fatalError("init(coder:) has not been implemented")
   }
   
   private func setSubviews() {
      contentView.addSubviews(imageViewWrapper, imageDeleteButton)
      imageViewWrapper.addSubview(imageView)
   }
   
   private func setLayout() {
      imageViewWrapper.snp.makeConstraints { make in
         make.edges.equalTo(contentView.safeAreaLayoutGuide).inset(8)
      }
      imageView.snp.makeConstraints { make in
         make.edges.equalTo(imageViewWrapper.safeAreaLayoutGuide)
      }
      imageDeleteButton.snp.makeConstraints { make in
         make.top.trailing.equalTo(contentView.safeAreaLayoutGuide).inset(2)
         make.size.equalTo(20)
      }
   }
   
   private func setUI() {
      imageView.layer.cornerRadius = 12.0
      imageView.clipsToBounds = true
      imageView.contentMode = .scaleToFill
      imageViewWrapper.layer.shadowColor = UIColor.darkGray.cgColor
      imageViewWrapper.layer.shadowOpacity = 0.3
      imageViewWrapper.layer.shadowOffset = CGSize(width: 0, height: 1)
      imageViewWrapper.layer.shadowRadius = 1.0
      imageDeleteButton.setImage(.deleteButtonRed, for: .normal)
      imageDeleteButton.backgroundColor = .none
   }
   
   func bindImageView(for image: UIImage) {
      imageView.image = image
   }
}
