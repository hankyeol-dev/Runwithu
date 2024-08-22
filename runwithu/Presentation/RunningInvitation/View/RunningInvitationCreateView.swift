//
//  RunningInvitationCreateView.swift
//  runwithu
//
//  Created by 강한결 on 8/21/24.
//

import UIKit

import PinLayout
import FlexLayout

final class RunningInvitationCreateView: BaseView, BaseViewProtocol {
   private let contentsFlexBox = UIView()
   private let scrollView = UIScrollView()
   private let contentsBox = UIView()
   
   private let headerView = UIView()
   private let headerTitle = BaseLabel(for: "함께 달려요", font: .boldSystemFont(ofSize: 16))
   let headerCloseButton = UIButton()
   
   private let inviteRectangle = RectangleView(backColor: .systemGray5.withAlphaComponent(0.4), radius: 12)
   let runningInviteUserPicker = RoundedAddUserView(title: "초대할 러너")
   let runningInvitationTitle = RoundedInputViewWithTitle(label: "초대장 제목", placeHolder: "ex. 우리 함께 달려요!")
   let runningInvitationContent = RoundedTextViewWithTitle(title: "초대장 내용")
   
   private let infoRectangle = RectangleView(backColor: .systemGray6.withAlphaComponent(0.4), radius: 12)
   let runningDatePicker = RoundedDatePickerView(title: "일자", sub: "러닝 일자를 시간까지 선택해주세요.")
   let runningCourse = RoundedInputViewWithTitle(label: "코스 (선택)", placeHolder: "간략한 코스 정보를 알려주세요.")
   let runningTimeTaking = RoundedInputViewWithTitle(label: "예상 소요 시간 (선택)", placeHolder: "", keyboardType: .numberPad)
   let runningHardType = RoundedInputViewWithTitle(label: "예상 난이도 (선택)", placeHolder: "적당히 힘들 수 있어요.")
   let runningSupplies = RoundedInputViewWithTitle(label: "준비물 (선택)", placeHolder: "ex. 물, 건강한 정신과 신체")
   let runningRewards = RoundedInputViewWithTitle(label: "보상 (선택)", placeHolder: "ex. 맛난 잔치국수 한 사발")
   let createButton = RoundedButtonView("러닝 초대하기", backColor: .systemGreen, baseColor: .orange)
   
   override func setSubviews() {
      super.setSubviews()
      
      addSubview(contentsFlexBox)
      
      [headerView, scrollView].forEach {
         contentsFlexBox.addSubview($0)
      }
      
      [headerCloseButton, headerTitle].forEach {
         headerView.addSubview($0)
      }
      
      scrollView.addSubview(contentsBox)
      
      [inviteRectangle, infoRectangle, createButton].forEach {
         contentsBox.addSubview($0)
      }
   }
   
   override func layoutSubviews() {
      super.layoutSubviews()
      
      contentsFlexBox.pin
         .all(self.pin.safeArea)
      
      /// headerView
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
      
      scrollView.pin
         .below(of: headerView)
         .horizontally(contentsFlexBox.pin.safeArea)
         .bottom(contentsFlexBox.pin.safeArea)
      
      contentsBox.pin
         .vertically()
         .horizontally()
      
      contentsBox.flex
         .direction(.column)
         .padding(16)
         .rowGap(12)
         .define { flex in
            flex.addItem(inviteRectangle)
               .direction(.column)
               .padding(16)
               .define { items in
                  items.addItem(runningDatePicker)
                     .marginBottom(20)
                  items.addItem(runningInviteUserPicker)
                     .marginBottom(12)
                  items.addItem(runningInvitationTitle)
                     .marginBottom(8)
                  items.addItem(runningInvitationContent)
               }
            
            flex.addItem(infoRectangle)
               .direction(.column)
               .padding(16)
               .define { items in
                  items.addItem(runningCourse)
                     .marginBottom(12)
                  items.addItem(runningTimeTaking)
                     .marginBottom(12)
                  items.addItem(runningHardType)
                     .marginBottom(12)
                  items.addItem(runningSupplies)
                     .marginBottom(12)
                  items.addItem(runningRewards)
               }
            
            flex.addItem(createButton)
               .height(48)
               .marginBottom(12)
         }.layout(mode: .adjustHeight)
      
      scrollView.contentSize = contentsBox.frame.size
   }
   
   override func setUI() {
      super.setUI()
      headerCloseButton.closeButton()
      runningTimeTaking.inputField.setRightLabelView(with: "분", by: 40, background: .clear)
      runningHardType.bindToInputPickerView()
   }
}
