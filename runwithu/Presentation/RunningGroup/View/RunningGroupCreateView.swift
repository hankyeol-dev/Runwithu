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
   
   private let headerView = UIView()
   private let headerTitle = BaseLabel(for: "러닝 그룹 생성", font: .boldSystemFont(ofSize: 16))
   let headerCloseButton = UIButton()
   
   let previewView = RunningGroupPreviewView()
   let groupNameField = RoundedInputViewWithTitle(label: "그룹 이름", placeHolder: "")
   let groupEntryLimitField = RoundedInputViewWithTitle(label: "그룹 최대 인원", placeHolder: "", keyboardType: .numberPad)
   let groupDescriptionField = RoundedTextViewWithTitle(title: "그룹 소개")
   let groupSpotField = RoundedInputViewWithTitle(label: "그룹 러닝 지역", placeHolder: "")
   let groupHardType = RoundedInputViewWithTitle(label: "그룹 추천 러닝 난이도", placeHolder: "그룹이 필요로 하는 러닝 경험 정도를 선택해주세요.")
   let createButton = RoundedButtonView("그룹 만들기", backColor: .systemGreen, baseColor: .white)
   
   override func setSubviews() {
      super.setSubviews()
      
      addSubview(contentsFlexBox)
      [headerView, previewView, scrollView].forEach {
         contentsFlexBox.addSubview($0)
      }
      [headerCloseButton, headerTitle].forEach {
         headerView.addSubview($0)
      }
      
      scrollView.addSubview(contentsBox)
      [groupNameField, groupEntryLimitField, groupDescriptionField, groupSpotField, groupHardType, createButton].forEach {
         contentsBox.addSubview($0)
      }
   }
   
   override func layoutSubviews() {
      super.layoutSubviews()
      
      contentsFlexBox.pin
         .all(self.pin.safeArea)
      
      headerView.pin
         .top(contentsFlexBox.pin.safeArea)
         .horizontally()
         .height(44)
      
      headerCloseButton.pin
         .left(headerView.pin.safeArea + 24)
         .vCenter()
         .size(12)
      
      headerTitle.pin
         .hCenter()
         .height(100%)
         .sizeToFit(.height)
      
      previewView.pin
         .below(of: headerView)
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
      groupEntryLimitField.inputField.setRightLabelView(with: "명", by: 40, background: .white)
      headerCloseButton.closeButton()
      groupHardType.bindToInputPickerView(
         for: RunningHardType.allCases.map { $0.byLevel }
      )
   }
}
