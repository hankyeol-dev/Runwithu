//
//  RunningGroupDetailView.swift
//  runwithu
//
//  Created by 강한결 on 8/26/24.
//

import UIKit

import SnapKit

final class RunningGroupDetailView: BaseView, BaseViewProtocol {
   private var isJoinedGroup = false
   private let groupInfoHeader = RectangleView(backColor: .systemGray6, radius: 12)
   private let groupIcon = UIImageView(image: .runner)
   private let groupTitle = BaseLabel(for: "", font: .boldSystemFont(ofSize: 20))
   private let groupSpot = BaseLabel(for: "", font: .systemFont(ofSize: 16))
   private let groupUserCount = BaseLabel(for: "", font: .systemFont(ofSize: 15))
   let groupDetailButton = UIButton()
   
   private let groupJoinButton = RoundedButtonView(
      "그룹에 참여하기", backColor: .systemGreen, baseColor: .white, radius: 12)
   
   override func setSubviews() {
      super.setSubviews()
      addSubviews(groupInfoHeader)
      groupInfoHeader.addSubviews(groupIcon, groupTitle, groupSpot, groupUserCount, groupDetailButton)
   }
   
   override func setLayout() {
      super.setLayout()
      groupInfoHeader.snp.makeConstraints { make in
         make.top.equalTo(self.safeAreaLayoutGuide).inset(8)
         make.horizontalEdges.equalTo(self.safeAreaLayoutGuide).inset(12)
      }
      
      let guide = groupInfoHeader.safeAreaLayoutGuide
      
      groupIcon.snp.makeConstraints { make in
         make.top.leading.equalTo(guide).inset(12)
         make.size.equalTo(64)
      }
      groupTitle.snp.makeConstraints { make in
         make.top.equalTo(groupIcon.snp.bottom).offset(16)
         make.horizontalEdges.equalTo(guide).inset(12)
      }
      groupSpot.snp.makeConstraints { make in
         make.top.equalTo(groupTitle.snp.bottom).offset(12)
         make.horizontalEdges.equalTo(guide).inset(12)
      }
      groupUserCount.snp.makeConstraints { make in
         make.top.equalTo(groupSpot.snp.bottom).offset(8)
         make.horizontalEdges.equalTo(guide).inset(12)
      }
      groupDetailButton.snp.makeConstraints { make in
         make.top.equalTo(groupUserCount.snp.bottom).offset(12)
         make.trailing.equalTo(guide).inset(12)
         make.bottom.equalTo(guide).inset(12)
      }
   }
   
   override func setUI() {
      super.setUI()
      
      groupDetailButton.setTitle("그룹 상세 소개 >", for: .normal)
      groupDetailButton.setTitleColor(.darkGray, for: .normal)
      groupDetailButton.titleLabel?.font = .systemFont(ofSize: 14)
   }
   
   func bindInfoHeader(by data: PostsOutput) {
      if let content1 = data.content1, 
            let content2 = data.content2 {
         groupTitle.text = data.title
         groupSpot.text = "러닝 지역: " + content2
         groupUserCount.text = "함께하는 러너: " + String(data.likes.count) + "명 (제한: \(content1)명)"
      }
   }
   
   func updateGroupJoined(by isJoined: Bool) {
      isJoinedGroup = isJoined
      
      if !isJoinedGroup {
         DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            self.addSubviews(self.groupJoinButton)
            groupJoinButton.snp.makeConstraints { make in
               make.horizontalEdges.equalTo(self.safeAreaLayoutGuide).inset(16)
               make.bottom.equalTo(self.safeAreaLayoutGuide).inset(64)
               make.height.equalTo(46)
            }
            setNeedsLayout()
         }
      }
   }
}
