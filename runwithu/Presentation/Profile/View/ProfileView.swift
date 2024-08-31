//
//  ProfileView.swift
//  runwithu
//
//  Created by 강한결 on 8/21/24.
//

import UIKit

import PinLayout
import FlexLayout
import SnapKit

final class ProfileView: BaseView, BaseViewProtocol {
   private var isUserProfile = false
   private let contentsFlexBox = UIView()
   
   private let profileHeaderRectangle = RectangleView(backColor: .black, radius: 16)
   let profileImage = BaseUserImage(size: 44)
   let profileNickname = BaseLabel(for: "", font: .boldSystemFont(ofSize: 18), color: .white)
   let profileFollower = BaseLabel(for: "", font: .systemFont(ofSize: 14, weight: .light), color: .white)
   let profileFollowing = BaseLabel(for: "", font: .systemFont(ofSize: 14, weight: .light), color: .white)
   let followButton = RoundedButtonView("팔로우", backColor: .clear, baseColor: .white, radius: 4)
   let logoutButton = UIButton()
   
   let sendRunningInvitationButton = RoundedButtonView(
      "✉️  함께 달리기 초대하기", backColor: .black, baseColor: .white, radius: 12)
   
   private let invitaionSection = RectangleView(backColor: .white, radius: 0)
   private let consentTitle = BaseLabel(for: "내가 참가하는 러닝", font: .systemFont(ofSize: 15, weight: .semibold))
   private let notConsentTitle = BaseLabel(for: "아직 수락하지 않은 초대장", font: .systemFont(ofSize: 15, weight: .semibold))
   lazy var consentCollection = UICollectionView(frame: .zero, collectionViewLayout: createCollectionLayout())
   lazy var notConsentCollection = UICollectionView(frame: .zero, collectionViewLayout: createCollectionLayout())
   
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
      contentsFlexBox.addSubviews(profileHeaderRectangle, profileInfoRectangle)
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
                     .alignItems(.start)
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
                        if isUserProfile {
                           flex.addItem(logoutButton)
                              .height(20)
                        }
                     }
                  
               }
            
            if !isUserProfile {
               flex.addItem(sendRunningInvitationButton)
                  .height(64)
            }
            
            if isUserProfile {
               flex.addItem(invitaionSection)
                  .direction(.column)
                  .width(100%)
                  .padding(8, 8)
                  .define { flex in
                     flex.addItem(consentTitle)
                        .width(100%)
                        .height(24)
                        .marginBottom(4)
                     flex.addItem(consentCollection)
                        .width(100%)
                        .height(80)
                        .marginBottom(16)
                     flex.addItem(notConsentTitle)
                        .width(100%)
                        .height(24)
                        .marginBottom(4)
                     flex.addItem(notConsentCollection)
                        .width(100%)
                        .height(80)
                        .marginBottom(16)
                  }
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
      logoutButton.setTitleColor(.systemRed, for: .normal)
      logoutButton.setTitle("로그아웃", for: .normal)
      logoutButton.titleLabel?.font = .systemFont(ofSize: 14)
      
      consentCollection.register(ProfileInvitationCollectionCell.self, forCellWithReuseIdentifier: ProfileInvitationCollectionCell.id)
      notConsentCollection.register(ProfileInvitationCollectionCell.self, forCellWithReuseIdentifier: ProfileInvitationCollectionCell.id)
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

extension ProfileView {
   private func createCollectionLayout() -> UICollectionViewCompositionalLayout {
      let itemSize = NSCollectionLayoutSize(
         widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0))
      let item = NSCollectionLayoutItem(layoutSize: itemSize)
      
      let groupSize = NSCollectionLayoutSize(
         widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0))
      let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
      
      let section = NSCollectionLayoutSection(group: group)
      section.orthogonalScrollingBehavior = .groupPagingCentered
      
      return UICollectionViewCompositionalLayout(section: section)
   }
}

final class ProfileInvitationCollectionCell: BaseCollectionViewCell {
   private let backView = RectangleView(backColor: .systemGray6, radius: 8)
   private let titleLabel = BaseLabel(for: "", font: .systemFont(ofSize: 15, weight: .medium))
   private let dateLabel = BaseLabel(for: "", font: .systemFont(ofSize: 13, weight: .light))
   private let countLabel = BaseLabel(for: "", font: .systemFont(ofSize: 10))
   private let emptyLabel = BaseLabel(for: "", font: .systemFont(ofSize: 15, weight: .medium))
   
   override func setSubviews() {
      super.setSubviews()
      contentView.addSubview(backView)
   }
   
   override func setLayout() {
      super.setLayout()
      backView.snp.makeConstraints { make in
         make.verticalEdges.equalTo(contentView.safeAreaLayoutGuide)
         make.leading.equalTo(contentView.safeAreaLayoutGuide)
         make.trailing.equalTo(contentView.safeAreaLayoutGuide).inset(8)
      }
   }
   
   func bindView(for invitation: PostsOutput, index: Int, totalIndex: Int) {
      backView.addSubviews(titleLabel, dateLabel, countLabel)
      let guide = backView.safeAreaLayoutGuide
      titleLabel.snp.makeConstraints { make in
         make.top.equalTo(guide).inset(12)
         make.horizontalEdges.equalTo(guide).inset(12)
         make.height.equalTo(20)
      }
      dateLabel.snp.makeConstraints { make in
         make.top.equalTo(titleLabel.snp.bottom).offset(6)
         make.horizontalEdges.equalTo(guide).inset(12)
         make.height.equalTo(20)
      }
      countLabel.snp.makeConstraints { make in
         make.bottom.equalTo(guide).inset(8)
         make.trailing.equalTo(guide).inset(8)
         make.height.equalTo(20)
      }
      
      titleLabel.bindText("✉️ " + invitation.title)
      if let content2 = invitation.content2, let data = content2.data(using: .utf8) {
         do {
            let runningInfo = try JSONDecoder().decode(RunningInfo.self, from: data)
            dateLabel.bindText("🏃‍♀️ " + runningInfo.date)
         } catch {
            dateLabel.bindText("")
         }
      }
      countLabel.bindText("\(index + 1) / \(totalIndex)")
      countLabel.textAlignment = .right
   }
   
   func bindEmptyView() {
      backView.addSubview(emptyLabel)
      emptyLabel.snp.makeConstraints { make in
         make.center.equalTo(backView.snp.center)
         make.height.equalTo(20)
      }
      emptyLabel.bindText("현재 받은 초대장이 없어요 :D")
   }
}
