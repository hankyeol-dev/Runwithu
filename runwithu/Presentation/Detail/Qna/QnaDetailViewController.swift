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
         .asDriver(onErrorJustReturn: [])
         .drive(with: self) { vc, comments in
            vc.baseView.contentCommentsTable.delegate = nil
            vc.baseView.contentCommentsTable.dataSource = nil
            Observable.just(comments)
               .bind(to: vc.baseView.contentCommentsTable.rx.items(
                  cellIdentifier: BaseCommentsView.id,
                  cellType: BaseCommentsView.self)) { row, item, cell in
                     cell.bindView(for: item)
                  }
                  .disposed(by: vc.disposeBag)
         }.disposed(by: disposeBag)
      
      output.errorEmitter
         .asDriver(onErrorJustReturn: .dataNotFound)
         .drive(with: self) { vc, errors in
            if errors == .needToLogin {
               vc.dismissToLoginVC()
            }
            
            if errors == .dataNotFound {
               vc.baseView.displayToast(for: "QnA를 불러오지 못했어요.", isError: true, duration: 1.0)
               DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                  vc.navigationController?.popViewController(animated: true)
               }
            }
            
            if errors == .writeCommentError {
               vc.baseView.displayToast(for: "댓글 작성에 문제가 발생했어요.", isError: true, duration: 1.5)
            }
         }
         .disposed(by: disposeBag)
   }
}

extension QnaDetailViewController {
   private func bindCreatorView(_ output: PostsOutput) {
      
      baseView.creatorView.bindCreatedDate(date: output.createdAt.formattedCreatedAt())
      
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
