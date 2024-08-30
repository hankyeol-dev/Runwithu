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
   let creatorImage = BaseUserImage(size: 44, borderW: 2, borderColor: .systemGray6)
   private let creatorInfoStack = UIStackView()
   private let creatorName = BaseLabel(for: "", font: .systemFont(ofSize: 14), color: .darkGray)
   private let createdDate = BaseLabel(for: "", font: .systemFont(ofSize: 14), color: .systemGray2)
   
   override func setSubviews() {
      super.setSubviews()
      addSubviews(creatorImage, creatorInfoStack)
      creatorInfoStack.addArrangedSubview(creatorName)
      creatorInfoStack.addArrangedSubview(createdDate)
   }
   
   override func setLayout() {
      super.setLayout()
      creatorImage.snp.makeConstraints { make in
         make.centerY.equalToSuperview()
         make.leading.equalTo(self.safeAreaLayoutGuide).inset(8)
         make.size.equalTo(44)
      }
      creatorInfoStack.snp.makeConstraints { make in
         make.centerY.equalToSuperview()
         make.leading.equalTo(creatorImage.snp.trailing).offset(12)
         make.trailing.equalTo(self.safeAreaLayoutGuide).inset(8)
      }
   }
   
   override func setUI() {
      super.setUI()
      
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
      DispatchQueue.main.async { [weak self] in
         guard let self else { return }
         creatorName.text = creator.nick
         calcCreatedAt(for: createdAt)
         setNeedsLayout()
      }
     
      Task {
         if let imageURL = creator.profileImage {
            await getImageFromServer(for: creatorImage, by: imageURL)
            setNeedsLayout()
         } else {
            creatorImage.image = .userUnselected
            setNeedsLayout()
         }
      }
   }
   
   private func calcCreatedAt(for createdAt: String) {
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
   }
}
