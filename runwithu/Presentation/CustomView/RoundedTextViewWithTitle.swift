//
//  RoundedTextViewWithTitle.swift
//  runwithu
//
//  Created by 강한결 on 8/20/24.
//

import UIKit

import PinLayout
import FlexLayout

final class RoundedTextViewWithTitle: BaseView {
   private let flexBox = UIView()
   private let inputTitle = BaseLabel(for: "", font: .systemFont(ofSize: 18))
   let inputTextView = UITextView()
   let inputCountLabel = BaseLabel(for: "", font: .systemFont(ofSize: 12))
   
   convenience init(title: String) {
      self.init(frame: .zero)
      
      inputTitle.text = title
   }
   
   override func setSubviews() {
      super.setSubviews()
      
      addSubview(flexBox)
      [inputTitle, inputTextView, inputCountLabel].forEach {
         flexBox.addSubview($0)
      }
   }
   
   override func layoutSubviews() {
      super.layoutSubviews()
      
      flexBox.pin
         .width(100%)
      
      flexBox.flex
         .direction(.column)
         .define { flex in
            flex.addItem(inputTitle)
               .marginBottom(8)
            flex.addItem(inputTextView)
               .width(100%)
               .height(120)
               .marginBottom(4)
            flex.addItem(inputCountLabel)
               .width(100%)
               .height(20)
               .alignSelf(.end)
         }
      
      flexBox.flex.layout(mode: .adjustHeight)
   }
   
   override func setUI() {
      super.setUI()
      
      inputTextView.layer.cornerRadius = 8
      inputTextView.layer.borderWidth = 1
      inputTextView.layer.borderColor = UIColor.darkGray.withAlphaComponent(0.5).cgColor
      inputTextView.font = .systemFont(ofSize: 15)
      inputTextView.textContainerInset = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
      
      inputCountLabel.textAlignment = .right
   }
}
