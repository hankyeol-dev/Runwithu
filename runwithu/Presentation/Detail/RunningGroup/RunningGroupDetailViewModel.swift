//
//  RunningGroupDetailViewModel.swift
//  runwithu
//
//  Created by 강한결 on 8/26/24.
//

import Foundation

import RxSwift

final class RunningGroupDetailViewModel: BaseViewModelProtocol {
   let disposeBag: DisposeBag
   let networkManager: NetworkService
   private let groupId: String
   private var isJoined: Bool = false
   private var groupPostsOutput: PostsOutput!
   
   init(
      disposeBag: DisposeBag,
      networkManager: NetworkService,
      groupId: String
   ) {
      self.disposeBag = disposeBag
      self.networkManager = networkManager
      self.groupId = groupId
   }
   
   struct Input {
      let didLoadInput: PublishSubject<Void>
   }
   struct Output{
      let didLoadOutput: PublishSubject<PostsOutput>
      let validGroupJoinEmitter: PublishSubject<Bool>
      let errorOutput: PublishSubject<NetworkErrors>
   }
   
   func transform(for input: Input) -> Output {
      let didLoadOutput = PublishSubject<PostsOutput>()
      let validGroupJoinEmitter = PublishSubject<Bool>()
      let errorOutput = PublishSubject<NetworkErrors>()
      
      input.didLoadInput
         .debug("invoked didLoadInput")
         .subscribe(with: self) { vm, _ in
            Task {
               await vm.getGroupPost(
                  successEmitter: didLoadOutput,
                  validGroupJoinEmitter: validGroupJoinEmitter,
                  errorEmitter: errorOutput
               )
            }
         }
         .disposed(by: disposeBag)
      
      return Output(
         didLoadOutput: didLoadOutput,
         validGroupJoinEmitter: validGroupJoinEmitter,
         errorOutput: errorOutput
      )
   }
}

extension RunningGroupDetailViewModel {
   private func getGroupPost(
      successEmitter: PublishSubject<PostsOutput>,
      validGroupJoinEmitter: PublishSubject<Bool>,
      errorEmitter: PublishSubject<NetworkErrors>
   ) async {
      do {
         let postResult = try await networkManager.request(
            by: PostEndPoint.getPost(input: .init(post_id: groupId)),
            of: PostsOutput.self)
         
         groupPostsOutput = postResult
         
         if let content1 = postResult.content1, let entryLimit = Int(content1) {
            isJoined = await validIsJoinedGroup(
               for: postResult.likes,
               limit: entryLimit,
               errorEmitter: errorEmitter
            )
            validGroupJoinEmitter.onNext(isJoined)
            successEmitter.onNext(postResult)
         }
      } catch NetworkErrors.needToRefreshRefreshToken {
         errorEmitter.onNext(.needToLogin)
      } catch {
         errorEmitter.onNext(.dataNotFound)
      }
   }
   
   private func validIsJoinedGroup(
      for likes: [String],
      limit: Int,
      errorEmitter: PublishSubject<NetworkErrors>
   ) async -> Bool {
      do {
         let userId = try await networkManager.request(
            by: UserEndPoint.readMyProfile, of: ProfileUserIdOutput.self)
                  
         return likes.contains(userId.user_id) && ( limit > likes.count )
         
      } catch NetworkErrors.needToRefreshRefreshToken {
         errorEmitter.onNext(.needToLogin)
      } catch {
         return false
      }
      return false
   }
   
   func getGroupPost() -> PostsOutput { return groupPostsOutput }
}
