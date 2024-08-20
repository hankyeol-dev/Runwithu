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
   
   override func viewWillAppear(_ animated: Bool) {
      super.viewWillAppear(animated)
      
      setGoBackButton(by: .darkGray, imageName: "xmark")
      title = "러닝 그룹 생성"
   }
   
   override func viewDidLoad() {
      super.viewDidLoad()
   }
   
   override func bindViewAtDidLoad() {
      super.bindViewAtDidLoad()
      
      baseView
         .groupNameField
         .inputField
         .rx.text.orEmpty
         .bind(with: self) { vc, text in
            if !text.isEmpty {
               let trimmedText = vc.trimmingText(for: text, index: 15)
               vc.baseView.groupNameField.inputField.text = trimmedText
               vc.baseView.previewView.bindTitleView(for: trimmedText)
               vc.baseView.groupNameField.additionToCountingLabel(for: "\(trimmedText.count) / 15")
            }
         }
         .disposed(by: disposeBag)
      
      baseView
         .groupEntryLimitField
         .inputField
         .rx.text.orEmpty
         .bind(with: self) { vc, text in
            if !text.isEmpty {
               let count = vc.countingEntry(for: text)
               vc.baseView.groupEntryLimitField.inputField.text = count
               vc.baseView.previewView.bindEntryLimitView(for: "러닝 인원 - \(count)")
               vc.baseView.groupEntryLimitField.inputIndicatingLabel.text = "최대 인원은 99명입니다."
            }
         }
         .disposed(by: disposeBag)
      
      baseView
         .groupDescriptionField
         .inputTextView
         .rx.text.orEmpty
         .bind(with: self) { vc, text in
            if !text.isEmpty {
               let trimmedText = vc.trimmingText(for: text, index: 300)
               vc.baseView.groupDescriptionField.inputTextView.text = trimmedText
               vc.baseView.groupDescriptionField.inputCountLabel.text = "\(trimmedText.count) / 300"
            }
         }
         .disposed(by: disposeBag)
      
      baseView
         .groupSpotField.inputField
         .rx.text.orEmpty
         .bind(with: self) { vc, text in
            if !text.isEmpty {
               vc.baseView.groupSpotField.inputIndicatingLabel.text = "주요한 그룹 러닝 지역만 적어주세요."
               let trimmedText = vc.trimmingText(for: text, index: 15)
               vc.baseView.groupSpotField.inputField.text = trimmedText
               vc.baseView.groupSpotField.additionToCountingLabel(for: "\(trimmedText.count) / 15")
               vc.baseView.previewView.bindSpotView(for: "러닝 지역 - \(trimmedText)")
            }
         }
         .disposed(by: disposeBag)
      
      baseView
         .groupHardType.inputField.rx.text.orEmpty
         .bind(with: self) { vc, text in
            if !text.isEmpty {
               vc.baseView.previewView.bindHardTypeView(for: "러닝 난도 - \(text)")
            }
         }
         .disposed(by: disposeBag)
   }
   
   private func trimmingText(for text: String, index: Int) -> String {
      if text.count >= index {
         let index = text.index(text.startIndex, offsetBy: index)
         return String(text[..<index])
      } else {
         return text
      }
   }
   
   private func countingEntry(for text: String) -> String {
      if let count = Int(text), count >= 100 {
         return "99"
      } else {
         return text
      }
   }
}
