//
//  JoinView.swift
//  runwithu
//
//  Created by 강한결 on 8/17/24.
//

import UIKit

import PinLayout
import FlexLayout

final class JoinView: BaseView, BaseViewProtocol {
   private let rootFlexBox = UIView()
   private let viewWelcomeTitle = BaseLabel(for: "새로운 러너님 환영합니다 :D", font: .boldSystemFont(ofSize: 16))
   private let viewTitle = BaseLabel(for: "러너 계정 만들기", font: .boldSystemFont(ofSize: 20))
   let emailInput = InputWithTitleView(label: "이메일", placeHolder: "이메일을 입력해주세요.", keyboardType: .emailAddress)
   let emailOverlapCheckButton = RoundedButtonView("이메일 중복 확인", backColor: .black, baseColor: .white)
   let passwordInput = InputWithTitleView(label: "비밀번호", placeHolder: "비밀번호를 입력해주세요.")
   let nicknameInput = InputWithTitleView(label: "러너 이름", placeHolder: "유저 이름을 입력해주세요.")
   let joinButton = RoundedButtonView("계정 생성", backColor: .systemBlue, baseColor: .white)
   
   
   override func layoutSubviews() {
      super.layoutSubviews()
      
      rootFlexBox.pin
         .horizontally(16)
         .top(self.pin.safeArea + 32)
      
      rootFlexBox.flex.direction(.column)
         .padding(0)
         .define { flex in
            flex.addItem(viewWelcomeTitle)
               .margin(0, 16, 8, 0)
            
            flex.addItem(viewTitle)
               .margin(0, 16, 16, 0)
            
            flex.addItem(emailInput)
            flex.addItem(passwordInput)
            flex.addItem(nicknameInput)
               .marginBottom(16)
            
            flex.addItem(joinButton)
               .height(48)
               .margin(0, 16, 16, 16)
            
         }
      
      rootFlexBox.flex.layout(mode: .adjustHeight)
   }
   
   override func setSubviews() {
      super.setSubviews()
      
      addSubview(rootFlexBox)
      
      [viewWelcomeTitle, viewTitle, emailInput, passwordInput, nicknameInput, joinButton].forEach {
         rootFlexBox.addSubview($0)
      }
   }
   
   override func setUI() {
      super.setUI()
      
      emailInput.inputField.rightView = emailOverlapCheckButton
      emailInput.inputField.rightViewMode = .always
   }
}
