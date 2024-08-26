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
   }
   
   func transform(for input: Input) -> Output {
      let didLoadOutput = PublishSubject<PostsOutput>()
      let validGroupJoinEmitter = PublishSubject<Bool>()
      
      input.didLoadInput
         .debug("invoked didLoadInput")
         .subscribe(with: self) { vm, _ in
            Task {
               await vm.getGroupPost(
                  successEmitter: didLoadOutput,
                  validGroupJoinEmitter: validGroupJoinEmitter
               )
            }
         }
         .disposed(by: disposeBag)
      
      return Output(
         didLoadOutput: didLoadOutput,
         validGroupJoinEmitter: validGroupJoinEmitter
      )
   }
}

extension RunningGroupDetailViewModel {
   private func getGroupPost(
      successEmitter: PublishSubject<PostsOutput>,
      validGroupJoinEmitter: PublishSubject<Bool>
   ) async {
      do {
         let postResult = try await networkManager.request(
            by: PostEndPoint.getPost(input: .init(post_id: groupId)),
            of: PostsOutput.self)
         groupPostsOutput = postResult
         if let content1 = postResult.content1, let entryLimit = Int(content1) {
            isJoined = await validIsJoinedGroup(for: postResult.likes, limit: entryLimit)
            validGroupJoinEmitter.onNext(isJoined)
            successEmitter.onNext(postResult)
         }
      } catch NetworkErrors.needToRefreshRefreshToken {
         await tempLoginAPI()
         await getGroupPost(successEmitter: successEmitter, validGroupJoinEmitter: validGroupJoinEmitter)
      } catch {
         dump(error)
      }
   }
   
   private func validIsJoinedGroup(for likes: [String], limit: Int) async -> Bool {
      do {
         let userId = try await networkManager.request(
            by: UserEndPoint.readMyProfile, of: ProfileUserIdOutput.self)
                  
         return likes.contains(userId.user_id) && ( limit > likes.count )
         
      } catch NetworkErrors.needToRefreshRefreshToken {
         await tempLoginAPI()
         return await validIsJoinedGroup(for: likes, limit: limit)
      } catch {
         dump(error)
         return false
      }
   }
   
   func getGroupPost() -> PostsOutput {
      return groupPostsOutput
   }
}
