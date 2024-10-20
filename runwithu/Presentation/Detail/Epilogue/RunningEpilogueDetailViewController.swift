//
//  RunningEpilogueDetailViewController.swift
//  runwithu
//
//  Created by 강한결 on 8/27/24.
//

import UIKit

import RxSwift
import RxCocoa

final class RunningEpilogueDetailViewController: BaseViewController<RunningEpilogueDetailView, RunningEpilogueDetailViewModel> {
   private let didLoadInput = PublishSubject<Void>()
   
   override func loadView() {
      view = baseView
   }
   
   override func viewDidLoad() {
      super.viewDidLoad()
   }
   
   override func viewWillAppear(_ animated: Bool) {
      super.viewWillAppear(animated)
      didLoadInput.onNext(())
      setGoBackButton(by: .darkGray, imageName: "chevron.left")
   }
   
   override func bindViewAtDidLoad() {
      super.bindViewAtDidLoad()
      
      let commentSendButtonTapped = PublishSubject<String>()
      let input = RunningEpilogueDetailViewModel.Input(
         didLoadInput: didLoadInput,
         commentSendButtonTapped: commentSendButtonTapped
      )
      let output = viewModel.transform(for: input)
      
      baseView.commentsSendButton.rx.tap
         .bind(with: self) { vc, _ in
            if let comment = vc.baseView.commentsInput.text {
               if !comment.isEmpty {
                  commentSendButtonTapped.onNext(comment)
                  vc.baseView.commentsInput.text = ""
               }
            }
         }
         .disposed(by: disposeBag)
      
      baseView.creatorView.creatorImage.rx.tapGesture()
         .skip(1)
         .bind(with: self) { vc, _ in
            print("tapped")
         }
         .disposed(by: disposeBag)
      
      output.didLoadOutput
         .bind(with: self) { vc, epilogue in
            vc.baseView.creatorView.bindViews(for: epilogue.creator, createdAt: epilogue.createdAt)
            vc.baseView.bindContents(for: epilogue)
         }
         .disposed(by: disposeBag)
      
      output.didLoadImageOutput
         .asDriver(onErrorJustReturn: [])
         .drive(with: self) { vc, images in
            vc.baseView.imageCollection.delegate = nil
            vc.baseView.imageCollection.dataSource = nil
            Observable.just(images)
               .bind(to: vc.baseView.imageCollection.rx.items(cellIdentifier: EpilogueImageCollectionCell.id, cellType: EpilogueImageCollectionCell.self)) { _, image, cell in
                  cell.bindView(for: image)
               }
               .disposed(by: vc.disposeBag)
         }
         .disposed(by: disposeBag)
      
      output.didLoadCommentsOutput
         .asDriver(onErrorJustReturn: [])
         .drive(with: self) { vc, comments in
            vc.baseView.commentsTable.delegate = nil
            vc.baseView.commentsTable.dataSource = nil
            Observable.just(comments)
               .bind(to: vc.baseView.commentsTable.rx.items(cellIdentifier: BaseCommentsView.id, cellType: BaseCommentsView.self)) { _, comment, cell in
                  cell.bindView(for: comment)
               }
               .disposed(by: vc.disposeBag)
         }
         .disposed(by: disposeBag)
      
      output.errorOutput
         .asDriver(onErrorJustReturn: .dataNotFound)
         .drive(with: self) { vc, errors in
            if errors == .needToLogin {
               vc.dismissToLoginVC()
               return
            }
            
            if errors == .dataNotFound {
               vc.baseView.displayToast(for: "러닝 일지를 불러오지 못했어요.", isError: true, duration: 2.0)
            }
            
            if errors == .writeCommentError {
               vc.baseView.displayToast(for: "댓글 작성에 문제가 발생했어요.", isError: true, duration: 2.0)
            }
         }
         .disposed(by: disposeBag)
   }
}
