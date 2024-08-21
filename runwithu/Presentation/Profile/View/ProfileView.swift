//
//  ProfileView.swift
//  runwithu
//
//  Created by 강한결 on 8/21/24.
//

import UIKit

import PinLayout
import FlexLayout

final class ProfileView: BaseView, BaseViewProtocol {
   private var isUserProfile = false
   private let contentsFlexBox = UIView()
   
   private let profileHeaderRectangle = RectangleView(backColor: .systemIndigo, radius: 32)
   let profileImage = UIImageView()
   let profileNickname = BaseLabel(for: "", font: .boldSystemFont(ofSize: 24), color: .white)
   let profileFollower = BaseLabel(for: "", font: .systemFont(ofSize: 13), color: .white)
   let profileFollowing = BaseLabel(for: "", font: .systemFont(ofSize: 13), color: .white)
   
   let sendRunningInvitationButton = RoundedButtonView("함께 달리기 초대 보내기", backColor: .systemIndigo, baseColor: .white)
   
   private let profileInfoRectangle = RectangleView(backColor: .systemGray4, radius: 24)
   private let postCountView = RoundedMenuView()
   
   
   override func setSubviews() {
      super.setSubviews()
      
      addSubview(contentsFlexBox)
      
      [profileHeaderRectangle, profileInfoRectangle].forEach {
         contentsFlexBox.addSubview($0)
      }
   }
   
   override func layoutSubviews() {
      super.layoutSubviews()
      
      contentsFlexBox.pin
         .horizontally(self.pin.safeArea + 16)
         .vertically(self.pin.safeArea + 8)
      
      contentsFlexBox.flex
         .direction(.column)
         .rowGap(16)
         .define { flex in
            flex.addItem(profileHeaderRectangle)
               .direction(.column)
               .padding(24)
               .alignItems(.start)
               .define { flex in
                  flex.addItem(profileImage)
                     .size(60)
                     .marginBottom(20)
                  flex.addItem(profileNickname)
                     .width(100%)
                     .marginBottom(8)
                  flex.addItem()
                     .direction(.row)
                     .alignItems(.center)
                     .justifyContent(.spaceAround)
                     .columnGap(16)
                     .define { flex in
                        flex.addItem(profileFollower)
                           .height(20)
                        flex.addItem(profileFollowing)
                           .height(20)
                     }
               }
            
            if !isUserProfile {
               flex.addItem(sendRunningInvitationButton)
                  .height(64)
            }
            
            flex.addItem(profileInfoRectangle)
               .direction(.row)
               .padding(16)
               .justifyContent(.spaceEvenly)
               .wrap(.wrap)
               .gap(12)
               .define { flex in
                  flex.addItem(postCountView)
                     .width(30%)
                     .height(80)
               }
            
         }
         .layout(mode: .adjustHeight)
   }
   
   override func setUI() {
      super.setUI()
      
      profileImage.forSymbolImageWithTintColor(for: "person.circle", ofSize: 40, tintColor: .white)
      profileNickname.text = "닉네임입니다."
      
      profileFollower.text = "팔로워 - 0명"
      profileFollowing.text = "팔로잉 - 0명"
      
      postCountView.bindView(title: "커뮤니티", count: "5")
   }
   
   func bindViewState(for state: Bool) {
      isUserProfile = state
   }
}
