//
//  RoundedAddUserView.swift
//  runwithu
//
//  Created by 강한결 on 8/21/24.
//

import UIKit

import PinLayout
import FlexLayout

final class RoundedAddUserView: BaseView {
   private let flexBox = UIView()
   private let title = BaseLabel(for: "", font: .systemFont(ofSize: 18))
   let inviteButton = UIButton()
   let inviteCollection = {
      let flow = UICollectionViewFlowLayout()
      flow.scrollDirection = .horizontal
      flow.minimumInteritemSpacing = 8.0
      flow.itemSize = .init(width: 100.0, height: 36)
      flow.sectionInset = .init(top: 6, left: 0, bottom: 6, right: 0)
      let collection = UICollectionView(frame: .zero, collectionViewLayout: flow)
      collection.register(RunningInvitedUserCell.self, forCellWithReuseIdentifier: RunningInvitedUserCell.id)
      return collection
   }()
   
   convenience init(title: String) {
      self.init(frame: .zero)
      self.title.text = title
   }
   
   override func setSubviews() {
      super.setSubviews()
      
      addSubview(flexBox)
      [title, inviteButton, inviteCollection].forEach {
         flexBox.addSubview($0)
      }
   }
   
   override func setLayout() {
      super.setLayout()
      
      flexBox.pin.width(100%)
      flexBox.flex
         .direction(.column)
         .define { flex in
            flex
               .addItem()
               .direction(.row)
               .alignItems(.center)
               .justifyContent(.spaceBetween)
               .width(100%)
               .define { flex in
                  flex.addItem(title)
                     .width(50%)
                  flex.addItem(inviteButton)
                     .width(100)
               }
               .marginBottom(8)
            
            flex.addItem(inviteCollection)
               .width(100%)
               .alignSelf(.end)
               .height(60)
         }
         .layout(mode: .adjustHeight)
   }
   
   override func setUI() {
      super.setUI()
      inviteCollection.backgroundColor = .none
      inviteButton.configuration = .bordered()
      inviteButton.configuration?.subtitle = "+ 팔로잉 러너"
      inviteButton.configuration?.baseForegroundColor = .darkGray
      inviteButton.configuration?.baseBackgroundColor = .systemGray5
   }
}
