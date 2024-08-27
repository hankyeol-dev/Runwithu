//
//  RunningEpilogueDetailView.swift
//  runwithu
//
//  Created by 강한결 on 8/27/24.
//

import UIKit

import SnapKit

final class RunningEpilogueDetailView: BaseView, BaseViewProtocol {
   private let scrollView = BaseScrollView()
   let creatorView = BaseCreatorView()
   private let contentType = BaseLabel(for: "", font: .systemFont(ofSize: 15, weight: .semibold))
   private let contentTypeUnderBar = RectangleView(backColor: .systemIndigo, radius: 2)
   private let titleView = BaseLabel(for: "", font: .boldSystemFont(ofSize: 20))
   private let titleDivider = RectangleView(backColor: .systemGray3, radius: 0)
   private let bodyView = BaseLabel(for: "", font: .systemFont(ofSize: 16, weight: .regular))
   private let bodyDivider = RectangleView(backColor: .systemGray3, radius: 0)
   lazy var imageCollection = UICollectionView(frame: .zero, collectionViewLayout: createCollectionLayout())
   private let commentsEmptyView = UIImageView(image: .commentsFirst)
   let commentsTable = UITableView()
   private let commentsInputBackView = RectangleView(backColor: .systemGray6, radius: 8)
   let commentsInput = UITextField()
   let commentsSendButton = UIButton()
   
   override func setSubviews() {
      super.setSubviews()
      addSubview(scrollView)
      scrollView.contentsView.addSubviews(
         creatorView, contentType, contentTypeUnderBar, titleView, titleDivider, bodyView, bodyDivider, commentsInputBackView
      )
      commentsInputBackView.addSubviews(commentsInput, commentsSendButton)
   }
   
   override func setLayout() {
      super.setLayout()
      scrollView.snp.makeConstraints { make in
         make.top.horizontalEdges.equalTo(self.safeAreaLayoutGuide)
         make.bottom.equalTo(self.safeAreaLayoutGuide).inset(64)
      }
      
      let guide = scrollView.contentsView.safeAreaLayoutGuide
      creatorView.snp.makeConstraints { make in
         make.top.equalTo(guide).inset(8)
         make.horizontalEdges.equalTo(24)
         make.height.equalTo(64)
      }
      
      contentType.snp.makeConstraints { make in
         make.top.equalTo(creatorView.snp.bottom).offset(12)
         make.leading.equalTo(guide).inset(24)
         make.height.equalTo(24)
      }
      
      contentTypeUnderBar.snp.makeConstraints { make in
         make.top.equalTo(contentType.snp.bottom).offset(4)
         make.leading.equalTo(guide).inset(24)
         make.width.equalTo(contentType.snp.width)
         make.height.equalTo(2)
      }
      
      titleView.snp.makeConstraints { make in
         make.top.equalTo(contentTypeUnderBar.snp.bottom).offset(16)
         make.horizontalEdges.equalTo(guide).inset(24)
      }
      
      titleDivider.snp.makeConstraints { make in
         make.top.equalTo(titleView.snp.bottom).offset(24)
         make.height.equalTo(0.5)
         make.horizontalEdges.equalTo(guide)
      }
      
      bodyView.snp.makeConstraints { make in
         make.top.equalTo(titleDivider.snp.bottom).offset(24)
         make.horizontalEdges.equalTo(guide).inset(24)
      }
      
   }
   
   override func setUI() {
      super.setUI()
      titleView.numberOfLines = 0
      bodyView.numberOfLines = 0
      imageCollection.register(EpilogueImageCollectionCell.self, forCellWithReuseIdentifier: EpilogueImageCollectionCell.id)
      commentsInputBackView.backgroundColor = .systemGray6
      commentsInputBackView.layer.shadowColor = UIColor.darkGray.cgColor
      commentsInputBackView.layer.shadowOpacity = 0.3
      commentsInputBackView.layer.shadowRadius = 1.4
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
      commentsEmptyView.contentMode = .center
      
   }
   
