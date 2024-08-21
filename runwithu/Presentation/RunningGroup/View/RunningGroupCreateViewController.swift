//
//  RunningGroupCreateViewController.swift
//  runwithu
//
//  Created by 강한결 on 8/19/24.
//

import UIKit

import RxSwift
import RxCocoa

final class RunningGroupCreateViewController: BaseViewController<RunningGroupCreateView, RunningGroupCreateViewModel> {
   
   override func loadView() {
      view = baseView
   }
     
   override func viewDidLoad() {
      super.viewDidLoad()
   }
   
   override func bindViewAtDidLoad() {
      super.bindViewAtDidLoad()
      
      let groupName = PublishSubject<String>()
      let groupEntryLimit = PublishSubject<String>()
      let groupDescription = PublishSubject<String>()
      let groupSpot = PublishSubject<String>()
      let groupHardType = PublishSubject<String>()
      let createButtonTapped = PublishSubject<Void>()
      
      let input = RunningGroupCreateViewModel.Input(
         groupName: groupName,
         groupEntryLimit: groupEntryLimit,
         groupDescription: groupDescription,
         groupSpot: groupSpot,
         groupHardType: groupHardType,
         createButtonTapped: createButtonTapped
      )
      let output = viewModel.transform(for: input)
      
      baseView.headerCloseButton.rx.tap
         .bind(with: self) { vc, _ in
            vc.dismiss(animated: true)
         }
         .disposed(by: disposeBag)
      
      bindInputViewText(
         for: baseView.groupNameField.inputField,
         to: groupName
      )
      
      bindInputViewText(
         for: baseView.groupEntryLimitField.inputField,
         to: groupEntryLimit
      )
         
      bindInputViewText(
         for: baseView.groupSpotField.inputField,
         to: groupSpot
      )
      
      bindInputViewText(
         for: baseView.groupHardType.inputField,
         to: groupHardType
      )
      
      baseView
         .groupDescriptionField
         .inputTextView
         .rx.text.orEmpty
         .bind(with: self) { vc, text in
            if !text.isEmpty {
               groupDescription.onNext(text)
            }
         }
         .disposed(by: disposeBag)
      
      baseView
         .createButton.rx.tap
         .bind(with: self) { _, _ in
            createButtonTapped.onNext(())
         }
         .disposed(by: disposeBag)
      
      
      // MARK: Output bind
      output.name
         .bind(with: self) { vc, name in
            vc.baseView.groupNameField.inputField.text = name
            vc.baseView.groupNameField.bindToCountLabel(for: "\(name.count) / 15")
            vc.baseView.previewView.bindTitleView(for: name)
         }
         .disposed(by: disposeBag)
      
      output.entryLimit
         .bind(with: self) { vc, limit in
            vc.baseView.groupEntryLimitField.inputField.text = limit
            vc.baseView.groupEntryLimitField.bindToIndicatingLabel(for: "최대 인원은 99명입니다.")
            vc.baseView.previewView.bindEntryLimitView(for: "러닝 인원 - \(limit)명")
         }
         .disposed(by: disposeBag)
      
      output.description
         .bind(with: self) { vc, descript in
            vc.baseView.groupDescriptionField.inputTextView.text = descript
            vc.baseView.groupDescriptionField.inputCountLabel.text = "\(descript.count) / 300"
         }
         .disposed(by: disposeBag)
      
      output.spot
         .bind(with: self) { vc, spot in
            vc.baseView.groupSpotField.inputField.text = spot
            vc.baseView.groupSpotField.bindToIndicatingLabel(for: "주요 러닝 지역만 적어주세요.")
            vc.baseView.groupSpotField.bindToCountLabel(for: "\(spot.count) / 15")
            vc.baseView.previewView.bindSpotView(for: "러닝 지역 - \(spot)")
         }
         .disposed(by: disposeBag)
      
      output.hardType
         .bind(with: self) { vc, hardType in
            vc.baseView.previewView.bindHardTypeView(for: "러닝 난도 - \(hardType)")
         }
         .disposed(by: disposeBag)
      
      output.createError
         .bind(with: self) { vc, errorMessage in
            vc.baseView.displayToast(for: errorMessage, isError: true, duration: 1)
         }
         .disposed(by: disposeBag)
      
      output.createSuccess
         .bind(with: self) { vc, successMessage in
            vc.baseView.displayToast(for: successMessage, isError: false, duration: 1)
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
               vc.dismiss(animated: true)
            }
         }
         .disposed(by: disposeBag)
   }
}

extension RunningGroupCreateViewController {
   private func bindInputViewText(for field: BaseTextFieldRounded, to emitter: PublishSubject<String>) {
      field.rx.text.orEmpty
         .bind(with: self) { vc, text in
            if !text.isEmpty {
               emitter.onNext(text)
            }
         }
         .disposed(by: disposeBag)
   }
}
