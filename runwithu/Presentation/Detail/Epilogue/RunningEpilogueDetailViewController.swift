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
      didLoadInput.onNext(())
   }
   
   override func viewWillAppear(_ animated: Bool) {
      super.viewWillAppear(animated)
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
      
      output.didLoadOutput
         .bind(with: self) { vc, epilogue in
            vc.baseView.creatorView.bindViews(for: epilogue.creator, createdAt: epilogue.createdAt)
            vc.baseView.bindContents(for: epilogue)
         }
         .disposed(by: disposeBag)
      
      output.didLoadImageOutput
         .subscribe(on: MainScheduler.asyncInstance)
         .bind(to: baseView.imageCollection.rx.items(
            cellIdentifier: EpilogueImageCollectionCell.id,
            cellType: EpilogueImageCollectionCell.self)) { _, image, cell in
               cell.bindView(for: image)
            }
            .disposed(by: disposeBag)
      
      output.didLoadCommentsOutput
         .subscribe(on: MainScheduler.asyncInstance)
         .bind(to: baseView.commentsTable.rx.items(
            cellIdentifier: BaseCommentsView.id, cellType: BaseCommentsView.self)) { _, comments, cell in
               cell.bindView(for: comments)
            }
            .disposed(by: disposeBag)
   }
}
