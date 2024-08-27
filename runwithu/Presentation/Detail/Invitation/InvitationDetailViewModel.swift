//
//  InvitationDetailViewModel.swift
//  runwithu
//
//  Created by 강한결 on 8/26/24.
//

import Foundation

import RxSwift

final class InvitationDetailViewModel: BaseViewModelProtocol {
   let disposeBag: DisposeBag
   let networkManager: NetworkService
   private let invitationId: String
   private var invitation: PostsOutput!
   private var invitationEntries: [BaseProfileType] = []
   
   init(
      disposeBag: DisposeBag,
      networkManager: NetworkService,
      invitationId: String
   ) {
      self.disposeBag = disposeBag
      self.networkManager = networkManager
      self.invitationId = invitationId
   }
   
   struct Input {
      let didLoadInput: PublishSubject<Void>
      let dismissButtonTapped: PublishSubject<Void>
      let joinButtonTapped: PublishSubject<Void>
   }
   struct Output{
      let invitationOutput: PublishSubject<PostsOutput>
      let runningInfoOutput: PublishSubject<RunningInfo?>
      let runningEntryOutput: PublishSubject<[BaseProfileType]>
      let joinedOutput: PublishSubject<Bool>
   }
   
   func transform(for input: Input) -> Output {
      let invitationOutput = PublishSubject<PostsOutput>()
      let runningInfoOutput = PublishSubject<RunningInfo?>()
      let runningEntryOutput = PublishSubject<[BaseProfileType]>()
      let joinedOutput = PublishSubject<Bool>()
      
      input.didLoadInput
         .subscribe(with: self) { vm, _ in
            Task {
               await vm.getInvitation(
                  invitationOutput: invitationOutput,
                  runningInfoEmitter: runningInfoOutput,
                  runningEntryOutput: runningEntryOutput,
                  joinedOutput: joinedOutput
               )
            }
         }
         .disposed(by: disposeBag)
      
      input.dismissButtonTapped
         .subscribe(with: self) { vm, _ in
            Task {
               await vm.joinOrDismissInvitation(
                  isJoined: false,
                  isJoinedEmitter: joinedOutput
               )
            }
         }
         .disposed(by: disposeBag)
      
      input.joinButtonTapped
         .subscribe(with: self) { vm, _ in
            Task {
               await vm.joinOrDismissInvitation(
                  isJoined: true,
                  isJoinedEmitter: joinedOutput
               )
            }
         }
         .disposed(by: disposeBag)
      
      return Output(
         invitationOutput: invitationOutput,
         runningInfoOutput: runningInfoOutput,
         runningEntryOutput: runningEntryOutput,
         joinedOutput: joinedOutput
      )
   }
}

extension InvitationDetailViewModel {
   private func getInvitation(
      invitationOutput: PublishSubject<PostsOutput>,
      runningInfoEmitter: PublishSubject<RunningInfo?>,
      runningEntryOutput: PublishSubject<[BaseProfileType]>,
      joinedOutput: PublishSubject<Bool>
   ) async {
      do {
         let invitation = try await networkManager.request(
            by: PostEndPoint.getPost(input: .init(post_id: invitationId)),
            of: PostsOutput.self)
         self.invitation = invitation
         
         mapRunningInfo(for: invitation.content2, runningInfoEmitter: runningInfoEmitter)
         
         await getInvitors(runningEntryOutput: runningEntryOutput)
         await validJoined(
            for: invitation.likes,
            joinedOutputEmitter: joinedOutput
         )
         
         invitationOutput.onNext(invitation)
      } catch NetworkErrors.needToRefreshRefreshToken {
         await tempLoginAPI()
         await getInvitation(
            invitationOutput: invitationOutput,
            runningInfoEmitter: runningInfoEmitter,
            runningEntryOutput: runningEntryOutput,
            joinedOutput: joinedOutput
         )
      } catch {
         dump(error)
         // TODO: handling Error hear
      }
   }
   
   private func mapRunningInfo(
      for info: String?,
      runningInfoEmitter: PublishSubject<RunningInfo?>
   ) {
      if let info {
         if let json = info.data(using: .utf8) {
            do {
               let runningInfo = try JSONDecoder().decode(RunningInfo.self, from: json)
               runningInfoEmitter.onNext(runningInfo)
            } catch {
               runningInfoEmitter.onNext(nil)
            }
         }
      }
   }
   
   private func getInvitors(
      runningEntryOutput: PublishSubject<[BaseProfileType]>
   ) async {
      if let userIdString = invitation.content1 {
         
         let userIds = userIdString.split(separator: " ").map { String($0) }
         
         await getEntries(from: userIds) { [weak self] profile in
            guard let self else { return }
            self.invitationEntries.append(profile)
         }
         runningEntryOutput.onNext(invitationEntries)
      }
      
   }
   
   private func validJoined(
      for entries: [String],
      joinedOutputEmitter: PublishSubject<Bool>
   ) async {
      do {
         let userId = try await networkManager.request(
            by: UserEndPoint.readMyProfile,
            of: ProfileUserIdOutput.self)
         joinedOutputEmitter.onNext(entries.contains(userId.user_id))
      } catch NetworkErrors.needToRefreshRefreshToken {
         await tempLoginAPI()
         await validJoined(for: entries, joinedOutputEmitter: joinedOutputEmitter)
      } catch {
         joinedOutputEmitter.onNext(false)
      }
   }
   
   private func joinOrDismissInvitation(
      isJoined: Bool,
      isJoinedEmitter: PublishSubject<Bool>
   ) async {
      do {
         let results = try await networkManager.request(
            by: PostEndPoint.postLike(
               input: .init(
                  postId: invitationId,
                  isLike: .init(like_status: isJoined))),
            of: PostLikeOutput.self)
         isJoinedEmitter.onNext(results.like_status)
      } catch NetworkErrors.needToRefreshRefreshToken {
         await tempLoginAPI()
         await joinOrDismissInvitation(
            isJoined: isJoined, isJoinedEmitter: isJoinedEmitter)
      } catch {
         isJoinedEmitter.onNext(false)
      }
   }
}
