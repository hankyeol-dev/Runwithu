//
//  RoundedInputViewWithTitle.swift
//  runwithu
//
//  Created by 강한결 on 8/19/24.
//

import UIKit

import PinLayout
import FlexLayout
import SnapKit

final class RoundedInputViewWithTitle: BaseView {
   private var pickerData: [String] = []
   
   private let flexBox = UIView()
   private let inputTitle = BaseLabel(for: "", font: .systemFont(ofSize: 18))
   let inputField = BaseTextFieldRounded("")
   let inputIndicatingLabel = BaseLabel(for: "", font: .systemFont(ofSize: 12))
   let inputCountLabel = BaseLabel(for: "", font: .systemFont(ofSize: 12), color: .darkGray)
   let picker = UIPickerView()
   
   convenience init(
      label: String,
      placeHolder: String,
      keyboardType: UIKeyboardType = .default,
      indicatingLabel: String = "",
      labelSize: CGFloat = 18.0
   ) {
      self.init(frame: .zero)
      inputTitle.text = label
      inputTitle.font = .systemFont(ofSize: labelSize)
      inputField.placeholder = placeHolder
      inputField.keyboardType = keyboardType
      inputIndicatingLabel.text = indicatingLabel
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
   func bindToTitleSize(_ fontSize: CGFloat) {
      inputTitle.font = .systemFont(ofSize: fontSize)
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
   
   func bindToTitleLabel(for text: String) {
      inputTitle.text = text
   }

}

extension RoundedInputViewWithTitle: UIPickerViewDelegate, UIPickerViewDataSource {
   func bindToInputPickerView(for pickerData: [String]) {
      self.pickerData = pickerData
      let arrow = UIImageView()
      arrow.image = UIImage(systemName: "chevron.down")
      arrow.contentMode = .center
      arrow.tintColor = .darkGray
      inputField.addSubview(arrow)
      arrow.snp.makeConstraints { make in
         make.width.equalTo(24)
         make.verticalEdges.equalTo(inputField.safeAreaLayoutGuide)
         make.trailing.equalTo(inputField.safeAreaLayoutGuide).inset(4)
      }
      
      picker.delegate = self
      picker.dataSource = self
      inputField.inputView = picker
      inputField.tintColor = .clear
   }
   
   func numberOfComponents(in pickerView: UIPickerView) -> Int {
      return 1
   }
   
   func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
      return pickerData.count
   }
   
   func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
      return pickerData[row]
   }
   
   func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
      inputField.text = pickerData[row]
   }
   
}
