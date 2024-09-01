//
//  RunningGroupListViewModel.swift
//  runwithu
//
//  Created by 강한결 on 8/20/24.
//

import Foundation

import RxSwift

final class RunningGroupListViewModel: BaseViewModelProtocol {
   let disposeBag: DisposeBag
   let networkManager: NetworkService
   
   init(
      disposeBag: DisposeBag,
      networkManager: NetworkService
   ) {
      self.disposeBag = disposeBag
      self.networkManager = networkManager
   }
   
   struct Input {
      let willLoadInput: PublishSubject<Void>
      let groupCreateButtonTapped: PublishSubject<Void>
   }
   struct Output {
      let floatingButtonTapped: PublishSubject<Void>
      let userCreatedGroupOutput: PublishSubject<[PostsOutput]>
      let userJoinedGroupOutput: PublishSubject<[PostsOutput]>
      let runningGroupOutput: PublishSubject<[PostsOutput]>
   }
   
   func transform(for input: Input) -> Output {
      let userCreatedGroupOutput = PublishSubject<[PostsOutput]>()
      let userJoinedGroupOutput = PublishSubject<[PostsOutput]>()
      let runningGroupOutput = PublishSubject<[PostsOutput]>()
      let errorOutput = PublishSubject<NetworkErrors>()
      
      input.willLoadInput
         .subscribe(with: self) { vm, _ in
            Task {
               await vm.getRunningGroupPosts(
                  userCreatedGroupOutput: userCreatedGroupOutput,
                  userJoinedGroupOutput: userJoinedGroupOutput,
                  runningGroupOutput: runningGroupOutput,
                  errorEmitter: errorOutput
               )
            }
         }
         .disposed(by: disposeBag)
      
      return Output(
         floatingButtonTapped: input.groupCreateButtonTapped,
         userCreatedGroupOutput: userCreatedGroupOutput,
         userJoinedGroupOutput: userJoinedGroupOutput,
         runningGroupOutput: runningGroupOutput
      )
   }
}

extension RunningGroupListViewModel {
   private func getRunningGroupPosts(
      userCreatedGroupOutput: PublishSubject<[PostsOutput]>,
      userJoinedGroupOutput: PublishSubject<[PostsOutput]>,
      runningGroupOutput: PublishSubject<[PostsOutput]>,
      errorEmitter: PublishSubject<NetworkErrors>
   ) async {
      do {
         let posts = try await networkManager.request(
            by: PostEndPoint.getPosts(input: .init(
               product_id: ProductIds.runwithu_running_group.rawValue,
               limit: 1000,
               next: nil)),
            of: GetPostsOutput.self).data
         
         let userId = await UserDefaultsManager.shared.getUserId()
         
         if let first = posts.filter({ $0.creator.user_id == userId }).first {
            userCreatedGroupOutput.onNext([first])
         }
         
         let userJoinedGroup = posts.filter({ $0.likes.contains(userId) })
         userJoinedGroupOutput.onNext(userJoinedGroup)
         
         let userNotJoinedOrCreated = posts.filter({ $0.creator.user_id != userId && !$0.likes.contains(userId) })
         runningGroupOutput.onNext(userNotJoinedOrCreated)
         
      } catch NetworkErrors.needToRefreshRefreshToken {
         await autoLoginCheck { [weak self] isAutoLoginSuccess in
            guard let self else { return }
            if isAutoLoginSuccess {
               Task {
                  await self.getRunningGroupPosts(
                     userCreatedGroupOutput: userCreatedGroupOutput,
                     userJoinedGroupOutput: userJoinedGroupOutput,
                     runningGroupOutput: runningGroupOutput,
                     errorEmitter: errorEmitter
                  )
               }
            } else {
               errorEmitter.onNext(.needToLogin)
            }
         } autoLoginErrorHandler: {
            errorEmitter.onNext(.needToLogin)
         }
      } catch {
         errorEmitter.onNext(.dataNotFound)
      }
   }
}
