//
//  TestViewController.swift
//  runwithu
//
//  Created by 강한결 on 8/22/24.
//

import UIKit

import SnapKit
import RxSwift
import RxCocoa

final class TestViewController: UIViewController {
   let disposeBag = DisposeBag()
   let data: [PostsOutput] = [
      
      .init(post_id: "asdf", product_id: "asdfasdf", title: "타이틀은 적당히 길어줬으면 합니다..핵심은 이미지 이니까요..", content: "콘텐츠도 적당히 또 적당히 그리고 적당히 길어줬으면 합니다..핵심은 이미지 이니까요..", content1: "나이키", content2: "러닝화", content3: nil, content4: nil, content5: nil, createdAt: "2024-08-27", creator: .init(user_id: AppEnvironment.demoUserId, nick: "기깔나는 이름", profileImage: "uploads/profiles/1724649445894.png"), files: ["uploads/posts/postImage_1724849001136", "uploads/posts/postImage_1724849001136", "uploads/posts/postImage_1724849001136"], likes: [], likes2: [], hashTags: [], comments: []),
      .init(post_id: "asdf", product_id: "asdfasdf", title: "타이틀은 적당히 길어줬으면 합니다..핵심은 이미지 이니까요..", content: "콘텐츠도 적당히 또 적당히 그리고 적당히 길어줬으면 합니다..핵심은 이미지 이니까요..", content1: "나이키", content2: "러닝화", content3: nil, content4: nil, content5: nil, createdAt: "2024-08-27", creator: .init(user_id: AppEnvironment.demoUserId, nick: "기깔나는 이름", profileImage: "uploads/profiles/1724649445894.png"), files: ["uploads/posts/postImage_1724849001136", "uploads/posts/postImage_1724849001136"], likes: [], likes2: [], hashTags: [], comments: []),
      .init(post_id: "asdf", product_id: "asdfasdf", title: "타이틀은 적당히 길어줬으면 합니다..핵심은 이미지 이니까요..", content: "콘텐츠도 적당히 또 적당히 그리고 적당히 길어줬으면 합니다..핵심은 이미지 이니까요..", content1: "나이키", content2: "러닝화", content3: nil, content4: nil, content5: nil, createdAt: "2024-08-27", creator: .init(user_id: AppEnvironment.demoUserId, nick: "기깔나는 이름", profileImage: "uploads/profiles/1724649445894.png"), files: ["uploads/posts/postImage_1724849001136"], likes: [], likes2: [], hashTags: [], comments: []),
      .init(post_id: "asdf", product_id: "asdfasdf", title: "타이틀은 적당히 길어줬으면 합니다..핵심은 이미지 이니까요..", content: "콘텐츠도 적당히 또 적당히 그리고 적당히 길어줬으면 합니다..핵심은 이미지 이니까요..", content1: "나이키", content2: "러닝화", content3: nil, content4: nil, content5: nil, createdAt: "2024-08-27", creator: .init(user_id: AppEnvironment.demoUserId, nick: "기깔나는 이름", profileImage: "uploads/profiles/1724649445894.png"), files: [], likes: [], likes2: [], hashTags: [], comments: [])
   ]
   
   private let table = UITableView()
   
   override func viewDidLoad() {
      super.viewDidLoad()
      
      view.backgroundColor = .white
      
      view.addSubview(table)
      
      table.snp.makeConstraints { make in
         make.edges.equalTo(view.safeAreaLayoutGuide)
      }
      table.register(EpiloguePostCell.self, forCellReuseIdentifier: EpiloguePostCell.id)
      table.delegate = nil
      table.dataSource = nil
      table.rowHeight = UITableView.automaticDimension
      
      Observable.just(data)
         .bind(to: table.rx.items(cellIdentifier: EpiloguePostCell.id, cellType: EpiloguePostCell.self)) { row, item, cell in
            cell.bindView(for: item)
         }
         .disposed(by: disposeBag)
   }
}
