//
//  ProductDetailView.swift
//  runwithu
//
//  Created by 강한결 on 8/30/24.
//

import UIKit

import SnapKit

final class ProductDetailView: BaseView, BaseViewProtocol {
   private let scrollView = BaseScrollView()
   private let commentsInputBackView = RectangleView(backColor: .systemGray6, radius: 8)
   let commentsInput = UITextField()
   let commentsSendButton = UIButton()
   let creatorView = BaseCreatorView()
   
   private let type = BaseLabel(for: "", font: .systemFont(ofSize: 18, weight: .semibold), color: .systemOrange)
   private let ratingLabel = BaseLabel(for: "", font: .systemFont(ofSize: 14, weight: .light), color: .darkGray)
   private let titleLabel = BaseLabel(for: "", font: .boldSystemFont(ofSize: 20))
   private let titleDivider = RectangleView(backColor: .systemGray3, radius: 0)
   private let contentLabel = BaseLabel(for: "", font: .systemFont(ofSize: 16))
   private let contentDivider = RectangleView(backColor: .systemGray3, radius: 0)
   lazy var imageCollection = UICollectionView(frame: .zero, collectionViewLayout: createCollectionLayout())
   private let commentsEmptyView = UIImageView(image: .commentsFirst)
   let commentsTable = UITableView()
   
   override func setSubviews() {
      super.setSubviews()
      addSubviews(scrollView, commentsInputBackView)
      commentsInputBackView.addSubviews(commentsInput, commentsSendButton)
      scrollView.contentsView.addSubviews(creatorView, type, ratingLabel, titleLabel, titleDivider, contentLabel, contentDivider)
   }
   
   override func setLayout() {
      super.setLayout()
      
      scrollView.snp.makeConstraints { make in
         make.top.horizontalEdges.equalTo(self.safeAreaLayoutGuide)
         make.bottom.equalTo(commentsInputBackView.snp.top)
      }
      commentsInputBackView.snp.makeConstraints { make in
         make.height.equalTo(70)
         make.horizontalEdges.equalTo(safeAreaLayoutGuide)
         make.bottom.equalTo(safeAreaLayoutGuide).inset(80)
      }
      commentsInput.snp.makeConstraints { make in
         make.centerY.equalToSuperview()
         make.leading.equalTo(commentsInputBackView.safeAreaLayoutGuide).inset(16)
         make.width.equalTo(240)
         make.height.equalTo(48)
      }
      commentsSendButton.snp.makeConstraints { make in
         make.centerY.equalToSuperview()
         make.trailing.equalTo(commentsInputBackView.safeAreaLayoutGuide).inset(16)
         make.leading.equalTo(commentsInput.snp.trailing).offset(8)
         make.height.equalTo(40)
      }
      
      let guide = scrollView.contentsView.safeAreaLayoutGuide
      creatorView.snp.makeConstraints { make in
         make.top.equalTo(guide)
         make.horizontalEdges.equalTo(16)
         make.height.equalTo(48)
      }
      type.snp.makeConstraints { make in
         make.top.equalTo(creatorView.snp.bottom).offset(12)
         make.horizontalEdges.equalTo(guide).inset(16)
         make.height.equalTo(32)
      }
      titleLabel.snp.makeConstraints { make in
         make.top.equalTo(type.snp.bottom)
         make.horizontalEdges.equalTo(guide).inset(16)
         make.bottom.equalTo(ratingLabel.snp.top).offset(-8)
      }
      ratingLabel.snp.makeConstraints { make in
         make.height.equalTo(20)
         make.horizontalEdges.equalTo(guide).inset(16)
      }
      titleDivider.snp.makeConstraints { make in
         make.top.equalTo(ratingLabel.snp.bottom).offset(8)
         make.horizontalEdges.equalTo(guide)
         make.height.equalTo(0.5)
      }
      contentLabel.snp.makeConstraints { make in
         make.top.equalTo(titleDivider.snp.bottom).offset(12)
         make.horizontalEdges.equalTo(guide).inset(16)
      }
   }
   
