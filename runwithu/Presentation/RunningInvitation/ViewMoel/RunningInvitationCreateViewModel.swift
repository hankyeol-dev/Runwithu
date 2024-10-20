//
//  RunningInvitationCreateViewModel.swift
//  runwithu
//
//  Created by 강한결 on 8/21/24.
//

import Foundation

import RxSwift

final class RunningInvitationCreateViewModel: BaseViewModelProtocol {
   let disposeBag: DisposeBag
   let networkManager: NetworkService
   
   private var invitationId = ""
   private var mainInvitedUserId: [String] = []
   private var invitedUsers: [String] = []
   private let publishedInvitedUsers = PublishSubject<[String]>()
   private var followings: [BaseProfileType] = []
   private var title = ""
   private var content = ""
   private var runningInfo: RunningInfo = .init(
      date: "",
      course: nil,
      timeTaking: nil,
      hardType: nil,
      supplies: nil,
      reward: nil
   )
   
   init(
      disposeBag: DisposeBag,
      networkManager: NetworkService
   ) {
      self.disposeBag = disposeBag
      self.networkManager = networkManager
   }
   
   struct Input {
      let didLoadInput: PublishSubject<Void>
      let inviteButtonTapped: PublishSubject<Void>
      let inviteTitle: PublishSubject<String>
      let inviteContent: PublishSubject<String>
      let inviteDate: PublishSubject<String>
      let inviteCourse: PublishSubject<String>
      let inviteTimeTaking: PublishSubject<String>
      let inviteHardType: PublishSubject<String>
      let inviteSupplies: PublishSubject<String>
      let inviteRewards: PublishSubject<String>
      let createButtonTapped: PublishSubject<Void>
   }
   
   struct Output {
      let followings: PublishSubject<[BaseProfileType]?>
      let titleText: PublishSubject<String>
      let contentText: PublishSubject<String>
      let courseText: PublishSubject<String>
      let supplyText: PublishSubject<String>
      let rewardsText: PublishSubject<String>
      let createResult: PublishSubject<(String?, String?)>
      let publishedInvitedUsers: PublishSubject<[String]>
   }
   
   func transform(for input: Input) -> Output {
      let followings = PublishSubject<[BaseProfileType]?>()
      let titleText = PublishSubject<String>()
      let contentText = PublishSubject<String>()
      let courseText = PublishSubject<String>()
      let supplyText = PublishSubject<String>()
      let rewardsText = PublishSubject<String>()
      let createResult = PublishSubject<(String?, String?)>()
      
      input.didLoadInput
         .subscribe(with: self) { vm, _ in
            vm.publishedInvitedUsers.onNext(vm.invitedUsers)
         }
         .disposed(by: disposeBag)
      
      input.inviteButtonTapped
         .withUnretained(self)
         .subscribe(with: self) { vm, _ in
            // TODO: sender closure 여기
            
            if vm.followings.isEmpty {
               Task {
                  await vm.getFollowings(successEmitter: followings)
               }
            } else {
               followings.onNext(vm.followings)
            }
         }
         .disposed(by: disposeBag)
      
      bindingToRunningInfo(with: input.inviteDate) { [weak self] date in
         guard let self else { return }
         self.runningInfo.date = date
      }
      
      bindingToRunningInfo(with: input.inviteTimeTaking) { [weak self] timeTake in
         guard let self else { return }
         self.runningInfo.timeTaking = Int(timeTake)
      }
      
      bindingToRunningInfo(with: input.inviteHardType) { [weak self] type in
         guard let self else { return }
         self.runningInfo.hardType = type
      }
      
      subscribingTrimmedText(with: input.inviteTitle, how: 15, for: titleText) { [weak self] title in
         guard let self else { return }
         self.title = title
      }
      
      subscribingTrimmedText(with: input.inviteContent, how: 100, for: contentText) { [weak self] content in
         guard let self else { return }
         self.content = content
      }
      
      subscribingTrimmedText(with: input.inviteCourse, how: 25, for: courseText) { [weak self] course in
         guard let self else { return }
         self.runningInfo.course = course
      }
      
      subscribingTrimmedText(with: input.inviteSupplies, how: 15, for: supplyText) { [weak self] supplies in
         guard let self else { return }
         self.runningInfo.supplies = supplies
      }
      
      subscribingTrimmedText(with: input.inviteRewards, how: 15, for: rewardsText) { [weak self] rewards in
         guard let self else { return }
         self.runningInfo.reward = rewards
      }
      
      input.createButtonTapped
         .subscribe(with: self) { vm, _ in
            let valid = vm.validateForCreate()
            if valid {
               Task {
                  await vm.createInvitation(successEmitter: createResult)
               }
            } else {
               createResult.onNext((nil, "필수 항목을 모두 채워주세요."))
            }
         }
         .disposed(by: disposeBag)
      
      return Output(
         followings: followings,
         titleText: titleText,
         contentText: contentText,
         courseText: courseText,
         supplyText: supplyText,
         rewardsText: rewardsText,
         createResult: createResult,
         publishedInvitedUsers: publishedInvitedUsers
      )
   }
   
