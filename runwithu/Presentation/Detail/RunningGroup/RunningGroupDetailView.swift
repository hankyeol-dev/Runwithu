//
//  RunningGroupDetailView.swift
//  runwithu
//
//  Created by 강한결 on 8/26/24.
//

import UIKit

import SnapKit

final class RunningGroupDetailView: BaseView, BaseViewProtocol {
   private let scrollView = BaseScrollView()
   private let groupInfoHeader = RectangleView(backColor: .white, radius: 0)
   private let groupIcon = UIImageView(image: .runner)
   private let groupTitle = BaseLabel(for: "", font: .boldSystemFont(ofSize: 20))
   private let groupSpot = BaseLabel(for: "", font: .systemFont(ofSize: 16))
   private let groupUserCount = BaseLabel(for: "", font: .systemFont(ofSize: 15))
   let groupDetailButton = UIButton()
   
   let groupEpilogue = RunningGroupPostStack("러닝 후기")
   let groupProductEpilogue = RunningGroupPostStack("러닝 기어 후기")
   let groupQna = RunningGroupPostStack("러닝 Qna")
   let groupJoinButton = RoundedButtonView(
      "그룹에 참여하기", backColor: .systemGreen, baseColor: .white, radius: 12)
   private let emptyBox = RectangleView(backColor: .clear, radius: 0)
   
   let groupPostWriteButton = PlusButton(backColor: .systemGreen, baseColor: .white)
   
   override func setSubviews() {
      super.setSubviews()
      addSubview(scrollView)
      scrollView.contentsView.addSubviews(groupInfoHeader, groupEpilogue, groupProductEpilogue, groupQna)
      groupInfoHeader.addSubviews(groupIcon, groupTitle, groupSpot, groupUserCount, groupDetailButton)
   }
   
   override func setLayout() {
      super.setLayout()
      scrollView.snp.makeConstraints { make in
         make.top.horizontalEdges.equalTo(safeAreaLayoutGuide)
         make.bottom.equalTo(safeAreaLayoutGuide).inset(72)
      }
      
      let scrollGuide = scrollView.contentsView.safeAreaLayoutGuide
      
      groupInfoHeader.snp.makeConstraints { make in
         make.top.equalTo(scrollGuide)
         make.horizontalEdges.equalTo(scrollGuide)
      }
      
      let guide = groupInfoHeader.safeAreaLayoutGuide
      
      groupIcon.snp.makeConstraints { make in
         make.top.leading.equalTo(guide).inset(12)
         make.size.equalTo(32)
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
      
      groupEpilogue.snp.makeConstraints { make in
         make.top.equalTo(groupInfoHeader.snp.bottom).offset(6)
         make.horizontalEdges.equalTo(scrollGuide)
         make.height.equalTo(300)
      }
      groupProductEpilogue.snp.makeConstraints { make in
         make.top.equalTo(groupEpilogue.snp.bottom).offset(6)
         make.horizontalEdges.equalTo(scrollGuide)
         make.height.equalTo(300)
      }
      groupQna.snp.makeConstraints { make in
         make.top.equalTo(groupProductEpilogue.snp.bottom).offset(6)
         make.horizontalEdges.equalTo(scrollGuide)
         make.height.equalTo(300)
      }
   }
   
   override func setUI() {
      super.setUI()
      scrollView.contentsView.backgroundColor = .systemGray5
      groupDetailButton.setTitle("그룹 상세 소개 >", for: .normal)
      groupDetailButton.setTitleColor(.darkGray, for: .normal)
      groupDetailButton.titleLabel?.font = .systemFont(ofSize: 14)
   }
   
   func bindInfoHeader(by data: PostsOutput) {
      groupTitle.bindText(data.title)
      if let content1 = data.content1,
            let content2 = data.content2 {
         groupSpot.bindText("러닝 지역: " + content2)
         groupUserCount.bindText("함께하는 러너: " + String(data.likes.count) + "명 (제한: \(content1)명)")
      }
   }
   
   func updateGroupJoined(by isJoined: Bool) {
      let scrollGuide = scrollView.contentsView.safeAreaLayoutGuide
      if !isJoined {
         scrollView.contentsView.addSubview(groupJoinButton)
         groupJoinButton.snp.makeConstraints { make in
            make.top.equalTo(groupQna.snp.bottom).offset(12)
            make.horizontalEdges.equalTo(scrollGuide).inset(16)
            make.bottom.equalTo(scrollGuide).inset(24)
            make.height.equalTo(46)
         }
         setNeedsLayout()
      }
      
      if isJoined {
         addSubview(groupPostWriteButton)
         scrollView.contentsView.addSubview(emptyBox)
         groupPostWriteButton.snp.makeConstraints { make in
            make.bottom.equalTo(safeAreaLayoutGuide).inset(92)
            make.trailing.equalTo(safeAreaLayoutGuide).inset(24)
            make.size.equalTo(44)
         }
         emptyBox.snp.makeConstraints { make in
            make.top.equalTo(groupQna.snp.bottom).offset(12)
            make.horizontalEdges.equalTo(scrollGuide)
            make.bottom.equalTo(scrollGuide).inset(4)
         }
      }
   }
}
