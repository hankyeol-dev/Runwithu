//
//  RunnigGroupDetailInfoViewModel.swift
//  runwithu
//
//  Created by 강한결 on 8/26/24.
//

import Foundation

import RxSwift

final class RunnigGroupDetailInfoViewModel: BaseViewModelProtocol {
   let disposeBag: DisposeBag
   let networkManager: NetworkService
   private var groupPost: PostsOutput!
   private var entries: [BaseProfileType] = []
   private var isGroupOwner = false
   
   init(
      disposeBag: DisposeBag,
      networkManager: NetworkService) {
         self.disposeBag = disposeBag
         self.networkManager = networkManager
      }
   
   struct Input {
      let didLoadInput: PublishSubject<Void>
      let groupOutButtonTapped: PublishSubject<Void>
   }
   struct Output{
      let didLoadEntrys: PublishSubject<[BaseProfileType]>
      let isGroupOwnerOutput: PublishSubject<Bool>
      let groupOutOutput: PublishSubject<Bool>
      let errorOutput: PublishSubject<NetworkErrors>
   }
   
   func transform(for input: Input) -> Output {
      let didLoadEntrys = PublishSubject<[BaseProfileType]>()
      let isGroupOwnerOutput = PublishSubject<Bool>()
      let groupOutOutput = PublishSubject<Bool>()
      let errorOutput = PublishSubject<NetworkErrors>()
      
      input.didLoadInput
         .subscribe(with: self) { vm, _ in
            Task {
               await vm.getEntry()
               didLoadEntrys.onNext(vm.entries)
               await vm.validIsGroupOwner(isGroupOwnerEmitter: isGroupOwnerOutput)
            }
         }
         .disposed(by: disposeBag)
      
      input.groupOutButtonTapped
         .subscribe(with: self) { vm, _ in
            Task {
               await vm.groupOut(
                  groupOutEmitter: groupOutOutput,
                  errorEmitter: errorOutput
               )
            }
         }
         .disposed(by: disposeBag)
      
      return Output(
         didLoadEntrys: didLoadEntrys,
         isGroupOwnerOutput: isGroupOwnerOutput,
         groupOutOutput: groupOutOutput,
         errorOutput: errorOutput
      )
   }
   
   func setGroupPosts(by groupPosts: PostsOutput) {
      self.groupPost = groupPosts
   }
   
   func getGroupPost() -> BehaviorSubject<PostsOutput> {
      return BehaviorSubject(value: groupPost)
   }
   
   func getGroupName() -> String { return groupPost.title }
}

extension RunnigGroupDetailInfoViewModel {
   private func getEntry() async {
      await getEntries(from: groupPost.likes) { [weak self] profile in
         guard let self else { return }
         self.entries.append(profile)
      }
   }
   
   private func validIsGroupOwner(
      isGroupOwnerEmitter: PublishSubject<Bool>
   ) async {
      let userId = await UserDefaultsManager.shared.getUserId()
      let isCreator = groupPost.creator.user_id == userId
      let isJoinedGroup = groupPost.likes.contains(userId)
      
      if isJoinedGroup {
         if isCreator {
            isGroupOwnerEmitter.onNext(true)
            return;
         }
      } else {
         isGroupOwnerEmitter.onNext(true)
         return;
      }
      
      isGroupOwnerEmitter.onNext(false)
   }
   
   private func groupOut(
      groupOutEmitter: PublishSubject<Bool>,
      errorEmitter: PublishSubject<NetworkErrors>
   ) async {
      let groupId = groupPost.post_id
      do {
         let outResult = try await networkManager.request(
            by: PostEndPoint.postLike(input: .init(postId: groupId, isLike: .init(like_status: false))),
            of: PostLikeOutput.self).like_status
         groupOutEmitter.onNext(!outResult)
      } catch NetworkErrors.needToRefreshRefreshToken {
         errorEmitter.onNext(.needToLogin)
      } catch {
         errorEmitter.onNext(.invalidResponse)
      }
   }
}