   func getInvitationId() -> String { return invitationId }
}

extension RunningInvitationCreateViewModel {
   typealias runningInfoHandler = (String) -> Void
   
   func appendOrRemoveFromInvitedUsers(userId: String, username: String) {
      if let userIndex = invitedUsers.firstIndex(of: username) {
         invitedUsers.remove(at: userIndex)
      } else {
         mainInvitedUserId.append(userId)
         invitedUsers.append(username)
      }
      publishedInvitedUsers.onNext(invitedUsers)
   }
   
   func appendOrRemoveFromInvitedUsers(username: String) {
      if let userIndex = invitedUsers.firstIndex(of: username) {
         invitedUsers.remove(at: userIndex)
      } else {
         invitedUsers.append(username)
      }
      
      publishedInvitedUsers.onNext(invitedUsers)
   }
   
   private func subscribingTrimmedText(
      with input: PublishSubject<String>,
      how trimLimit: Int,
      for output: PublishSubject<String>,
      _ handler: @escaping runningInfoHandler
   ) {
      input.subscribe(with: self) { vm, text in
         let trimmedText = vm.trimmingText(for: text, index: trimLimit)
         handler(text)
         output.onNext(trimmedText)
      }
      .disposed(by: disposeBag)
   }
   
   private func bindingToRunningInfo(with input: PublishSubject<String>, _ handler: @escaping runningInfoHandler) {
      input.subscribe(with: self) { _, text in
         handler(text)
      }
      .disposed(by: disposeBag)
   }
   
   private func validateForCreate() -> Bool {
      if title.isEmpty { return false }
      if content.isEmpty { return false }
      if invitedUsers.count == 0 { return false }
      if runningInfo.date.isEmpty { return false }
      return true
   }
   
   private func createInvitation(
      successEmitter: PublishSubject<(String?, String?)>
   ) async {
      let createInvitationInput: CreateInvitationInput = .init(
         title: title,
         content: content,
         invited: mainInvitedUserId + followings.filter { invitedUsers.contains($0.nick) }.map { $0.user_id },
         runningInfo: runningInfo
      )
      
      do {
         let results = try await networkManager.request(
            by: PostEndPoint.posts(input: createInvitationInput.formatToPostsInput),
            of: PostsOutput.self
         )
         invitationId = results.post_id
         successEmitter.onNext((results.post_id, nil))
      } catch NetworkErrors.needToRefreshRefreshToken {
         await tempLoginAPI()
         await createInvitation(successEmitter: successEmitter)
      } catch {
         dump(error)
         successEmitter.onNext((nil, "초대장을 생성할 수 없습니다."))
      }
   }
   
   private func getFollowings(
      successEmitter: PublishSubject<[BaseProfileType]?>
   ) async {
      do {
         let results = try await networkManager.request(
            by: UserEndPoint.readMyProfile,
            of: FollowingsOutput.self
         )
         followings = results.following
         successEmitter.onNext(results.following)
      } catch NetworkErrors.needToRefreshRefreshToken {
         await tempLoginAPI()
         await getFollowings(successEmitter: successEmitter)
      } catch {
         dump(error)
         successEmitter.onNext(nil)
      }
   }
}
