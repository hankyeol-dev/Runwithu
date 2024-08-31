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
   private var userId: String!
   private var entries: [BaseProfileType] = []
   
   init(
      disposeBag: DisposeBag,
      networkManager: NetworkService) {
         self.disposeBag = disposeBag
         self.networkManager = networkManager
      }
   
   struct Input {
      let didLoadInput: PublishSubject<Void>
   }
   struct Output{
      let didLoadEntrys: PublishSubject<[BaseProfileType]>
   }
   
   func transform(for input: Input) -> Output {
      let didLoadEntrys = PublishSubject<[BaseProfileType]>()
      
      input.didLoadInput
         .subscribe(with: self) { vm, _ in
            Task {
               await vm.getEntry()
               dump(vm.entries)
               didLoadEntrys.onNext(vm.entries)
            }
         }
         .disposed(by: disposeBag)
      return Output(
         didLoadEntrys: didLoadEntrys
      )
   }
   
   func setGroupPosts(by groupPosts: PostsOutput) {
      self.groupPost = groupPosts
   }
   
   func getGroupPost() -> BehaviorSubject<PostsOutput> {
      return BehaviorSubject(value: groupPost)
   }
   
   private func getUseRrofile() async {
      userId = await UserDefaultsManager.shared.getUserId()
   }
   
   private func getEntry() async {
      await getEntries(from: groupPost.likes) { [weak self] profile in
         guard let self else { return }
         self.entries.append(profile)
      }
   }
}
