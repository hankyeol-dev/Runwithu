//
//  BaseCreatorView.swift
//  runwithu
//
//  Created by 강한결 on 8/25/24.
//

import UIKit

import SnapKit
import Kingfisher

final class BaseCreatorView: BaseView {
   private let creatorView = RectangleView(backColor: .clear, radius: 8)
   private let creatorImage = UIImageView()
   private let creatorInfoStack = UIStackView()
   private let creatorName = BaseLabel(for: "", font: .systemFont(ofSize: 14), color: .darkGray)
   private let createdDate = BaseLabel(for: "", font: .systemFont(ofSize: 14), color: .systemGray2)
   
   override func setSubviews() {
      super.setSubviews()
      addSubviews(creatorView)
      creatorView.addSubviews(creatorImage, creatorInfoStack)
      creatorInfoStack.addArrangedSubview(creatorName)
      creatorInfoStack.addArrangedSubview(createdDate)
   }
   
   override func setLayout() {
      super.setLayout()
      creatorView.snp.makeConstraints { make in
         make.edges.horizontalEdges.equalTo(self.safeAreaLayoutGuide).inset(8)
      }
      creatorImage.snp.makeConstraints { make in
         make.centerY.equalToSuperview()
         make.leading.equalTo(creatorView.safeAreaLayoutGuide)
         make.size.equalTo(44)
      }
      creatorInfoStack.snp.makeConstraints { make in
         make.centerY.equalToSuperview()
         make.leading.equalTo(creatorImage.snp.trailing).offset(8)
         make.trailing.equalTo(creatorView.safeAreaLayoutGuide)
      }
   }
   
   override func setUI() {
      super.setUI()
      
      creatorImage.layer.cornerRadius = 22
      creatorImage.clipsToBounds = true
      creatorImage.contentMode = .scaleToFill
      creatorImage.backgroundColor = .white
      creatorInfoStack.distribution = .fillEqually
      creatorInfoStack.axis = .vertical
      creatorInfoStack.spacing = 4
   }
   
   func bindView(image: UIImage, name: String) {
      creatorImage.image = image
      creatorName.text = name
   }
   
   func bindView(imageURL: String, name: String) {
      creatorImage.image = .checked
      creatorName.text = name
   }
   
   func bindCreatedDate(date: String) {
      createdDate.text = date
   }
   
   func bindViews(for creator: BaseProfileType, createdAt: String) {
      creatorName.text = creator.nick
      
      if let compare = createdAt.calcBetweenDayAndHour() {
         var compareString = ""
         if let day = compare.day, day != 0 {
            compareString += "\(day)일 "
         }
         
         if let hour = compare.hour {
            compareString += "\(hour)시간 "
         }
         compareString += "전"
         
         createdDate.text = compareString
      }
      
      Task {
         if let imageURL = creator.profileImage {
            await getImageFromServer(for: creatorImage, by: imageURL)
         } else {
            creatorImage.image = .userUnselected
         }
      }
   }
}
