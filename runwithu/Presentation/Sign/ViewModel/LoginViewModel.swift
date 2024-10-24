//
//  LoginViewModel.swift
//  runwithu
//
//  Created by 강한결 on 8/17/24.
//

import Foundation

import RxSwift

final class LoginViewModel: BaseViewModelProtocol {
   let disposeBag: DisposeBag
   let networkManager: NetworkService
   let tokenManager: TokenManager
   let userDefaultsManager: UserDefaultsManager
   
   private var email = ""
   private var password = ""
   private var isAutoLogin = false
   
   init(
      disposeBag: DisposeBag,
      networkManager: NetworkService,
      tokenManager: TokenManager,
      userDefaultsManager: UserDefaultsManager
   ) {
      self.disposeBag = disposeBag
      self.networkManager = networkManager
      self.tokenManager = tokenManager
      self.userDefaultsManager = userDefaultsManager
   }
   
   struct Input {
      let willAppearInput: PublishSubject<Void>
      let email: PublishSubject<String>
      let password: PublishSubject<String>
      let loginButtonTapped: PublishSubject<Void>
      let autoLoginCheckButtonTapped: PublishSubject<Void>
   }
   
   struct Output {
      let emailValidation: Observable<Bool>
      let passwordValidation: Observable<Bool>
      let isAbleToLogin: BehaviorSubject<Bool>
      let isLoginSuccess: PublishSubject<Bool>
      let isLoginError: PublishSubject<String>?
      let isAutoLogin: PublishSubject<Bool>
   }
   
   func transform(for input: Input) -> Output {
      let isAbleToLogin = BehaviorSubject<Bool>(value: false)
      let isLoginSuccess = PublishSubject<Bool>()
      let isLoginError = PublishSubject<String>()
      let isAutoLogin = PublishSubject<Bool>()
      
      input.email.subscribe(with: self) { vm, email in
         vm.email = email
      }
      .disposed(by: disposeBag)
      
      input.password.subscribe(with: self) { vm, password in
         vm.password = password
      }
      .disposed(by: disposeBag)
      
      input.willAppearInput
         .subscribe(with: self) { vm, _ in
            isAutoLogin.onNext(vm.isAutoLogin)
         }
         .disposed(by: disposeBag)
      
      input.autoLoginCheckButtonTapped
         .subscribe(with: self) { vm, _ in
            vm.isAutoLogin.toggle()
            isAutoLogin.onNext(vm.isAutoLogin)
         }
         .disposed(by: disposeBag)
      
      let emailValidation = input.email
         .map { self.validateEmail(for: $0) }
         .share()
      
      let passwordValidation = input.password
         .map { self.validatePassword(for: $0) }
         .share()
      
      Observable.combineLatest([emailValidation, passwordValidation])
         .subscribe(with: self) { _, validations in
            let isEnabled = (validations.filter { $0 == true }).count == validations.count
            isAbleToLogin.onNext(isEnabled)
         }
         .disposed(by: disposeBag)
      
      input.loginButtonTapped
         .subscribe(with: self) { vm, _ in
            Task {
               await vm.login(
                  successEmitter: isLoginSuccess,
                  errorEmitter: isLoginError
               )
            }
         }
         .disposed(by: disposeBag)
      
      return Output(
         emailValidation: emailValidation,
         passwordValidation: passwordValidation,
         isAbleToLogin: isAbleToLogin,
         isLoginSuccess: isLoginSuccess,
         isLoginError: isLoginError,
         isAutoLogin: isAutoLogin
      )
   }
}

extension LoginViewModel {
   private func login(
      successEmitter: PublishSubject<Bool>,
      errorEmitter: PublishSubject<String>?
   ) async {
      let loginInput = LoginInput(
         email: email,
         password: password
      )
      
      do {
         let result = try await networkManager.request(
            by: UserEndPoint.login(input: loginInput),
            of: LoginOutput.self
         )
         
         let accessTokenResult = await tokenManager.registerAccessToken(by: result.accessToken)
         let refreshTokenResult = await tokenManager.registerRefreshToken(by: result.refreshToken)

         if accessTokenResult && refreshTokenResult {
            await userDefaultsManager.registerUserId(by: result.user_id)
            
            if isAutoLogin {
               await userDefaultsManager.registerAutoLogin(by: true)
               await userDefaultsManager.registerUserEmail(by: result.email)
               await userDefaultsManager.registerUserPassword(by: password)
            } else {
               await userDefaultsManager.registerAutoLogin(by: false)
               await userDefaultsManager.registerUserEmail(by: "")
               await userDefaultsManager.registerUserPassword(by: "")
            }
            
            successEmitter.onNext(true)
         } else {
            successEmitter.onNext(false)
            errorEmitter?.onNext("알 수 없는 문제가 발생했어요. :(")
         }
         
      } catch NetworkErrors.invalidAccessToken {
         successEmitter.onNext(false)
         errorEmitter?.onNext("가입되지 않은 계정이에요.")
      } catch {
         successEmitter.onNext(false)
         errorEmitter?.onNext("알 수 없는 문제가 발생했어요. :(")
      }
   }
}
