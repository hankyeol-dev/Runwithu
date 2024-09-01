//
//  RunningGroupPostStack.swift
//  runwithu
//
//  Created by 강한결 on 9/1/24.
//

import UIKit

import SnapKit
import RxSwift
import RxCocoa

final class RunningGroupPostStack: BaseView {
   private let disposeBag = DisposeBag()
   private let stackTitleLabel = BaseLabel(for: "", font: .systemFont(ofSize: 16, weight: .semibold))
   let seeMorebutton = UIButton()
   let postTable = UITableView()
   
   convenience init(_ title: String) {
      self.init(frame: .zero)
      stackTitleLabel.bindText(title)
   }
   
   override func setSubviews() {
      super.setSubviews()
      addSubviews(stackTitleLabel, seeMorebutton, postTable)
   }
   
   override func setLayout() {
      super.setLayout()
      stackTitleLabel.snp.makeConstraints { make in
         make.top.equalTo(safeAreaLayoutGuide).inset(12)
         make.leading.equalTo(safeAreaLayoutGuide).inset(16)
         make.width.equalTo(200)
         make.height.equalTo(20)
      }
      seeMorebutton.snp.makeConstraints { make in
         make.top.equalTo(safeAreaLayoutGuide).inset(8)
         make.trailing.equalTo(safeAreaLayoutGuide).inset(16)
         make.height.equalTo(20)
      }
      postTable.snp.makeConstraints { make in
         make.top.equalTo(stackTitleLabel.snp.bottom).offset(12)
         make.horizontalEdges.bottom.equalTo(safeAreaLayoutGuide).inset(16)
      }
   }
   
   override func setUI() {
      super.setUI()
      backgroundColor = .white
      seeMorebutton.setTitle("더 보기 >", for: .normal)
      seeMorebutton.setTitleColor(.darkGray, for: .normal)
      seeMorebutton.titleLabel?.font = .systemFont(ofSize: 15)
      postTable.backgroundColor = .none
      postTable.separatorInset = .init(top: 2, left: 0, bottom: 2, right: 0)
      postTable.separatorColor = .darkGray.withAlphaComponent(0.5)
      postTable.rowHeight = 80
      postTable.register(RunningGroupPostStackCell.self, forCellReuseIdentifier: RunningGroupPostStackCell.id)
   }
   
   func bindPostTable(for posts: [PostsOutput]) {
      postTable.delegate = nil
      postTable.dataSource = nil
      
      Observable.just(posts)
         .bind(to: postTable.rx.items(
            cellIdentifier: RunningGroupPostStackCell.id,
            cellType: RunningGroupPostStackCell.self)
         ) { row, post, cell in
            cell.bindView(for: post)
         }
         .disposed(by: disposeBag)
   }
}

final class RunningGroupPostStackCell: BaseTableViewCell {
   private let cellType = BaseLabel(for: "", font: .systemFont(ofSize: 13), color: .systemGray)
   private let cellTitle = BaseLabel(for: "", font: .systemFont(ofSize: 15, weight: .medium))
   private let cellContent = BaseLabel(for: "", font: .systemFont(ofSize: 13), color: .darkGray)
   
   override func setSubviews() {
      super.setSubviews()
      contentView.addSubviews(cellType, cellTitle, cellContent)
   }
   
   override func setLayout() {
      super.setLayout()
      let guide = contentView.safeAreaLayoutGuide
      cellType.snp.makeConstraints { make in
         make.top.equalTo(guide).inset(8)
         make.horizontalEdges.equalTo(guide).inset(12)
      }
      cellTitle.snp.makeConstraints { make in
         make.top.equalTo(cellType.snp.bottom).offset(8)
         make.horizontalEdges.equalTo(guide).inset(12)
      }
      cellContent.snp.makeConstraints { make in
         make.top.equalTo(cellTitle.snp.bottom).offset(4)
         make.horizontalEdges.equalTo(guide).inset(12)
      }
   }
   
   func bindView(for post: PostsOutput) {
      cellTitle.bindText(post.title)
      cellContent.bindText(post.content)
      
      if let content1 = post.content1 {
         switch content1 {
         case PostsCommunityType.epilogues.rawValue:
            cellType.bindText(PostsCommunityType.epilogues.byDetailLabel)
         case PostsCommunityType.product_epilogues.rawValue:
            cellType.bindText(PostsCommunityType.product_epilogues.byDetailLabel)
         case PostsCommunityType.qnas.rawValue:
            cellType.bindText(PostsCommunityType.qnas.byDetailLabel)
         default:
            cellType.bindText("")
         }
      }
   }
}
