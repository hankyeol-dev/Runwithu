//
//  QnaPostViewController.swift
//  runwithu
//
//  Created by 강한결 on 8/25/24.
//

import UIKit

import RxSwift
import RxCocoa

final class QnaPostViewController: BaseViewController<QnaPostView, QnaPostViewModel> {
   
   var willDisappearHanlder: ((String) -> Void)?
   
   override func loadView() {
      view = baseView
   }
   
   override func viewDidLoad() {
      super.viewDidLoad()
   }
   
   override func viewDidDisappear(_ animated: Bool) {
      super.viewDidDisappear(animated)
      let qnaPostId = viewModel.getGeneratedQnaPostId()
      willDisappearHanlder?(qnaPostId)
   }
   
   override func bindViewAtDidLoad() {
      super.bindViewAtDidLoad()
      
      baseView.scrollView.headerCloseButton.rx.tap
         .bind(with: self) { vc, _ in
            vc.dismiss(animated: true)
         }
         .disposed(by: disposeBag)
      
      let qnaTypePickerInput = PublishSubject<String>()
      let titleInput = PublishSubject<String>()
      let contentInput = PublishSubject<String>()
      let createButtonTapped = PublishSubject<Void>()
      
      let input = QnaPostViewModel.Input(
         qnaTypePickerInput: qnaTypePickerInput,
         titleInput: titleInput,
         contentInput: contentInput,
         createButtonTapped: createButtonTapped
      )
      let output = viewModel.transform(for: input)
      
      bindingTextToEmitter(
         for: baseView.qnaTypePicker.inputField.rx.text.orEmpty,
         emitter: qnaTypePickerInput)
      bindingTextToEmitter(
         for: baseView.titleInput.rx.text.orEmpty,
         emitter: titleInput)
      bindingTextToEmitter(
         for: baseView.contentInput.rx.text.orEmpty,
         emitter: contentInput)
      
      baseView.scrollView.headerAdditionButton
         .rx.tap
         .bind(to: createButtonTapped)
         .disposed(by: disposeBag)
      
      output.successEmitter
         .asDriver(onErrorJustReturn: ())
         .drive(with: self) { vc, _ in
            vc.dismiss(animated: true)
         }
         .disposed(by: disposeBag)
      
      output.errorEmitter
         .asDriver(onErrorJustReturn: "")
         .drive(with: self) { vc, errorMessage in
            BaseAlertBuilder(viewController: vc)
               .setTitle(for: "포스트 작성에 문제가 있어요.")
               .setMessage(for: errorMessage)
               .setActions(by: .black, for: "확인")
               .displayAlert()
         }
         .disposed(by: disposeBag)
   }
}
