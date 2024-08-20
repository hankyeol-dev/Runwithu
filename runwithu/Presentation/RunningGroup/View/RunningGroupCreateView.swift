//
//  RunningGroupCreateView.swift
//  runwithu
//
//  Created by 강한결 on 8/19/24.
//

import UIKit

import SnapKit
import PinLayout
import FlexLayout

final class RunningGroupCreateView: BaseView, BaseViewProtocol {
   private let contentsFlexBox = UIView()
   private let scrollView = UIScrollView()
   private let contentsBox = UIView()
   private let hardTypePicker = UIPickerView()
   
   let previewView = RunningGroupPreviewView()
   let groupNameField = RoundedInputViewWithTitle(label: "그룹 이름", placeHolder: "")
   let groupEntryLimitField = RoundedInputViewWithTitle(label: "그룹 최대 인원", placeHolder: "", keyboardType: .numberPad)
   let groupDescriptionField = RoundedTextViewWithTitle(title: "그룹 소개")
   let groupSpotField = RoundedInputViewWithTitle(label: "그룹 러닝 지역", placeHolder: "")
   let groupHardType = RoundedInputViewWithTitle(label: "그룹 추천 러닝 난이도", placeHolder: "그룹이 필요로 하는 러닝 경험 정도를 선택해주세요.")
   let createButton = RoundedButtonView("그룹 만들기", backColor: .darkGray, baseColor: .white)
   
   
   override func setSubviews() {
      super.setSubviews()
      
      addSubview(contentsFlexBox)
      contentsFlexBox.addSubview(previewView)
      contentsFlexBox.addSubview(scrollView)
      scrollView.addSubview(contentsBox)
      
      [groupNameField, groupEntryLimitField, groupDescriptionField, groupSpotField, groupHardType, createButton].forEach {
         contentsBox.addSubview($0)
      }
   }
   
   override func layoutSubviews() {
      super.layoutSubviews()
      
      contentsFlexBox.pin
         .all(self.pin.safeArea)
      
      previewView.pin
         .top(contentsFlexBox.pin.safeArea)
         .horizontally()
         .height(180)
      
      scrollView.pin
         .below(of: previewView)
         .horizontally(contentsFlexBox.pin.safeArea)
         .bottom(contentsFlexBox.pin.safeArea)
      
      contentsBox.pin
         .vertically()
         .horizontally()
      
      contentsBox.flex.direction(.column)
         .padding(24, 16)
         .define { flex in
            flex.addItem(groupNameField)
               .marginBottom(8)
            
            flex.addItem(groupEntryLimitField)
               .marginBottom(12)
            
            flex.addItem(groupDescriptionField)
               .height(180)
               .marginBottom(8)
            
            flex.addItem(groupSpotField)
               .marginBottom(16)
            
            flex.addItem(groupHardType)            
            flex.addItem(createButton)
               .height(48)
         }
      
      contentsBox.flex
         .layout(mode: .adjustHeight)
      
      scrollView.contentSize = contentsBox.frame.size
   }
   
   override func setUI() {
      super.setUI()
      scrollView.backgroundColor = .systemBackground
      setRightCountLabel()
      setGroupHardType()
   }
}

extension RunningGroupCreateView {
   private func setRightCountLabel() {
      let rightCountLabel = UILabel()
      rightCountLabel.text = "명"
      rightCountLabel.font = .systemFont(ofSize: 14, weight: .semibold)
      rightCountLabel.textAlignment = .center
      rightCountLabel.backgroundColor = .white
      rightCountLabel.layer.zPosition = 100
      groupEntryLimitField.inputField.addSubview(rightCountLabel)
      rightCountLabel.snp.makeConstraints { make in
         make.width.equalTo(40)
         make.trailing.verticalEdges.equalTo(groupEntryLimitField.inputField.safeAreaLayoutGuide)
      }
   }
   private func setGroupHardType() {
      let arrow = UIImageView()
      arrow.image = UIImage(systemName: "chevron.down")
      arrow.contentMode = .center
      arrow.tintColor = .darkGray
      groupHardType.inputField.addSubview(arrow)
      arrow.snp.makeConstraints { make in
         make.width.equalTo(24)
         make.verticalEdges.equalTo(groupHardType.inputField.safeAreaLayoutGuide)
         make.trailing.equalTo(groupHardType.inputField.safeAreaLayoutGuide).inset(4)
      }
      
      hardTypePicker.delegate = self
      hardTypePicker.dataSource = self
      groupHardType.inputField.inputView = hardTypePicker
      groupHardType.tintColor = .clear
   }
}

// MARK: PickerViewControl
extension RunningGroupCreateView: UIPickerViewDelegate, UIPickerViewDataSource {
   func numberOfComponents(in pickerView: UIPickerView) -> Int {
      return 1
   }
   
   func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
      return RunningHardType.allCases.count
   }
   
   func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
      return RunningHardType.allCases.map { $0.byLevel }[row]
   }
   
   func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
      groupHardType.inputField.text = RunningHardType.allCases.map { $0.byLevel }[row]
   }
}
