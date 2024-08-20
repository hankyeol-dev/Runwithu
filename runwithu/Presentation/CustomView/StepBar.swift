//
//  StepBar.swift
//  runwithu
//
//  Created by 강한결 on 8/20/24.
//

import UIKit

import PinLayout
import FlexLayout

final class StepBar: BaseView {
   private let flexBox = UIView()
   private let stepIamge = UIImageView(image: UIImage(systemName: "circle.fill", withConfiguration: UIImage.SymbolConfiguration(font: .systemFont(ofSize: 24))))
   private let stepLabel = BaseLabel(for: "", font: .systemFont(ofSize: 15))
   
   override func setSubviews() {
      super.setSubviews()
      
      addSubview(flexBox)
      flexBox.addSubview(stepIamge)
      flexBox.addSubview(stepLabel)
   }
   
   convenience init(labelText: String) {
      self.init(frame: .zero)
      stepLabel.text = labelText
   }
   
   override func layoutSubviews() {
      super.layoutSubviews()
      
      flexBox.pin
         .all(self.pin.safeArea)
      
      flexBox.flex.direction(.row)
         .padding(8)
         .alignItems(.center)
         .justifyContent(.start)
         .define { flex in
            flex.addItem(stepIamge)
               .size(16)
               .marginHorizontal(8)
            flex.addItem(stepLabel)
               .width(100%)
         }
      
      flexBox.flex.layout(mode: .fitContainer)
   }
   
   override func setUI() {
      super.setUI()
      
      stepLabel.textColor = .white
      stepIamge.tintColor = .white.withAlphaComponent(0.8)
   }
   
   func additionLabelText(by text: String) {
      if text.count != 0 {
         stepIamge.tintColor = .white.withAlphaComponent(1.0)
         stepLabel.text = text
         stepLabel.font = .boldSystemFont(ofSize: 15)
      } else {
         stepIamge.tintColor = .white.withAlphaComponent(0.8)
         stepLabel.text = text
         stepLabel.font = .systemFont(ofSize: 15)
      }
   }
}
