//
//  ProducteDetailViewController.swift
//  runwithu
//
//  Created by 강한결 on 8/30/24.
//

import UIKit

import RxSwift
import RxCocoa
import RxGesture

final class ProducteDetailViewController: BaseViewController<ProductDetailView, ProductDetailViewModel> {
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
      let input = ProductDetailViewModel.Input(
         didLoadInput: didLoadInput,
         commentSendButtonTapped: commentSendButtonTapped
      )
      let output = viewModel.transform(for: input)
      
      /// bind input
      baseView.commentsSendButton
         .rx.tap
         .bind(with: self) { vc, _ in
            if let comment = vc.baseView.commentsInput.text {
               if !comment.isEmpty {
                  commentSendButtonTapped.onNext(comment)
                  vc.baseView.commentsInput.text = ""
               }
            }
         }
         .disposed(by: disposeBag)
      
      /// bind output
      output.didLoatOutput
         .asDriver(onErrorJustReturn: AppEnvironment.drivedPostObject)
         .drive(with: self) { vc, detail in
            vc.baseView.bindView(for: detail)
            vc.baseView.imageCollection.delegate = nil
            vc.baseView.imageCollection.dataSource = nil
           
            Observable.just(detail.files)
               .bind(to: vc.baseView.imageCollection.rx.items(cellIdentifier: EpilogueImageCollectionCell.id, cellType: EpilogueImageCollectionCell.self)) { _, image, cell in
                  cell.bindView(for: image)
               }
               .disposed(by: vc.disposeBag)
         }
         .disposed(by: disposeBag)
      
      output.commentsOutput
         .asDriver(onErrorJustReturn: [])
         .drive(with: self) { vc, comments in
            vc.baseView.commentsTable.delegate = nil
            vc.baseView.commentsTable.dataSource = nil
            Observable.just(comments)
               .bind(to: vc.baseView.commentsTable.rx.items(
                  cellIdentifier: BaseCommentsView.id,
                  cellType: BaseCommentsView.self)
               ) { _, comment, cell in
                  cell.bindView(for: comment)
               }
               .disposed(by: vc.disposeBag)
         }
         .disposed(by: disposeBag)
   }
}
