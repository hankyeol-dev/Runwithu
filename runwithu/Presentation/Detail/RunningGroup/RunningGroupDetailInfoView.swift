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
   private let groupTitle = BaseLabel(for: "", font: .boldSystemFont(ofSize: 32))
   private let groupSpot = BaseLabel(for: "", font: .systemFont(ofSize: 20))
   private let groupUserCount = BaseLabel(for: "", font: .systemFont(ofSize: 20))
   private let groupHardType = BaseLabel(for: "", font: .systemFont(ofSize: 20))
   private let groupDescript = BaseLabel(for: "", font: .systemFont(ofSize: 20))
   private let groupOwnerImage = UIImageView()
   private let groupOwnerName = BaseLabel(for: "", font: .systemFont(ofSize: 20))
   let groupEntryTable = UITableView()
   
   override func setSubviews() {
      super.setSubviews()
      addSubview(scrollView)
      scrollView.contentsView.addSubviews(
         groupTitle, groupSpot, groupUserCount, groupHardType, groupDescript, groupEntryTable, groupOwnerName, groupOwnerImage)
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
      groupSpot.snp.makeConstraints { make in
         make.top.equalTo(groupTitle.snp.bottom).offset(12)
         make.horizontalEdges.equalTo(guide).inset(16)
      }
      groupUserCount.snp.makeConstraints { make in
         make.top.equalTo(groupSpot.snp.bottom).offset(12)
         make.horizontalEdges.equalTo(guide).inset(16)
      }
      groupHardType.snp.makeConstraints { make in
         make.top.equalTo(groupUserCount.snp.bottom).offset(12)
         make.horizontalEdges.equalTo(guide).inset(16)
      }
      groupOwnerImage.snp.makeConstraints { make in
         make.top.equalTo(groupHardType.snp.bottom).offset(12)
         make.leading.equalTo(guide).inset(16)
         make.size.equalTo(44)
      }
      groupOwnerName.snp.makeConstraints { make in
         make.centerY.equalTo(groupOwnerImage)
         make.leading.equalTo(groupOwnerImage.snp.trailing).offset(12)
         make.trailing.equalTo(guide).inset(12)
      }
      groupDescript.snp.makeConstraints { make in
         make.top.equalTo(groupOwnerImage.snp.bottom).offset(24)
         make.horizontalEdges.equalTo(guide).inset(16)
      }
      groupEntryTable.snp.makeConstraints { make in
         make.top.equalTo(groupDescript.snp.bottom).offset(24)
         make.horizontalEdges.bottom.equalTo(guide)
      }
   }
   
   override func setUI() {
      super.setUI()
      [groupTitle, groupSpot, groupUserCount, groupHardType, groupDescript].forEach {
         $0.numberOfLines = 0
      }
      groupEntryTable.backgroundColor = .systemGreen
      groupOwnerImage.layer.cornerRadius = 22
      groupOwnerImage.clipsToBounds = true
      groupOwnerImage.contentMode = .scaleToFill
      groupEntryTable.register(RunningGroupEntryCell.self, forCellReuseIdentifier: RunningGroupEntryCell.id)
      groupEntryTable.rowHeight = 60
      groupEntryTable.separatorInset = .init(top: 2, left: 2, bottom: 2, right: 2)
      groupEntryTable.delegate = nil
   }
   
   func bindView(for data: PostsOutput) {
      dump(data)
      if let content1 = data.content1,
         let content2 = data.content2,
         let content3 = data.content3 {
         groupTitle.text = data.title
         groupUserCount.text = content1
         groupSpot.text = content2
         groupHardType.text = content3
         groupDescript.text = data.content
      }
      
      if let profileImage = data.creator.profileImage {
         Task {
            await getImageFromServer(for: groupOwnerImage, by: profileImage)
         }
      } else {
         groupOwnerImage.image = .userSelected
      }
      groupOwnerName.text = data.creator.nick
   }
}
