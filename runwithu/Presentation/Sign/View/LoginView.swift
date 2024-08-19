//
//  LoginView.swift
//  runwithu
//
//  Created by 강한결 on 8/17/24.
//

import UIKit

import PinLayout
import FlexLayout

final class LoginView: BaseView, BaseViewProtocol {
   private let rootFlexBox = UIView()
   private let loginWelcomeTitle = BaseLabel(for: "함께 달려볼까요! :)", font: .boldSystemFont(ofSize: 16))
   private let loginTitle = BaseLabel(for: "로그인", font: .boldSystemFont(ofSize: 20))
   let emailInput = InputWithTitleView(
      label: "이메일",
      placeHolder: "이메일을 입력해주세요.",
      keyboardType: .emailAddress
   )
   let passwordInput = InputWithTitleView(
      label: "비밀번호",
      placeHolder: "비밀번호를 입력해주세요."
   )
   let loginButton = RoundedButtonView("로그인", backColor: .systemBlue, baseColor: .white)
   let joinButton = {
      let button = UIButton()
      button.setTitle("런윗유 식구되기", for: .normal)
      button.setTitleColor(.systemBlue.withAlphaComponent(0.8), for: .normal)
      button.backgroundColor = .none
      button.titleLabel?.font = .systemFont(ofSize: 13, weight: .semibold)
      return button
   }()
   
   override func setSubviews() {
      super.setSubviews()
      
      addSubview(rootFlexBox)
      
      [loginWelcomeTitle, loginTitle, emailInput, passwordInput, loginButton, joinButton].forEach {
         rootFlexBox.addSubview($0)
      }
   }
   
   override func layoutSubviews() {
      super.layoutSubviews()
      
      rootFlexBox.pin
         .horizontally(16)
         .top(self.pin.safeArea + 32)
      
      rootFlexBox.flex.direction(.column)
         .padding(0)
         .define { flex in
            flex.addItem(loginWelcomeTitle)
               .margin(0, 16, 8, 0)
            
            flex.addItem(loginTitle)
               .margin(0, 16, 16, 0)
            
            flex.addItem(emailInput)
            flex.addItem(passwordInput)
               .marginBottom(16)
            
            flex.addItem(loginButton)
               .height(48)
               .margin(0, 16, 16, 16)
            
            flex.addItem(joinButton)
               .width(100%)
               .height(32)
               .marginBottom(16)
         }
      
      rootFlexBox.flex.layout(mode: .adjustHeight)
   }
}