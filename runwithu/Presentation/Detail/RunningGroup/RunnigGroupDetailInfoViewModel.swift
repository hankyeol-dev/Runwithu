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
               await vm.getEntries()
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
   
   private func getEntries() async {
      if !groupPost.likes.isEmpty {
         await withTaskGroup(of: BaseProfileType?.self) { [weak self] taskGroup in
            guard let self else { return }
            for like in self.groupPost.likes {
               taskGroup.addTask {
                  if let entry = await self.getEntry(for: like) {
                     return entry
                  } else {
                     return nil
                  }
               }
            }
            
            for await entry in taskGroup {
               if let entry {
                  self.entries.append(entry)
               }
            }
         }
      }
   }
   
   private func getEntry(for userId: String) async -> BaseProfileType? {
      return await withCheckedContinuation { continuation in
         Task {
            do {
               let result = try await networkManager.request(
                  by: UserEndPoint.readAnotherProfile(input: .init(user_id: userId)),
                  of: BaseProfileType.self)
               continuation.resume(returning: result)
            } catch NetworkErrors.needToRefreshRefreshToken {
               await self.tempLoginAPI()
               continuation.resume(returning: await self.getEntry(for: userId))
            } catch {
               continuation.resume(returning: nil)
            }
         }
      }
   }
}
