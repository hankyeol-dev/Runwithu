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
   
   private let profileHeaderRectangle = RectangleView(backColor: .white, radius: 16)
   let profileImage = BaseUserImage(size: 44)
   let profileNickname = BaseLabel(for: "", font: .boldSystemFont(ofSize: 18), color: .black)
   let profileFollower = BaseLabel(for: "", font: .systemFont(ofSize: 12, weight: .light), color: .black)
   let profileFollowing = BaseLabel(for: "", font: .systemFont(ofSize: 12, weight: .light), color: .black)
   let followButton = RoundedButtonView("팔로우", backColor: .clear, baseColor: .white, radius: 4)
   
   let sendRunningInvitationButton = RoundedButtonView(
      "✉️  함께 달리기 초대하기", backColor: .black, baseColor: .white, radius: 12)
   
   private let profileInfoRectangle = RectangleView(backColor: .white, radius: 0)
   let runningEpilogueMenu = RoundedMenuView(title: "러닝 일지")
   let runningProductEpilogueMenu = RoundedMenuView(title: "용품 후기")
   let runningQnaMenu = RoundedMenuView(title: "러닝 QnA")
   let selfMarathonMenu = RoundedMenuView(title: "셀프 마라톤", count: 0)
   let runningInvitationMenu = RoundedMenuView(title: "함께 달리기")
   let runningGroupMenu = RoundedMenuView(title: "러닝 그룹")
   
   
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
               .width(100%)
               .padding(16, 24)
               .direction(.row)
               .define { flex in
                  flex.addItem(profileImage)
                     .width(44)
                     .height(44)
                     .marginRight(16)
                  flex.addItem()
                     .direction(.column)
                     .rowGap(4)
                     .define { flex in
                        flex.addItem(profileNickname)
                           .height(20)
                           .grow(1)
                        flex.addItem().direction(.row)
                           .define { flex in
                              flex.addItem(profileFollower)
                                 .height(20)
                                 .grow(1)
                                 .marginRight(8)
                              flex.addItem(profileFollowing)
                                 .height(20)
                                 .grow(1)
                           }
                           .marginBottom(4)
                        if !isUserProfile {
                           flex.addItem(followButton)
                              .height(24)
                              .width(64)
                        }
                     }
                  
               }
            
            if !isUserProfile {
               flex.addItem(sendRunningInvitationButton)
                  .height(64)
            }
            
            flex.addItem(profileInfoRectangle)
               .direction(.row)
               .justifyContent(.spaceBetween)
               .wrap(.wrap)
               .gap(16)
               .define { flex in
                  flex.addItem(runningEpilogueMenu)
                     .width(30%)
                     .height(80)
                  flex.addItem(runningProductEpilogueMenu)
                     .width(30%)
                     .height(80)
                  flex.addItem(runningQnaMenu)
                     .width(30%)
                     .height(80)
                  flex.addItem(runningInvitationMenu)
                     .width(30%)
                     .height(80)
                  flex.addItem(runningGroupMenu)
                     .width(30%)
                     .height(80)
                  flex.addItem(selfMarathonMenu)
                     .width(30%)
                     .height(80)
               }
            
         }
         .layout(mode: .adjustHeight)
   }
   
   override func setUI() {
      super.setUI()
      
      profileHeaderRectangle.layer.borderColor = UIColor.darkGray.cgColor
      profileHeaderRectangle.layer.borderWidth = 1
      followButton.titleLabel?.font = .systemFont(ofSize: 10)
      followButton.layer.borderColor = UIColor.black.cgColor
      followButton.layer.borderWidth = 1
   }
   
   func bindView(for profile: ProfileOutput) {
      profileNickname.bindText(profile.nick)
      profileFollower.bindText("팔로워 - \(profile.followers.count)명")
      profileFollowing.bindText("팔로잉 - \(profile.following.count)명")
      
      if let profileImageURL = profile.profileImage {
         Task {
            await getImageFromServer(for: profileImage, by: profileImageURL)
         }
      } else {
         profileImage.image = .userSelected
         profileImage.backgroundColor = .white
      }
      setNeedsLayout()
   }
   
   func bindView(for isFollowingUser: Bool) {
      if !isUserProfile {
         followButton.setTitle(isFollowingUser ? "팔로우 취소" : "팔로우", for: .normal)
         followButton.setTitleColor(isFollowingUser ? .black : .white, for: .normal)
         followButton.backgroundColor = isFollowingUser ? .white : .black
      }
   }
   
   func bindView(for postsList: [String: [PostsOutput]]) {
      if let key = postsList[PostsCommunityType.epilogues.rawValue] {
         runningEpilogueMenu.bindView(count: key.count)
      }
      
      if let key = postsList[PostsCommunityType.product_epilogues.rawValue] {
         runningProductEpilogueMenu.bindView(count: key.count)
      }
      
      if let key = postsList[PostsCommunityType.qnas.rawValue] {
         runningQnaMenu.bindView(count: key.count)
      }
      
      if let key = postsList[ProductIds.runwithu_running_inviation.rawValue] {
         runningInvitationMenu.bindView(count: key.count)
      }
      
      if let key = postsList[ProductIds.runwithu_running_group.rawValue] {
         runningGroupMenu.bindView(count: key.count)
      }
      
      setNeedsLayout()
   }
   
   func bindViewState(for state: Bool) {
      isUserProfile = state
   }
}
