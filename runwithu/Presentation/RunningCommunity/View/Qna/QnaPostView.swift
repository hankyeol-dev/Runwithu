//
//  QnaPostView.swift
//  runwithu
//
//  Created by 강한결 on 8/25/24.
//

import UIKit

import PinLayout
import FlexLayout

final class QnaPostView: BaseView, BaseViewProtocol {
   let contentViewPlaceHolder = "러닝과 관련된 궁금한 사항을 자세히 남겨주세요!"
   let scrollView = BaseScrollViewWithCloseButton(
      with: "러닝 QnA 작성",
      isAdditionButton: true,
      additionButtonTitle: "작성"
   )
   
   private let requiredRectangle = RectangleView(backColor: .white, radius: 0)
   let qnaTypePicker = RoundedInputViewWithTitle(
      label: "다른 러너의 도움이 필요한 영역을 선택해주세요.",
      placeHolder: "QnA 유형",
      labelSize: 14
   )
   let titleInput = UITextField()
   let contentInput = UITextView()
   
   override func setSubviews() {
      super.setSubviews()
      addSubviews(scrollView)
   }
   
   override func layoutSubviews() {
      super.layoutSubviews()
      
      scrollView.pin.all(self.pin.safeArea)
      
      scrollView.flexHandler = { [weak self] flex in
         guard let self else { return }
         
         flex.addItem(self.requiredRectangle)
            .width(100%)
            .padding(4)
            .direction(.column)
            .define{ flex in
               flex.addItem(self.qnaTypePicker)
                  .width(50%)
               
               flex.addItem(self.titleInput)
                  .width(100%)
                  .height(44)
                  .marginBottom(12)
               
               flex.addItem(self.contentInput)
                  .width(100%)
                  .height(350)
                  .marginBottom(12)
               
            }
            .marginBottom(20)
      }
   }
   override func setUI() {
      super.setUI()
      
      titleInput.placeholder = "궁금한 내용에 제목을 붙여보세요. :D"
      titleInput.tintColor = .darkGray
      titleInput.font = .systemFont(ofSize: 15)
      titleInput.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 4, height: 44))
      titleInput.leftViewMode = .always
      contentInput.tintColor = .darkGray
      contentInput.font = .systemFont(ofSize: 15)
      contentInput.backgroundColor = .none
      contentInput.delegate = self
      contentInput.textColor = .systemGray3
      contentInput.text = contentViewPlaceHolder
      qnaTypePicker.bindToInputPickerView(
         for: RunningQnaType.allCases.map { $0.byKoreanQnaCase })
      qnaTypePicker.hideStateLabel()
   }
}

extension QnaPostView: UITextViewDelegate {
   func textViewDidBeginEditing(_ textView: UITextView) {
      if textView.textColor == .systemGray3 {
         textView.text = nil
         textView.textColor = .black
      }
   }
   
   func textViewDidEndEditing(_ textView: UITextView) {
      if textView.text.isEmpty {
         textView.text = contentViewPlaceHolder
         textView.textColor = .systemGray3
      }
   }
}
