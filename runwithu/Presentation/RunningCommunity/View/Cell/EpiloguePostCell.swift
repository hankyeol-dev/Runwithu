//
//  EpiloguePostCell.swift
//  runwithu
//
//  Created by 강한결 on 8/29/24.
//

import UIKit

import SnapKit
import RxSwift
import RxGesture

final class EpiloguePostCell: BaseTableViewCell {
   let disposeBag = DisposeBag()
   
   private let backView = RectangleView(backColor: .white, radius: 0)
   let user = BaseUserImage(size: 24, borderW: 2, borderColor: .darkGray)
   private let userInfoStack = UIStackView()
   private let username = BaseLabel(for: "", font: .systemFont(ofSize: 12, weight: .medium))
   private let userCreatedAt = BaseLabel(for: "", font: .systemFont(ofSize: 12, weight: .light))
   
   private let contentLabel = BaseLabel(for: "", font: .systemFont(ofSize: 13))
   private let divider = RectangleView(backColor: .darkGray.withAlphaComponent(0.5), radius: 0)
   private let postLikeAndComment = BasePostCommentAndLikeView()
   
   override func setSubviews() {
      contentView.addSubview(backView)
   }
   
   override func setLayout() {
      super.setLayout()
      backView.snp.makeConstraints { make in
         make.verticalEdges.equalTo(contentView.safeAreaLayoutGuide).inset(4)
         make.horizontalEdges.equalTo(contentView.safeAreaLayoutGuide)
      }
   }
   
   override func setUI() {
      super.setUI()
      contentView.backgroundColor = .systemGray6.withAlphaComponent(0.8)
      selectionStyle = .none
   }
   
   func bindView(by epilogues: PostsOutput) {
      bindCreatorView(creator: epilogues.creator, createdAt: epilogues.createdAt)
      bindImageCollection(files: epilogues.files)
      contentLabel.bindText(epilogues.content)
      postLikeAndComment.bindView(like: epilogues.likes.count, comment: epilogues.comments.count)
   }
   
   private func bindCreatorView(creator: BaseProfileType, createdAt: String) {
      if let userImageURL = creator.profileImage {
         Task {
            await getImageFromServer(for: user, by: userImageURL)
         }
      } else {
         user.image = .userSelected
      }
      username.bindText(creator.nick)
      if let dateText = createdAt.split(separator: "T").first {
         userCreatedAt.bindText(String(dateText))
      }
      
      backView.addSubviews(user, userInfoStack)
      userInfoStack.addArrangedSubview(username)
      userInfoStack.addArrangedSubview(userCreatedAt)
      userInfoStack.axis = .vertical
      userInfoStack.distribution = .fillEqually
      userInfoStack.spacing = 4
      
      user.snp.makeConstraints { make in
         make.top.leading.equalTo(backView.safeAreaLayoutGuide).inset(12)
         make.size.equalTo(24)
      }
      userInfoStack.snp.makeConstraints { make in
         make.top.trailing.equalTo(backView.safeAreaLayoutGuide).inset(12)
         make.leading.equalTo(user.snp.trailing).offset(12)
         make.centerY.equalTo(user.snp.centerY)
      }
   }
   
   private func bindImageCollection(files: [String]) {
      backView.addSubviews(contentLabel, divider, postLikeAndComment)
      
      if !files.isEmpty {
         let imageCollection = UICollectionView(frame: .zero, collectionViewLayout: createImageCollectionlayout(for: files.count))
         imageCollection.delegate = nil
         imageCollection.dataSource = nil
         imageCollection.register(EpilogueImageCollectionCell.self, forCellWithReuseIdentifier: EpilogueImageCollectionCell.id)
         backView.addSubview(imageCollection)
         imageCollection.snp.makeConstraints { make in
            make.top.equalTo(user.snp.bottom).offset(12)
            make.horizontalEdges.equalTo(backView.safeAreaLayoutGuide)
            make.height.equalTo(files.count == 1 ? 240 : files.count == 2 ? 180 : 150)
         }
         imageCollection.layer.cornerRadius = 12
         imageCollection.layer.masksToBounds = true
         
         Observable.just(files)
            .bind(to: imageCollection.rx.items(
               cellIdentifier: EpilogueImageCollectionCell.id,
               cellType: EpilogueImageCollectionCell.self)) { row, imageURL, cell in
                  cell.bindView(for: imageURL)
               }
               .disposed(by: disposeBag)
         
         contentLabel.snp.makeConstraints { make in
            make.top.equalTo(imageCollection.snp.bottom).offset(8)
            make.horizontalEdges.equalTo(backView.safeAreaLayoutGuide).inset(16)
            make.height.equalTo(20)
         }
      } else {
         contentLabel.snp.makeConstraints { make in
            make.top.equalTo(user.snp.bottom).offset(12)
            make.horizontalEdges.equalTo(backView.safeAreaLayoutGuide).inset(16)
            make.height.equalTo(20)
         }
      }
      
      divider.snp.makeConstraints { make in
         make.top.equalTo(contentLabel.snp.bottom).offset(12)
         make.horizontalEdges.equalTo(backView.safeAreaLayoutGuide).inset(4)
         make.height.equalTo(1.0)
      }
      postLikeAndComment.snp.makeConstraints { make in
         make.top.equalTo(divider.snp.bottom).offset(8)
         make.horizontalEdges.equalTo(backView.safeAreaLayoutGuide).inset(16)
         make.height.equalTo(24)
         make.bottom.equalTo(backView.safeAreaLayoutGuide).inset(8)
      }
      
      setNeedsLayout()
   }
   
   private func createImageCollectionlayout(for count: Int) -> UICollectionViewCompositionalLayout {
      var item: NSCollectionLayoutItem
      var group: NSCollectionLayoutGroup
      
      switch count {
      case 1:
         item = .init(layoutSize: .init(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0)))
      case 2:
         item = .init(layoutSize: .init(widthDimension: .fractionalWidth(1/2), heightDimension: .fractionalHeight(1.0)))
      default:
         item = .init(layoutSize: .init(widthDimension: .fractionalWidth(1/3), heightDimension: .fractionalHeight(1.0)))
      }
      item.contentInsets = NSDirectionalEdgeInsets(top: 0.0, leading: 1.0, bottom: 0.0, trailing: 1.0)
      group = NSCollectionLayoutGroup.horizontal(layoutSize: .init(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0)), subitems: [item])
      group.contentInsets = NSDirectionalEdgeInsets(top: 8.0, leading: 0.0, bottom: 8.0, trailing: 0.0)
      
      let section = NSCollectionLayoutSection(group: group)
      return UICollectionViewCompositionalLayout(section: section)
   }
}
