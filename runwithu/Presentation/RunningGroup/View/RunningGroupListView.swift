//
//  RunningGroupListView.swift
//  runwithu
//
//  Created by 강한결 on 8/20/24.
//

import UIKit

import SnapKit

final class RunningGroupListView: BaseView, BaseViewProtocol {
   private let scrollView = BaseScrollView()
   
   private let userCreateSection = RectangleView(backColor: .white, radius: 8)
   private let userCreateSectionTitle = BaseLabel(for: "내가 운영하는 러닝 그룹", font: .boldSystemFont(ofSize: 16))
   lazy var userCreateSectionCollection = UICollectionView(frame: .zero, collectionViewLayout: createUserCreateSectionCollectionLayout())
   let userCreateButton = RoundedButtonView("+ 러닝 그룹 생성", backColor: .systemPurple, baseColor: .white, radius: 8)
   
   private let userJoinedSection = RectangleView(backColor: .white, radius: 8)
   private let userJoinedTitle = BaseLabel(for: "내가 가입한 러닝 그룹", font: .boldSystemFont(ofSize: 16))
   lazy var userJoinedCollection = UICollectionView(frame: .zero, collectionViewLayout: createUserJoinedSectionCollectionLayout())
   private let userJoinedGroupEmptyText = BaseLabel(for: "아직 가입한 러닝 그룹이 없어요.", font: .systemFont(ofSize: 15))
   
   private let runningGroupSection = RectangleView(backColor: .white, radius: 8)
   private let runningGroupSectionTittle = BaseLabel(for: "이런 러닝 그룹은 어떤가요?", font: .boldSystemFont(ofSize: 16))
   let runningGroupTable = UITableView()
   
   override func setSubviews() {
      super.setSubviews()
      
      addSubviews(scrollView)
      scrollView.contentsView.addSubviews(userCreateSection, userJoinedSection, runningGroupSection)
      userCreateSection.addSubviews(userCreateSectionTitle, userCreateButton, userCreateSectionCollection)
      userJoinedSection.addSubviews(userJoinedTitle, userJoinedCollection, userJoinedGroupEmptyText)
      runningGroupSection.addSubviews(runningGroupSectionTittle, runningGroupTable)
   }
   
   override func setLayout() {
      super.setLayout()
      
      scrollView.snp.makeConstraints { make in
         make.top.horizontalEdges.equalTo(safeAreaLayoutGuide)
         make.bottom.equalTo(safeAreaLayoutGuide).inset(84)
      }
      
      
      let scrollGuide = scrollView.contentsView.safeAreaLayoutGuide
      userCreateSection.snp.makeConstraints { make in
         make.top.horizontalEdges.equalTo(scrollGuide)
      }
      userCreateSectionTitle.snp.makeConstraints { make in
         make.top.equalTo(userCreateSection.safeAreaLayoutGuide).inset(8)
         make.horizontalEdges.equalTo(userCreateSection.safeAreaLayoutGuide).inset(24)
         make.height.equalTo(24)
      }
      userJoinedSection.snp.makeConstraints { make in
         make.top.equalTo(userCreateSection.snp.bottom)
         make.horizontalEdges.equalTo(scrollGuide)
      }
      userJoinedTitle.snp.makeConstraints { make in
         make.top.equalTo(userJoinedSection.safeAreaLayoutGuide).inset(16)
         make.horizontalEdges.equalTo(userJoinedSection.safeAreaLayoutGuide).inset(24)
         make.height.equalTo(24)
      }
      runningGroupSection.snp.makeConstraints { make in
         make.top.equalTo(userJoinedSection.snp.bottom).offset(12)
         make.horizontalEdges.bottom.equalTo(scrollGuide)
      }
      runningGroupSectionTittle.snp.makeConstraints { make in
         make.top.equalTo(runningGroupSection.safeAreaLayoutGuide).inset(16)
         make.horizontalEdges.equalTo(runningGroupSection.safeAreaLayoutGuide).inset(24)
         make.height.equalTo(24)
      }
      runningGroupTable.snp.makeConstraints { make in
         make.top.equalTo(runningGroupSectionTittle.snp.bottom)
         make.horizontalEdges.equalTo(runningGroupSection.safeAreaLayoutGuide).inset(24)
         make.height.equalTo(1000)
         make.bottom.equalTo(runningGroupSection.safeAreaLayoutGuide).inset(12)
      }
   }
   
