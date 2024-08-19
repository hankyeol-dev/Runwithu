//
//  InputWithTitleView.swift
//  runwithu
//
//  Created by 강한결 on 8/16/24.
//

import UIKit

import PinLayout
import FlexLayout

final class InputWithTitleView: BaseView {
   let flexBox = UIView()
   let inputTitle = BaseLabel(for: "", font: .systemFont(ofSize: 13))
   let inputField = BaseTextFieldWithLine()
   let inputIndicatingLabel = BaseLabel(for: "", font: .systemFont(ofSize: 10))

   convenience init(label: String, placeHolder: String, keyboardType: UIKeyboardType = .default) {
      self.init(frame: .zero)
      inputTitle.text = label
      inputField.placeholder = placeHolder
      inputField.keyboardType = keyboardType
   }

   override func setSubviews() {
      super.setSubviews()
      
      addSubview(flexBox)
      flexBox.addSubview(inputTitle)
      flexBox.addSubview(inputField)
      flexBox.addSubview(inputIndicatingLabel)
   }
   
   override func setLayout() {
      super.setLayout()
      
      flexBox.pin
         .width(100%)
      
      flexBox.flex
         .direction(.column)
         .padding(16)
         .define { flex in
            flex.addItem(inputTitle)
            flex.addItem(inputField)
               .width(100%)
               .height(44)
               .marginBottom(4)
            flex.addItem(inputIndicatingLabel)
               .height(16)
         }
      
      flexBox.flex.layout(mode: .adjustHeight)
   }
   
   func setIndicatingLabelError(for text: String) {
      inputIndicatingLabel.text = text
      inputIndicatingLabel.textColor = .systemRed
      inputIndicatingLabel.font = .systemFont(ofSize: 12, weight: .semibold)
   }
}
