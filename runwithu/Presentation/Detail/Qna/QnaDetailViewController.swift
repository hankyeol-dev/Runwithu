//
//  QnaDetailViewController.swift
//  runwithu
//
//  Created by 강한결 on 8/25/24.
//

import UIKit

import RxSwift
import RxCocoa

final class QnaDetailViewController: BaseViewController<QnaDetailView, QnaDetailViewModel> {
   private let didLoadInput = PublishSubject<Void>()
   
   
   override func loadView() {
      view = baseView
   }
   
   override func viewDidLoad() {
      super.viewDidLoad()
      
      didLoadInput.onNext(())
   }
   
   override func viewWillAppear(_ animated: Bool) {
      super.viewWillAppear(animated)
      
      title = "런윗유 QnA"
      setGoBackButton(by: .darkGray, imageName: "chevron.left")
   }
   
   override func bindViewAtDidLoad() {
      let commentsSendButtonTapped = PublishSubject<String>()
      
      let input = QnaDetailViewModel.Input(
         didLoadInput: didLoadInput,
         commentsSendButtonTapped: commentsSendButtonTapped
      )
      let output = viewModel.transform(for: input)
      
      baseView.commentsSendButton.rx.tap
         .bind(with: self) { vc, _ in
            if let comments = vc.baseView.commentsInput.text {
               if !comments.isEmpty {
                  commentsSendButtonTapped.onNext(comments)
                  vc.baseView.commentsInput.text = ""
               }
            }
         }
         .disposed(by: disposeBag)
      
      output.didLoadOutput
         .bind(with: self) { vc, qna in
            DispatchQueue.main.async {
               vc.baseView.creatorView.bindViews(
                  for: qna.creator, createdAt: qna.createdAt)
               vc.bindContentsView(qna)
            }
         }
         .disposed(by: disposeBag)
      
      output.commentsEmitter
         .bind(to: baseView.contentCommentsTable.rx.items(
            cellIdentifier: BaseCommentsView.id,
            cellType: BaseCommentsView.self)) { row, item, cell in
               DispatchQueue.main.async {
                  cell.bindView(for: item)
               }
            }
            .disposed(by: disposeBag)
   }
}

extension QnaDetailViewController {
   private func bindCreatorView(_ output: PostsOutput) {
      if let compare = output.createdAt.calcBetweenDayAndHour() {
         var compareString = ""
         if let day = compare.day, day != 0 {
            compareString += "\(day)일 "
         }
         
         if let hour = compare.hour {
            compareString += "\(hour)시간 "
         }
         compareString += "전"
         
         baseView.creatorView.bindCreatedDate(date: compareString)
      }
      
      
      if let profileURL = output.creator.profileImage {
         baseView.creatorView.bindView(imageURL: profileURL, name: output.creator.nick)
      } else {
         baseView.creatorView.bindView(image: .userSelected, name: output.creator.nick)
      }
   }
   private func bindContentsView(_ output: PostsOutput) {
      baseView.bindContents(for: output)
   }
}