   override func setUI() {
      super.setUI()
      scrollView.backgroundColor = .systemGray6
      runningGroupTable.register(GroupListTableCell.self, forCellReuseIdentifier: GroupListTableCell.id)
      runningGroupTable.separatorStyle = .none
      runningGroupTable.rowHeight = UITableView.automaticDimension
   }
   
   func bindUserCreateSection(isGroup: Bool) {
      if isGroup {
         userCreateButton.removeFromSuperview()
         
         userCreateSectionCollection.register(GroupListCollectionCell.self, forCellWithReuseIdentifier: GroupListCollectionCell.id)
         userCreateSectionCollection.delegate = nil
         userCreateSectionCollection.dataSource = nil
         
         
         userCreateSectionCollection.snp.makeConstraints { make in
            make.top.equalTo(userCreateSectionTitle.snp.bottom)
            make.horizontalEdges.equalTo(userCreateSection.safeAreaLayoutGuide).inset(24)
            make.height.equalTo(120)
            make.bottom.equalTo(userCreateSection.safeAreaLayoutGuide).inset(8)
         }
      } else {
         userCreateSectionCollection.removeFromSuperview()
         userCreateButton.snp.makeConstraints { make in
            make.top.equalTo(userCreateSectionTitle.snp.bottom).offset(8)
            make.leading.equalTo(userCreateSection.safeAreaLayoutGuide).inset(24)
            make.height.equalTo(44)
            make.width.equalTo(150)
            make.bottom.equalTo(userCreateSection.safeAreaLayoutGuide).inset(8)
         }
      }
   }
   
   func bindUserJoinedSection(isGroup: Bool) {
      if isGroup {
         userJoinedGroupEmptyText.removeFromSuperview()
         
         userJoinedCollection.register(GroupListCollectionCell.self, forCellWithReuseIdentifier: GroupListCollectionCell.id)
         userJoinedCollection.delegate = nil
         userJoinedCollection.dataSource = nil
         
         userJoinedCollection.snp.makeConstraints { make in
            make.top.equalTo(userJoinedTitle.snp.bottom)
            make.horizontalEdges.equalTo(userJoinedSection.safeAreaLayoutGuide).inset(24)
            make.height.equalTo(120)
            make.bottom.equalTo(userJoinedSection.safeAreaLayoutGuide).inset(8)
         }
      } else {
         userJoinedCollection.removeFromSuperview()
         userJoinedGroupEmptyText.snp.makeConstraints { make in
            make.top.equalTo(userJoinedTitle.snp.bottom).offset(8)
            make.horizontalEdges.equalTo(userJoinedSection).inset(24)
            make.height.equalTo(24)
            make.bottom.equalTo(userJoinedSection.safeAreaLayoutGuide).inset(24)
         }
      }
   }
}

extension RunningGroupListView {
   private func createUserCreateSectionCollectionLayout() -> UICollectionViewCompositionalLayout {
      let itemSize = NSCollectionLayoutSize(
         widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0))
      let item = NSCollectionLayoutItem(layoutSize: itemSize)
      
      let groupSize = NSCollectionLayoutSize(
         widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(120))
      let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
      
      let section = NSCollectionLayoutSection(group: group)
      
      return UICollectionViewCompositionalLayout(section: section)
   }
   
   private func createUserJoinedSectionCollectionLayout() -> UICollectionViewCompositionalLayout {
      let itemSize = NSCollectionLayoutSize(
         widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0))
      let item = NSCollectionLayoutItem(layoutSize: itemSize)
      
      let groupSize = NSCollectionLayoutSize(
         widthDimension: .fractionalWidth(0.95), heightDimension: .absolute(120))
      let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
      
      
      let section = NSCollectionLayoutSection(group: group)
      section.orthogonalScrollingBehavior = .groupPaging
      
      return UICollectionViewCompositionalLayout(section: section)
   }
}
