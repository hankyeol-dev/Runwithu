//
//  RoundedDatePickerView.swift
//  runwithu
//
//  Created by 강한결 on 8/21/24.
//

import UIKit

import PinLayout
import FlexLayout

final class RoundedDatePickerView: BaseView {
   private let flexBox = UIView()
   private let viewTitle = BaseLabel(for: "", font: .systemFont(ofSize: 18))
   let datePicker = UIDatePicker()
   private let viewSubLabel = BaseLabel(for: "", font: .systemFont(ofSize: 12), color: .darkGray)
   
   convenience init(title: String, sub: String) {
      self.init(frame: .zero)
      viewTitle.text = title
      viewSubLabel.text = sub
   }
   
   override func setSubviews() {
      super.setSubviews()
      
      addSubview(flexBox)
      [viewTitle, datePicker, viewSubLabel].forEach {
         flexBox.addSubview($0)
      }
   }
   
   override func setLayout() {
      super.setLayout()
      
      flexBox.pin.width(100%)
      flexBox.flex
         .direction(.column)
         .define { flex in
            flex
               .addItem()
               .direction(.row)
               .alignItems(.center)
               .justifyContent(.spaceBetween)
               .width(100%)
               .define { flex in
                  flex.addItem(viewTitle)
                     .width(25%)
                  flex.addItem(datePicker)
                     .width(65%)
               }
               .marginBottom(8)
            
            flex.addItem(viewSubLabel)
               .width(100%)
               .alignSelf(.end)
               .height(16)
         }
         .layout(mode: .adjustHeight)
   }
   
   override func setUI() {
      super.setUI()
      
      datePicker.datePickerMode = .dateAndTime
      datePicker.locale = Locale(identifier: "ko_KR")
      datePicker.preferredDatePickerStyle = .compact
      datePicker.minimumDate = .now
      datePicker.minuteInterval = 10
      viewSubLabel.textAlignment = .right
   }
}