   override func setUI() {
      super.setUI()
      titleLabel.numberOfLines = 0
      contentLabel.numberOfLines = 0
      commentsInputBackView.backgroundColor = .systemGray6
      commentsInputBackView.layer.shadowColor = UIColor.darkGray.cgColor
      commentsInputBackView.layer.shadowOpacity = 0.3
      commentsInputBackView.layer.shadowRadius = 1.0
      commentsInputBackView.layer.shadowOffset = .init(width: 0, height: -1)
      commentsInput.tintColor = .darkGray
      commentsInput.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 56))
      commentsInput.leftViewMode = .always
      commentsInput.placeholder = "댓글을 입력해보세요 :D"
      commentsInput.font = .systemFont(ofSize: 14)
      commentsSendButton.setTitle("전송", for: .normal)
      commentsSendButton.setTitleColor(.white, for: .normal)
      commentsSendButton.backgroundColor = .black
      commentsSendButton.layer.cornerRadius = 8
      commentsEmptyView.contentMode = .scaleAspectFit
   }
   
   func bindView(for detail: PostsOutput) {
      if let profileImage = detail.creator.profileImage {
         creatorView.bindView(imageURL: profileImage, name: detail.creator.nick)
      } else {
         creatorView.bindView(image: .userSelected, name: detail.creator.nick)
      }
      creatorView.bindCreatedDate(date: detail.createdAt)

      if let productType = detail.content3 {
         type.bindText(productType)
      }
      
      if let brands = detail.content2 {
         titleLabel.bindText("[\(brands)] \(detail.title)")
      } else {
         titleLabel.bindText(detail.title)
      }
      contentLabel.bindText(detail.content)
      
      if let rating = detail.content4 {
         ratingLabel.bindText("\(rating) / 5점")
      } else {
         ratingLabel.bindText("조금더 사용이 필요해요.")
      }
      
      setLayoutByCollection(isImages: !detail.files.isEmpty)
      setLayoutByTable(isComments: !detail.comments.isEmpty)
   }
   
   private func setLayoutByCollection(isImages: Bool) {
      let guide = scrollView.contentsView.safeAreaLayoutGuide
      if isImages {
         scrollView.contentsView.addSubview(imageCollection)
         imageCollection.register(EpilogueImageCollectionCell.self, forCellWithReuseIdentifier: EpilogueImageCollectionCell.id)
         imageCollection.snp.makeConstraints { make in
            make.top.equalTo(contentLabel.snp.bottom).offset(16)
            make.horizontalEdges.equalTo(guide).inset(12)
            make.height.equalTo(240)
         }
         contentDivider.snp.makeConstraints { make in
            make.top.equalTo(imageCollection.snp.bottom).offset(12)
            make.height.equalTo(0.5)
            make.horizontalEdges.equalTo(guide)
         }
      } else {
         contentDivider.snp.makeConstraints { make in
            make.top.equalTo(contentLabel.snp.bottom).offset(12)
            make.height.equalTo(0.5)
            make.horizontalEdges.equalTo(guide)
         }
      }
      setNeedsLayout()
   }
   
   private func setLayoutByTable(isComments: Bool) {
      let guide = scrollView.contentsView.safeAreaLayoutGuide
      
      if isComments {
         scrollView.contentsView.addSubview(commentsTable)
         commentsTable.register(BaseCommentsView.self, forCellReuseIdentifier: BaseCommentsView.id)
         commentsTable.rowHeight = UITableView.automaticDimension
         
         commentsTable.snp.makeConstraints { make in
            make.top.equalTo(contentDivider.snp.bottom).offset(24)
            make.horizontalEdges.equalTo(guide).inset(12)
            make.height.equalTo(300)
            make.bottom.equalTo(scrollView.contentsView.safeAreaLayoutGuide).inset(8)
         }
      } else {
         scrollView.contentsView.addSubview(commentsEmptyView)
         commentsEmptyView.snp.makeConstraints { make in
            make.top.equalTo(contentDivider.snp.bottom).offset(24)
            make.horizontalEdges.equalTo(guide).inset(24)
            make.bottom.equalTo(scrollView.contentsView.safeAreaLayoutGuide).inset(24)
         }
      }
      setNeedsLayout()
   }
}

extension ProductDetailView {
   private func createCollectionLayout() -> UICollectionViewCompositionalLayout {
      let itemSize = NSCollectionLayoutSize(
         widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0))
      let item = NSCollectionLayoutItem(layoutSize: itemSize)
      
      let groupSize = NSCollectionLayoutSize(
         widthDimension: .fractionalWidth(0.9), heightDimension: .fractionalHeight(1.0))
      let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
      
      let section = NSCollectionLayoutSection(group: group)
      section.orthogonalScrollingBehavior = .groupPaging
      
      return UICollectionViewCompositionalLayout(section: section)
   }
}
