//
//  RoundedInputViewWithTitle.swift
//  runwithu
//
//  Created by 강한결 on 8/19/24.
//

import UIKit

import PinLayout
import FlexLayout

final class RoundedInputViewWithTitle: BaseView {
   private let flexBox = UIView()
   private let inputTitle = BaseLabel(for: "", font: .systemFont(ofSize: 15))
   let inputField = BaseTextFieldRounded("")
   let inputIndicatingLabel = BaseLabel(for: "", font: .systemFont(ofSize: 12))
   let inputCountLabel = BaseLabel(for: "", font: .systemFont(ofSize: 12), color: .darkGray)
   
   convenience init(
      label: String,
      placeHolder: String,
      keyboardType: UIKeyboardType = .default
   ) {
      self.init(frame: .zero)
      inputTitle.text = label
      inputField.placeholder = placeHolder
      inputField.keyboardType = keyboardType
   }
   
   override func setSubviews() {
      super.setSubviews()
      
      addSubview(flexBox)
      [inputTitle, inputField, inputIndicatingLabel, inputCountLabel].forEach {
         flexBox.addSubview($0)
      }
   }
   
   override func setLayout() {
      super.setLayout()
      
      flexBox.pin
         .width(100%)
      
      flexBox.flex
         .direction(.column)
         .define { flex in
            flex.addItem(inputTitle)
               .marginBottom(8)
            flex.addItem(inputField)
               .width(100%)
               .height(44)
               .marginBottom(8)
            
            flex.addItem()
               .direction(.row)
               .justifyContent(.spaceBetween)
               .width(100%)
               .height(20)
               .define { flex in
                  flex.addItem(inputIndicatingLabel)
                     .width(80%)
                     .height(100%)
                     .alignSelf(.start)
                     .marginLeft(4)
                  flex.addItem(inputCountLabel)
                     .width(20%)
                     .height(100%)
                     .alignSelf(.end)
               }
         }
      
      flexBox.flex.layout(mode: .adjustHeight)
   }
   
   override func setUI() {
      super.setUI()
      inputIndicatingLabel.textAlignment = .left
      inputCountLabel.textAlignment = .right
   }
   
   func setErrorState(for text: String) {
      inputIndicatingLabel.text = text
      inputIndicatingLabel.textColor = .systemRed
      inputIndicatingLabel.font = .systemFont(ofSize: 12, weight: .semibold)
      inputField.layer.borderColor = UIColor.systemRed.cgColor
   }
   
   func hideStateLabel() {
      inputIndicatingLabel.isHidden = true
      inputCountLabel.isHidden = true
   }
   
   func bindToCountLabel(for text: String) {
      inputCountLabel.text = text
   }
   
   func bindToIndicatingLabel(for text: String) {
      inputIndicatingLabel.text = text
   }
}

