//
//  QnaDetailView.swift
//  runwithu
//
//  Created by 강한결 on 8/25/24.
//

import UIKit

import SnapKit

final class QnaDetailView: BaseView, BaseViewProtocol {
   let creatorView = BaseCreatorView()
   private let contentTitle = BaseLabel(for: "", font: .boldSystemFont(ofSize: 20))
   private let contentTitleDivider = RectangleView(backColor: .systemGray3, radius: 0)
   private let contentBody = BaseLabel(for: "", font: .systemFont(ofSize: 16, weight: .regular))
   private let contentBodyDivider = RectangleView(backColor: .systemGray3, radius: 0)
   private let contentCommentsEmptyView = UIImageView(image: .commentsFirst)
   let contentCommentsTable = UITableView()
   
   private let commentsInputBackView = UIView()
   let commentsInput = UITextField()
   let commentsSendButton = UIButton()
   
   
   override func setSubviews() {
      super.setSubviews()
      addSubviews(commentsInputBackView, creatorView, contentTitle, contentBody, contentTitleDivider, contentBodyDivider)
      commentsInputBackView.addSubviews(commentsInput, commentsSendButton)
   }
   
   override func setLayout() {
      super.setLayout()
      
      let guide = self.safeAreaLayoutGuide
      
      creatorView.snp.makeConstraints { make in
         make.top.horizontalEdges.equalTo(guide).inset(8)
         make.height.equalTo(64)
      }
      contentTitle.snp.makeConstraints { make in
         make.top.equalTo(creatorView.snp.bottom)
         make.horizontalEdges.equalTo(guide).inset(24)
         make.bottom.equalTo(contentTitleDivider.snp.top).offset(-16)
      }
      contentTitleDivider.snp.makeConstraints { make in
         make.horizontalEdges.equalTo(guide)
         make.height.equalTo(0.5)
      }
      contentBody.snp.makeConstraints { make in
         make.top.equalTo(contentTitleDivider.snp.bottom).offset(16)
         make.horizontalEdges.equalTo(guide).inset(32)
         make.bottom.equalTo(contentBodyDivider.snp.top).offset(-16)
      }
      contentBodyDivider.snp.makeConstraints { make in
         make.horizontalEdges.equalTo(guide)
         make.height.equalTo(0.5)
      }
      commentsInputBackView.snp.makeConstraints { make in
         make.horizontalEdges.equalTo(safeAreaLayoutGuide)
         make.bottom.equalTo(safeAreaLayoutGuide).inset(88)
         make.height.equalTo(80)
      }
      commentsInput.snp.makeConstraints { make in
         make.centerY.equalToSuperview()
         make.leading.equalTo(commentsInputBackView.safeAreaLayoutGuide).inset(16)
         make.width.equalTo(220)
         make.height.equalTo(56)
      }
      commentsSendButton.snp.makeConstraints { make in
         make.centerY.equalToSuperview()
         make.trailing.equalTo(commentsInputBackView.safeAreaLayoutGuide).inset(16)
         make.leading.equalTo(commentsInput.snp.trailing).offset(16)
         make.height.equalTo(56)
      }
   }
   
   override func setUI() {
      super.setUI()
      
      contentTitle.numberOfLines = 0
      contentBody.numberOfLines = 0
      contentCommentsEmptyView.contentMode = .center
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
   }
   
   func bindContents(for output: PostsOutput) {
      contentTitle.text = "Q. " + output.title
      contentBody.text = output.content
      
      if output.comments.isEmpty {
         bindEmptyView()
      } else {
         bindCommentsTableView()
      }
   }
   
   private func bindEmptyView() {
      addSubview(contentCommentsEmptyView)
      contentCommentsTable.removeFromSuperview()
      contentCommentsEmptyView.snp.makeConstraints { make in
         make.top.equalTo(contentBodyDivider.snp.bottom).offset(16)
         make.horizontalEdges.equalTo(self.safeAreaLayoutGuide)
         make.bottom.equalTo(commentsInputBackView.snp.top).offset(-8)
      }
   }
   
   private func bindCommentsTableView() {
      addSubviews(contentCommentsTable)
      contentCommentsEmptyView.removeFromSuperview()
      contentCommentsTable.snp.makeConstraints { make in
         make.top.equalTo(contentBodyDivider.snp.bottom).offset(16)
         make.horizontalEdges.equalTo(self.safeAreaLayoutGuide)
         make.bottom.equalTo(commentsInputBackView.snp.top).offset(-8)
      }
      contentCommentsTable.delegate = nil
      contentCommentsTable.dataSource = nil
      contentCommentsTable.register(BaseCommentsView.self, forCellReuseIdentifier: BaseCommentsView.id)
      contentCommentsTable.estimatedRowHeight = 150
      contentCommentsTable.rowHeight = UITableView.automaticDimension
   }
}