   func bindContents(for epilogue: PostsOutput) {
      DispatchQueue.main.async { [weak self] in
         guard let self else { return }
         if let content1 = epilogue.content1 {
            switch content1 {
            case PostsCommunityType.epilogue.rawValue:
               self.contentType.bindText(PostsCommunityType.epilogue.byDetailLabel)
            case PostsCommunityType.product_epilogue.rawValue:
               self.contentType.bindText(PostsCommunityType.product_epilogue.byDetailLabel)
            default:
               break
            }
         }
         self.titleView.bindText(epilogue.title)
         self.bodyView.bindText(epilogue.content)
         self.setLayoutByCollection(isImages: !epilogue.files.isEmpty)
         self.setLayoutByTable(isComments: !epilogue.comments.isEmpty)
      }
   }
   
   private func setLayoutByCollection(isImages: Bool) {
      let guide = scrollView.contentsView.safeAreaLayoutGuide
      if isImages {
         scrollView.contentsView.addSubview(imageCollection)
         imageCollection.snp.makeConstraints { make in
            make.top.equalTo(bodyView.snp.bottom).offset(16)
            make.horizontalEdges.equalTo(guide).inset(12)
            make.height.equalTo(240)
         }
         bodyDivider.snp.makeConstraints { make in
            make.top.equalTo(imageCollection.snp.bottom).offset(8)
            make.height.equalTo(0.5)
            make.horizontalEdges.equalTo(guide)
         }
      } else {
         bodyDivider.snp.makeConstraints { make in
            make.top.equalTo(bodyView.snp.bottom).offset(8)
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
         commentsTable.delegate = nil
         commentsTable.register(BaseCommentsView.self, forCellReuseIdentifier: BaseCommentsView.id)
         commentsTable.rowHeight = 130
         
         commentsTable.snp.makeConstraints { make in
            make.top.equalTo(bodyDivider.snp.bottom).offset(24)
            make.horizontalEdges.equalTo(guide).inset(12)
            make.height.equalTo(400)
         }
         commentsInputBackView.snp.makeConstraints { make in
            make.top.equalTo(commentsTable.snp.bottom).offset(12)
            make.horizontalEdges.equalTo(guide)
            make.height.equalTo(100)
            make.bottom.equalTo(guide).inset(8)
         }
         
         
      } else {
         scrollView.contentsView.addSubview(commentsEmptyView)
         commentsEmptyView.snp.makeConstraints { make in
            make.top.equalTo(bodyDivider.snp.bottom).offset(24)
            make.horizontalEdges.equalTo(guide).inset(24)
            make.bottom.equalTo(commentsInputBackView.snp.top).offset(-24)
         }
         commentsInputBackView.snp.makeConstraints { make in
            make.height.equalTo(100)
            make.horizontalEdges.equalTo(guide)
            make.bottom.equalTo(guide).inset(8)
         }
      }
      
      commentsInput.snp.makeConstraints { make in
         make.centerY.equalToSuperview()
         make.leading.equalTo(commentsInputBackView.safeAreaLayoutGuide).inset(16)
         make.width.equalTo(300)
         make.height.equalTo(56)
      }
      commentsSendButton.snp.makeConstraints { make in
         make.centerY.equalToSuperview()
         make.trailing.equalTo(commentsInputBackView.safeAreaLayoutGuide).inset(16)
         make.leading.equalTo(commentsInput.snp.trailing).offset(16)
         make.height.equalTo(56)
      }
      
      setNeedsLayout()
   }
}

extension RunningEpilogueDetailView {
   private func createCollectionLayout() -> UICollectionViewCompositionalLayout {
      let itemSize = NSCollectionLayoutSize(
         widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0))
      let item = NSCollectionLayoutItem(layoutSize: itemSize)
      
      let groupSize = NSCollectionLayoutSize(
         widthDimension: .fractionalWidth(0.85), heightDimension: .fractionalHeight(1.0))
      let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
      
      let section = NSCollectionLayoutSection(group: group)
      section.orthogonalScrollingBehavior = .groupPaging
      
      return UICollectionViewCompositionalLayout(section: section)
   }
}
