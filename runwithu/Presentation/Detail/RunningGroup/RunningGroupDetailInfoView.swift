//
//  RunningGroupDetailInfoView.swift
//  runwithu
//
//  Created by 강한결 on 8/26/24.
//

import UIKit

import SnapKit

final class RunningGroupDetailInfoView: BaseView, BaseViewProtocol {
   private let scrollView = BaseScrollView()
   private let groupTitle = BaseLabel(for: "", font: .boldSystemFont(ofSize: 24))
   private let groupDescript = BaseLabel(for: "", font: .systemFont(ofSize: 16))
   private let divider = RectangleView(backColor: .systemGray6, radius: 0)
   private let groupInfoTitle = BaseLabel(for: "그룹 기본 정보", font: .systemFont(ofSize: 15, weight: .semibold))
   private let groupSpot = BaseLabel(for: "", font: .systemFont(ofSize: 16))
   private let groupUserCount = BaseLabel(for: "", font: .systemFont(ofSize: 16))
   private let groupHardType = BaseLabel(for: "", font: .systemFont(ofSize: 16))
   private let groupOwnerName = BaseLabel(for: "", font: .systemFont(ofSize: 16))
   private let divider2 = RectangleView(backColor: .systemGray6, radius: 0)
   private let groupEntryTitle = BaseLabel(for: "함께 달리는 그룹원", font: .systemFont(ofSize: 15, weight: .semibold))
   let groupEntryTable = UITableView()
   
   override func setSubviews() {
      super.setSubviews()
      addSubview(scrollView)
      scrollView.contentsView.addSubviews(
         groupTitle, groupInfoTitle, groupSpot, groupUserCount, groupHardType, groupDescript, groupEntryTable, groupOwnerName, groupEntryTitle, divider, divider2)
   }
   
   override func setLayout() {
      super.setLayout()
      scrollView.snp.makeConstraints { make in
         make.top.horizontalEdges.equalTo(self.safeAreaLayoutGuide)
         make.bottom.equalTo(self.safeAreaLayoutGuide).inset(60)
      }
      
      let guide = scrollView.contentsView.safeAreaLayoutGuide
      groupTitle.snp.makeConstraints { make in
         make.top.horizontalEdges.equalTo(guide).inset(16)
      }
      groupDescript.snp.makeConstraints { make in
         make.top.equalTo(groupTitle.snp.bottom).offset(16)
         make.horizontalEdges.equalTo(guide).inset(16)
      }
      divider.snp.makeConstraints { make in
         make.top.equalTo(groupDescript.snp.bottom).offset(12)
         make.horizontalEdges.equalTo(guide)
         make.height.equalTo(12)
      }
      groupInfoTitle.snp.makeConstraints { make in
         make.top.equalTo(divider.snp.bottom).offset(8)
         make.horizontalEdges.equalTo(guide).inset(16)
      }
      groupSpot.snp.makeConstraints { make in
         make.top.equalTo(groupInfoTitle.snp.bottom).offset(12)
         make.horizontalEdges.equalTo(guide).inset(16)
      }
      groupUserCount.snp.makeConstraints { make in
         make.top.equalTo(groupSpot.snp.bottom).offset(8)
         make.horizontalEdges.equalTo(guide).inset(16)
      }
      groupHardType.snp.makeConstraints { make in
         make.top.equalTo(groupUserCount.snp.bottom).offset(8)
         make.horizontalEdges.equalTo(guide).inset(16)
      }
      
      groupOwnerName.snp.makeConstraints { make in
         make.top.equalTo(groupHardType.snp.bottom).offset(8)
         make.horizontalEdges.equalTo(guide).offset(16)
      }
      divider2.snp.makeConstraints { make in
         make.top.equalTo(groupOwnerName.snp.bottom).offset(12)
         make.height.equalTo(12)
         make.horizontalEdges.equalTo(guide)
      }
      
      groupEntryTitle.snp.makeConstraints { make in
         make.top.equalTo(divider2.snp.bottom).offset(8)
         make.horizontalEdges.equalTo(guide).inset(16)
         make.height.equalTo(24)
      }
      groupEntryTable.snp.makeConstraints { make in
         make.top.equalTo(groupEntryTitle.snp.bottom)
         make.horizontalEdges.bottom.equalTo(guide)
         make.height.equalTo(300)
      }
   }
   
   override func setUI() {
      super.setUI()
      [groupTitle, groupSpot, groupUserCount, groupHardType, groupDescript].forEach {
         $0.numberOfLines = 0
      }
      groupEntryTable.register(RunningGroupEntryCell.self, forCellReuseIdentifier: RunningGroupEntryCell.id)
      groupEntryTable.rowHeight = 60
      groupEntryTable.separatorInset = .init(top: 2, left: 2, bottom: 2, right: 2)
      groupEntryTable.delegate = nil
   }
   
   func bindView(for data: PostsOutput) {
      groupTitle.bindText(data.title)
      groupDescript.bindText(data.content)

      if let content1 = data.content1,
         let content2 = data.content2,
         let content3 = data.content3 {
         groupSpot.bindText("📍지역: \(content2)")
         groupUserCount.bindText("🏃🏻제한 인원: \(content1)명")
         groupHardType.bindText("💪그룹 러닝 난이도: \(content3)")
      }
      groupOwnerName.bindText("👑 그룹장: \(data.creator.nick) ")
   }
}
