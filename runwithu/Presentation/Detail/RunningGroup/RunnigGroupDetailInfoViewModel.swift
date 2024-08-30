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
      do {
         let userIdResult = try await networkManager.request(
            by: UserEndPoint.readMyProfile,
            of: ProfileUserIdOutput.self)
         userId = userIdResult.user_id
      } catch NetworkErrors.needToRefreshRefreshToken {
         await tempLoginAPI()
         await getUseRrofile()
      } catch {
         // TODO: 로그아웃 로직이 오는게 맞을 듯
         dump(error)
      }
   }
   
   private func getEntry() async {
      await getEntries(from: groupPost.likes) { [weak self] profile in
         guard let self else { return }
         self.entries.append(profile)
      }
   }
}