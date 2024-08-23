//
//  ProfileViewModel.swift
//  runwithu
//
//  Created by 강한결 on 8/21/24.
//

import Foundation

import RxSwift

final class ProfileViewModel: BaseViewModelProtocol {
   let disposeBag: DisposeBag
   let networkManager: NetworkService
   private let isUserProfile: Bool
   private var userId: String?
   private var username = "" // 성공했다면, 무조건 있으니까.
   
   struct Input {
      let didLoad: PublishSubject<Void>
      let createInvitationButtonTapped: PublishSubject<Void>
   }
   struct Output {
      let createInvitationButtonTapped: PublishSubject<String>
      let getProfileEmitter: PublishSubject<(ProfileOutput?, String?)>
   }
   
   init(
      disposeBag: DisposeBag,
      networkManager: NetworkService,
      isUserProfile: Bool,
      userId: String? = nil
   ) {
      self.disposeBag = disposeBag
      self.networkManager = networkManager
      self.isUserProfile = isUserProfile
      self.userId = userId
   }
   
   func transform(for input: Input) -> Output {
      let createInvitationButtonTapped = PublishSubject<String>()
      let getProfileEmitter = PublishSubject<(ProfileOutput?, String?)>()
      
      input.didLoad
         .subscribe(with: self) { vm, _ in
            Task {
               await vm.getUserProfile(getProfileEmitter: getProfileEmitter)
            }
         }
         .disposed(by: disposeBag)
      
      input.createInvitationButtonTapped
         .subscribe(with: self) { vm, void in
            createInvitationButtonTapped.onNext(vm.username)
         }
         .disposed(by: disposeBag)
      
      return Output(
         createInvitationButtonTapped: createInvitationButtonTapped,
         getProfileEmitter: getProfileEmitter
      )
   }
   
   func getUserProfileState() -> Bool {
      return isUserProfile
   }
   
   private func getUserProfile(
      getProfileEmitter: PublishSubject<(ProfileOutput?, String?)>
   ) async {
      do {
         var results: ProfileOutput
         if isUserProfile {
            results = try await networkManager.request(
               by: UserEndPoint.readMyProfile,
               of: ProfileOutput.self
            )
         } else {
            guard let userId else { return }
            results = try await networkManager.request(
               by: UserEndPoint.readAnotherProfile(input: .init(user_id: userId)),
               of: ProfileOutput.self
            )
         }
         userId = results.user_id
         username = results.nick
         getProfileEmitter.onNext((results, nil))
        
      } catch NetworkErrors.needToRefreshRefreshToken {
         await tempLoginAPI()
         await getUserProfile(getProfileEmitter: getProfileEmitter)
      } catch {
         dump(error)
         getProfileEmitter.onNext((nil, "뭔가 문제가 발생했습니다."))
      }
   }
}
