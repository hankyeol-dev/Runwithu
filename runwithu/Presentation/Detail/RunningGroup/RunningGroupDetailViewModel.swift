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
      let epiloguePostsOutput: PublishSubject<[PostsOutput]>
      let productPostsOutput: PublishSubject<[PostsOutput]>
      let qnaPostsOutput: PublishSubject<[PostsOutput]>
   }
   
   func transform(for input: Input) -> Output {
      let didLoadOutput = PublishSubject<PostsOutput>()
      let validGroupJoinEmitter = PublishSubject<Bool>()
      let errorOutput = PublishSubject<NetworkErrors>()
      let epiloguePostsOutput = PublishSubject<[PostsOutput]>()
      let productPostsOutput = PublishSubject<[PostsOutput]>()
      let qnaPostsOutput = PublishSubject<[PostsOutput]>()
      
      input.didLoadInput
         .subscribe(with: self) { vm, _ in
            Task {
               await vm.getGroupInfo(
                  successEmitter: didLoadOutput,
                  validGroupJoinEmitter: validGroupJoinEmitter,
                  errorEmitter: errorOutput
               )
               await vm.getGroupPosts(
                  epiloguePostsEmitter: epiloguePostsOutput,
                  productPostsEmitter: productPostsOutput,
                  qnaPostsEmitter: qnaPostsOutput,
                  errorEmitter: errorOutput
               )
            }
         }
         .disposed(by: disposeBag)
      
      return Output(
         didLoadOutput: didLoadOutput,
         validGroupJoinEmitter: validGroupJoinEmitter,
         errorOutput: errorOutput,
         epiloguePostsOutput: epiloguePostsOutput,
         productPostsOutput: productPostsOutput,
         qnaPostsOutput: qnaPostsOutput
      )
   }
   
   func getGroup() -> PostsOutput { return groupPostsOutput }
}

extension RunningGroupDetailViewModel {
   private func getGroupInfo(
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
   
   private func getGroupPosts(
      epiloguePostsEmitter: PublishSubject<[PostsOutput]>,
      productPostsEmitter: PublishSubject<[PostsOutput]>,
      qnaPostsEmitter: PublishSubject<[PostsOutput]>,
      errorEmitter: PublishSubject<NetworkErrors>
   ) async {
      do {
         let groupPosts = try await networkManager.request(
            by: PostEndPoint.getPosts(
               input: .init(
                  product_id: ProductIds.runwithu_community_posts_group.rawValue + "_" + groupId,
                  limit: 100000,
                  next: nil)),
            of: GetPostsOutput.self).data
         
         let epilogues = filterGroupPost(for: groupPosts, by: .epilogues)
         let products = filterGroupPost(for: groupPosts, by: .product_epilogues)
         let qnas = filterGroupPost(for: groupPosts, by: .qnas)
         
         epiloguePostsEmitter.onNext(epilogues)
         productPostsEmitter.onNext(products)
         qnaPostsEmitter.onNext(qnas)
         
      } catch NetworkErrors.needToRefreshRefreshToken {
         errorEmitter.onNext(.needToLogin)
      } catch {
         errorEmitter.onNext(.dataNotFound)
      }
   }
   
   private func filterGroupPost(for groupPosts: [PostsOutput], by: PostsCommunityType) -> [PostsOutput] {
      return groupPosts.filter { post in
         if let communityType = post.content1 {
            return communityType == by.rawValue
         }
         return false
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
                  
         if likes.contains(userId.user_id) && ( limit > likes.count ) {
            return true
         }
         
         if groupPostsOutput.creator.user_id == userId.user_id {
            return true
         }
         
         return false
         
      } catch NetworkErrors.needToRefreshRefreshToken {
         errorEmitter.onNext(.needToLogin)
      } catch {
         return false
      }
      return false
   }
   
   
}
