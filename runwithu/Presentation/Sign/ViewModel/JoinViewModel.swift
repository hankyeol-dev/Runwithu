//
//  JoinViewModel.swift
//  runwithu
//
//  Created by 강한결 on 8/17/24.
//

import Foundation

import RxSwift

final class JoinViewModel: BaseViewModelProtocol {
   let disposeBag: DisposeBag
   let networkManager: NetworkService
   
   init(
      disposeBag: DisposeBag,
      networkManager: NetworkService
   ) {
      self.disposeBag = disposeBag
      self.networkManager = networkManager
   }
   
   private var email = ""
   private var password = ""
   private var nickname = ""
   
   struct Input {
      let email: PublishSubject<String>
      let password: PublishSubject<String>
      let nickname: PublishSubject<String>
      let emailOverlapCheckButtonTapped: PublishSubject<Void>
      let joinButtonTapped: PublishSubject<Void>
   }
   struct Output {
      let emailValidation: Observable<Bool>
      let passwordValidation: Observable<Bool>
      let nicknameValidation: Observable<Bool>
      let isAbleToJoin: BehaviorSubject<Bool>
      let successMessage: PublishSubject<String>
      let errorMessage: PublishSubject<String>?
      let successJoin: PublishSubject<Bool>
   }
   
   func transform(for input: Input) -> Output {
      let isAbleToJoin = BehaviorSubject<Bool>(value: false)
      let successMessage = PublishSubject<String>()
      let errorMessage = PublishSubject<String>()
      let successJoin = PublishSubject<Bool>()
      
      input.email.subscribe(with: self) { vm, email in
         vm.email = email
      }
      .disposed(by: disposeBag)
      
      input.password.subscribe(with: self) { vm, password in
         vm.password = password
      }
      .disposed(by: disposeBag)
      
      input.nickname.subscribe(with: self) { vm, nickname in
         vm.nickname = nickname
      }
      .disposed(by: disposeBag)
      
      let emailValidation = input.email
         .map { self.validateEmail(for: $0) }
         .share()
      
      let passwordValidation = input.password
         .map { self.validatePassword(for: $0) }
         .share()
      
      let nicknameValidation = input.nickname
         .map { self.validateNickname(for: $0) }
         .share()
      
      input.emailOverlapCheckButtonTapped
         .withLatestFrom(input.email)
         .subscribe(with: self) { vm, email in
            Task {
               await vm.checkEmailIsOverlap(
                  email,
                  successEmitter: successMessage,
                  errorEmitter: errorMessage
               )
            }
         }
         .disposed(by: disposeBag)
      
      input.joinButtonTapped
         .subscribe(with: self, onNext: { vm, input in
            Task {
               await vm.join(
                  successEmitter: successMessage,
                  errorEmitter: errorMessage,
                  successJoinEmitter: successJoin
               )
            }
         })
         .disposed(by: disposeBag)
      
      Observable.combineLatest([emailValidation, passwordValidation, nicknameValidation])
         .subscribe(with: self) { _, validations in
            let isEnabled = (validations.filter { $0 == true }).count == validations.count
            isAbleToJoin.onNext(isEnabled)
         }
         .disposed(by: disposeBag)
      
      return Output(
         emailValidation: emailValidation,
         passwordValidation: passwordValidation,
         nicknameValidation: nicknameValidation,
         isAbleToJoin: isAbleToJoin,
         successMessage: successMessage,
         errorMessage: errorMessage,
         successJoin: successJoin
      )
   }
}

extension JoinViewModel {
   private func checkEmailIsOverlap(
      _ email: String,
      successEmitter: PublishSubject<String>,
      errorEmitter: PublishSubject<String>?
   ) async {
      do {
         let result = try await networkManager.request(
            by: UserEndPoint.validEmail(input: .init(email: email)),
            of: ValidEmailOutput.self)
         successEmitter.onNext(result.message)
      } catch NetworkErrors.invalidResponse {
         errorEmitter?.onNext("이미 사용중인 이메일이에요.")
      } catch {
         errorEmitter?.onNext("알 수 없는 에러가 발생했어요.")
      }
   }
   
   private func join(
      successEmitter: PublishSubject<String>,
      errorEmitter: PublishSubject<String>?,
      successJoinEmitter: PublishSubject<Bool>
   ) async {
      let joinInput = JoinInput(
         email: email,
         password: password,
         nick: nickname,
         phoneNum: nil,
         birthDay: nil
      )
      
      do {
         let result = try await networkManager.request(
            by: UserEndPoint.join(input: joinInput),
            of: JoinOutput.self
         )
         successEmitter.onNext("\(result.nick) 계정 생성 완료 :D")
         successJoinEmitter.onNext(true)
      } catch NetworkErrors.invalidResponse {
         errorEmitter?.onNext("이미 사용중인 계정이에요.")
         successJoinEmitter.onNext(false)
      } catch NetworkErrors.overlapUsername {
         errorEmitter?.onNext("이미 사용중인 러너이름이에요.")
         successJoinEmitter.onNext(false)
      } catch {
         errorEmitter?.onNext("알 수 없는 에러가 발생했어요.")
         successJoinEmitter.onNext(false)
      }
   }
}
