//
//  JoinViewController.swift
//  runwithu
//
//  Created by 강한결 on 8/17/24.
//

import UIKit

import RxSwift
import RxCocoa

final class JoinViewController: BaseViewController<JoinView, JoinViewModel> {
   
   override func loadView() {
      view = baseView
   }
   
   override func viewDidLoad() {
      super.viewDidLoad()
   }
   
   override func viewWillAppear(_ animated: Bool) {
      super.viewWillAppear(animated)
   }
   
   override func bindViewAtWillAppear() {
      super.bindViewAtWillAppear()
      
      setGoBackButton(by: .darkGray)
   }
   
   override func bindViewAtDidLoad() {
      super.bindViewAtDidLoad()
      
      let emailInputText = PublishSubject<String>()
      let passwordInputText = PublishSubject<String>()
      let nicknameInputText = PublishSubject<String>()
      let checkButtonTapped = PublishSubject<Void>()
      let joinButtonTapped = PublishSubject<Void>()
      
      let input = JoinViewModel.Input(
         email: emailInputText,
         password: passwordInputText,
         nickname: nicknameInputText,
         emailOverlapCheckButtonTapped: checkButtonTapped,
         joinButtonTapped: joinButtonTapped
      )
      let output = viewModel.transform(for: input)
      
      bindInputText(for: baseView.emailInput.inputField.rx.text.orEmpty, to: emailInputText)
      bindInputText(for: baseView.passwordInput.inputField.rx.text.orEmpty, to: passwordInputText)
      bindInputText(for: baseView.nicknameInput.inputField.rx.text.orEmpty, to: nicknameInputText)
      
      baseView.emailOverlapCheckButton.rx.tap
         .subscribe(with: self) { vc, _ in
            checkButtonTapped.onNext(())
         }
         .disposed(by: disposeBag)
      
      baseView.joinButton.rx.tap
         .bind(with: self) { vc, _ in
            joinButtonTapped.onNext(())
         }
         .disposed(by: disposeBag)
      
      output.emailValidation
         .bind(with: self) { vc, valid in
            vc.baseView.emailInput.inputIndicatingLabel.isHidden = valid
            vc.baseView.emailOverlapCheckButton.isEnabled = valid
            
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
      
      output.nicknameValidation
         .bind(with: self) { vc, valid in
            vc.baseView.nicknameInput.inputIndicatingLabel.isHidden = valid
            if !valid {
               vc.baseView.nicknameInput.setIndicatingLabelError(for: "러너 이름은 2자 이상 입력해주세요.")
            }
         }
         .disposed(by: disposeBag)
      
      output.isAbleToJoin
         .bind(to: baseView.joinButton.rx.isEnabled)
         .disposed(by: disposeBag)
      
      output.successMessage
         .bind(with: self) { vc, message in
            vc.baseView.displayToast(for: message, isError: false, duration: 2)
         }
         .disposed(by: disposeBag)
      
      output.successJoin
         .bind(with: self) { vc, isSuccess in
            if isSuccess {
               DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                  vc.baseView.emailInput.inputField.text = ""
                  vc.baseView.passwordInput.inputField.text = ""
                  vc.baseView.nicknameInput.inputField.text = ""
                  vc.navigationController?.popViewController(animated: true)
               }
            }
         }
         .disposed(by: disposeBag)
      
      if let error = output.errorMessage {
         error
            .bind(with: self) { vc, errorMessage in
               vc.baseView.displayToast(for: errorMessage, isError: true, duration: 2)
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
