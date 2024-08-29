//
//  RunningCommunityView.swift
//  runwithu
//
//  Created by 강한결 on 8/23/24.
//

import UIKit

import SnapKit

final class RunningCommunityView: BaseView, BaseViewProtocol {
   
   let communityWriteButton = PlusButton(backColor: .systemOrange, baseColor: .white)
   lazy var menuButtonCollection = {
      let view = UICollectionView(frame: .zero, collectionViewLayout: createCollectionLayout())
      view.register(CommunityMenuCell.self, forCellWithReuseIdentifier: CommunityMenuCell.id)
      view.delegate = nil
      view.isScrollEnabled = false
      return view
   }()
   let epiloguePostsTable = UITableView()
   let productPostsTable = UITableView()
   let qnaPostTable = UITableView()
   
   override func setSubviews() {
      super.setSubviews()
      addSubviews(menuButtonCollection)
   }
   
   override func setLayout() {
      super.setLayout()
      
      let guide = safeAreaLayoutGuide
      
      menuButtonCollection.snp.makeConstraints { make in
         make.top.equalTo(guide)
         make.horizontalEdges.equalTo(guide).inset(16)
         make.height.equalTo(56)
      }
   }
   
   override func setUI() {
      super.setUI()
      epiloguePostsTable.backgroundColor = .systemGray6.withAlphaComponent(0.5)
      qnaPostTable.backgroundColor = .systemGray6.withAlphaComponent(0.5)
      communityWriteButton.layer.zPosition = 100
      qnaPostTable.separatorStyle = .none
      epiloguePostsTable.separatorStyle = .none
   }
   
   func bindQnaView() {
      delegateClosure()

      addSubview(qnaPostTable)
      productPostsTable.removeFromSuperview()
      epiloguePostsTable.removeFromSuperview()

      qnaPostTable.register(QnaPostCell.self, forCellReuseIdentifier: QnaPostCell.id)
      qnaPostTable.rowHeight = UITableView.automaticDimension
      qnaPostTable.snp.makeConstraints { make in
         make.top.equalTo(menuButtonCollection.snp.bottom)
         make.horizontalEdges.equalTo(safeAreaLayoutGuide)
         make.bottom.equalTo(safeAreaLayoutGuide).inset(80)
      }
      bindFloatingButtonLayout()
   }
   
   func bindEpilogueView() {
      delegateClosure()
      
      addSubview(epiloguePostsTable)
      qnaPostTable.removeFromSuperview()
      productPostsTable.removeFromSuperview()
      
      epiloguePostsTable.rowHeight = UITableView.automaticDimension
      epiloguePostsTable.register(EpiloguePostCell.self, forCellReuseIdentifier: EpiloguePostCell.id)
      epiloguePostsTable.snp.makeConstraints { make in
         make.top.equalTo(menuButtonCollection.snp.bottom)
         make.horizontalEdges.equalTo(safeAreaLayoutGuide)
         make.bottom.equalTo(safeAreaLayoutGuide).inset(80)
      }
      bindFloatingButtonLayout()
   }
   
   func bindRunningProductView() {
      delegateClosure()
      
      addSubview(productPostsTable)
      epiloguePostsTable.removeFromSuperview()
      qnaPostTable.removeFromSuperview()
      
      productPostsTable.register(ProductPostCell.self, forCellReuseIdentifier: ProductPostCell.id)
      productPostsTable.rowHeight = UITableView.automaticDimension
      productPostsTable.separatorStyle = .none
      
      productPostsTable.snp.makeConstraints { make in
         make.top.equalTo(menuButtonCollection.snp.bottom)
         make.horizontalEdges.equalTo(safeAreaLayoutGuide)
         make.bottom.equalTo(safeAreaLayoutGuide).inset(80)
      }
      bindFloatingButtonLayout()
   }
   
   private func delegateClosure() {
      epiloguePostsTable.delegate = nil
      epiloguePostsTable.dataSource = nil
      qnaPostTable.delegate = nil
      qnaPostTable.dataSource = nil
      productPostsTable.delegate = nil
      productPostsTable.dataSource = nil
   }
   
   private func bindFloatingButtonLayout() {
      addSubview(communityWriteButton)
      communityWriteButton.snp.makeConstraints { make in
         make.size.equalTo(56)
         make.trailing.equalTo(safeAreaLayoutGuide).inset(20)
         make.bottom.equalTo(safeAreaLayoutGuide).inset(120)
      }
   }
}

extension RunningCommunityView {
   private func createCollectionLayout() -> UICollectionViewCompositionalLayout {
      let itemSize = NSCollectionLayoutSize(
         widthDimension: .estimated(50),
         heightDimension: .absolute(32)
      )
      
      let item = NSCollectionLayoutItem(layoutSize: itemSize)
      
      let groupSize = NSCollectionLayoutSize(
         widthDimension: .fractionalWidth(1.0),
         heightDimension: .absolute(32)
      )
      
      let group = NSCollectionLayoutGroup.horizontal(
         layoutSize: groupSize,
         subitems: [item]
      )
      group.interItemSpacing = .fixed(6.0)
      
      let section = NSCollectionLayoutSection(group: group)
      section.interGroupSpacing = 12
      section.contentInsets = NSDirectionalEdgeInsets(top: 6, leading: 8, bottom: 6, trailing: 0)
      
      return UICollectionViewCompositionalLayout(section: section)
   }
}
