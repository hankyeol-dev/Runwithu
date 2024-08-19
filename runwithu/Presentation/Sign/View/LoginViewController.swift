//
//  LoginViewController.swift
//  runwithu
//
//  Created by 강한결 on 8/16/24.
//

import UIKit

import PinLayout
import FlexLayout

import RxSwift
import RxCocoa

final class LoginViewController: BaseViewController<LoginView, LoginViewModel> {
   
   override func loadView() {
      view = baseView
   }
   
   override func viewDidLoad() {
      super.viewDidLoad()
      
      baseView.emailInput.inputField.text = "7@runwithu.com"
      baseView.passwordInput.inputField.text = "777777"
   }
   
   override func bindViewAtDidLoad() {
      super.bindViewAtDidLoad()
      
      let emailInputText = PublishSubject<String>()
      let passwordInputText = PublishSubject<String>()
      let loginButtonTapped = PublishSubject<Void>()
      
      let input = LoginViewModel.Input(
         email: emailInputText,
         password: passwordInputText,
         loginButtonTapped: loginButtonTapped
      )
      let output = viewModel.transform(for: input)
      
      bindInputText(for: baseView.emailInput.inputField.rx.text.orEmpty, to: emailInputText)
      bindInputText(for: baseView.passwordInput.inputField.rx.text.orEmpty, to: passwordInputText)
      
      baseView.joinButton.rx
         .tap
         .bind(with: self) { vc, _ in
            let targetVC = JoinViewController(
               bv: JoinView(),
               vm: JoinViewModel(),
               db: DisposeBag()
            )
            vc.navigationController?.pushViewController(targetVC, animated: true)
         }
         .disposed(by: disposeBag)
      
      baseView.loginButton.rx
         .tap
         .bind(with: self) { _, _ in
            loginButtonTapped.onNext(())
         }
         .disposed(by: disposeBag)
      
      output.emailValidation
         .bind(with: self) { vc, valid in
            vc.baseView.emailInput.inputIndicatingLabel.isHidden = valid
            if !valid {
               vc.baseView.emailInput.setIndicatingLabelError(for: "정확한 이메일 주소를 입력해주세요.")
            }
         }
         .disposed(by: disposeBag)
      
      output.passwordValidation
         .bind(with: self) { vc, valid in
            vc.baseView.passwordInput.inputIndicatingLabel.isHidden = valid
            if !valid {
               vc.baseView.passwordInput.setIndicatingLabelError(for: "비밀번호는 6자 이상 입력해주세요.")
            }
         }
         .disposed(by: disposeBag)
      
      output.isAbleToLogin
         .bind(to: baseView.loginButton.rx.isEnabled)
         .disposed(by: disposeBag)
      
      output.isLoginSuccess
         .bind(with: self) { vc, isSuccess in
            vc.baseView.displayToast(for: "로그인 성공 :D", isError: false, duration: 1)
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
               vc.dismissStack(for: ViewController())
            }
         }
         .disposed(by: disposeBag)
      
      if let errorState = output.isLoginError {
         errorState.bind(with: self) { vc, errorMessage in
            vc.baseView.displayToast(for: errorMessage, isError: true, duration: 1)
         }
         .disposed(by: disposeBag)
      }
   }
   
   private func bindInputText(for input: ControlProperty<String>, to bindTarget: PublishSubject<String>) {
      input
         .bind(with: self) { vc, text in
            if !text.isEmpty {
               bindTarget.onNext(text)
            }
         }
         .disposed(by: disposeBag)
   }
}