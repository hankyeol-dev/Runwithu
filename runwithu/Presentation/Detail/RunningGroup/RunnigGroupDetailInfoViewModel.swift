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
   }
   
   func transform(for input: Input) -> Output {
      let didLoadEntrys = PublishSubject<[BaseProfileType]>()
      let isGroupOwnerOutput = PublishSubject<Bool>()
      
      input.didLoadInput
         .subscribe(with: self) { vm, _ in
            Task {
               await vm.getEntry()
               didLoadEntrys.onNext(vm.entries)
               await vm.validIsGroupOwner(isGroupOwnerEmitter: isGroupOwnerOutput)
            }
         }
         .disposed(by: disposeBag)
      return Output(
         didLoadEntrys: didLoadEntrys,
         isGroupOwnerOutput: isGroupOwnerOutput
      )
   }
   
   func setGroupPosts(by groupPosts: PostsOutput) {
      self.groupPost = groupPosts
   }
   
   func getGroupPost() -> BehaviorSubject<PostsOutput> {
      return BehaviorSubject(value: groupPost)
   }
   
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
}
