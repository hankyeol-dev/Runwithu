//
//  ProfileViewModel.swift
//  runwithu
//
//  Created by 강한결 on 8/21/24.
//

import Foundation

import RxSwift

final class ProfileViewModel: BaseViewModelProtocol {
   let disposeBag: DisposeBag
   let networkManager: NetworkService
   private let isUserProfile: Bool
   private var isFollowing = false
   private var userId: String?
   private var username = "" // 성공했다면, 무조건 있으니까.
   
   struct Input {
      let didLoad: PublishSubject<Void>
      let followButtonTapped: PublishSubject<Void>
      let createInvitationButtonTapped: PublishSubject<Void>
   }
   struct Output {
      let createInvitationButtonTapped: PublishSubject<(String, String)>
      let followStateOutput: PublishSubject<Bool>
      let filteredPostsOutput: PublishSubject<[String: [PostsOutput]]>
      let getProfileEmitter: PublishSubject<(ProfileOutput?, String?)>
      let errorEmitter: PublishSubject<String>
   }
   
   init(
      disposeBag: DisposeBag,
      networkManager: NetworkService,
      isUserProfile: Bool,
      userId: String? = nil
   ) {
      self.disposeBag = disposeBag
      self.networkManager = networkManager
      self.isUserProfile = isUserProfile
      self.userId = userId
   }
   
   func transform(for input: Input) -> Output {
      let createInvitationButtonTapped = PublishSubject<(String, String)>()
      let followStateOutput = PublishSubject<Bool>()
      let filteredPostsOutput = PublishSubject<[String: [PostsOutput]]>()
      let getProfileEmitter = PublishSubject<(ProfileOutput?, String?)>()
      let errorEmitter = PublishSubject<String>()
      
      input.didLoad
         .subscribe(with: self) { vm, _ in
            Task {
               await vm.getUserProfile(
                  getProfileEmitter: getProfileEmitter,
                  followStateEmitter: followStateOutput,
                  filteredPostsEmitter: filteredPostsOutput
               )
            }
         }
         .disposed(by: disposeBag)
      
      input.followButtonTapped
         .subscribe(with: self) { vm, _ in
            Task {
               await vm.followingUser(
                  followStateEmitter: followStateOutput,
                  errorEmitter: errorEmitter) {
                     Task {
                        await vm.getUserProfile(
                           getProfileEmitter: getProfileEmitter,
                           followStateEmitter: followStateOutput,
                           filteredPostsEmitter: filteredPostsOutput
                        )
                     }
                  }
            }
         }
         .disposed(by: disposeBag)
      
      input.createInvitationButtonTapped
         .subscribe(with: self) { vm, _ in
            if let userId = vm.userId {
               createInvitationButtonTapped.onNext((userId, vm.username))
            }
         }
         .disposed(by: disposeBag)
      
      return Output(
         createInvitationButtonTapped: createInvitationButtonTapped,
         followStateOutput: followStateOutput,
         filteredPostsOutput: filteredPostsOutput,
         getProfileEmitter: getProfileEmitter,
         errorEmitter: errorEmitter
      )
   }
   
   func getUserProfileState() -> Bool {
      return isUserProfile
   }
   
   func getIsFollowing() -> Bool {
      return isFollowing
   }
   
   func getUsername() -> String {
      return username
   }
}

extension ProfileViewModel {
   private func getUserProfile(
      getProfileEmitter: PublishSubject<(ProfileOutput?, String?)>,
      followStateEmitter: PublishSubject<Bool>,
      filteredPostsEmitter: PublishSubject<[String: [PostsOutput]]>
   ) async {
      do {
         var results: ProfileOutput
         let myId = try await networkManager.request(by: UserEndPoint.readMyProfile, of: ProfileUserIdOutput.self).user_id
         
         if isUserProfile {
            results = try await networkManager.request(
               by: UserEndPoint.readMyProfile,
               of: ProfileOutput.self
            )
         } else {
            guard let userId else { return }
            results = try await networkManager.request(
               by: UserEndPoint.readAnotherProfile(input: .init(user_id: userId)),
               of: ProfileOutput.self
            )
         }
         userId = results.user_id
         username = results.nick
         if !isUserProfile {
            isFollowing = results.followers.contains { profile in
               profile.user_id == myId
            }
            print(isFollowing)
            followStateEmitter.onNext(isFollowing)
         }
         await filterPosts(postIds: results.posts, filteredPostsEmitter: filteredPostsEmitter)
         getProfileEmitter.onNext((results, nil))
         
      } catch NetworkErrors.needToRefreshRefreshToken {
         await tempLoginAPI()
         await getUserProfile(
            getProfileEmitter: getProfileEmitter,
            followStateEmitter: followStateEmitter,
            filteredPostsEmitter: filteredPostsEmitter
         )
      } catch {
         getProfileEmitter.onNext((nil, "뭔가 문제가 발생했습니다."))
      }
   }
   
   private func filterPosts(
      postIds: [String],
      filteredPostsEmitter: PublishSubject<[String: [PostsOutput]]>
   ) async {
      if !postIds.isEmpty {
         var postsList: [PostsOutput] = []
         await withTaskGroup(of: PostsOutput?.self) { groups in
            for id in postIds {
               groups.addTask { [weak self] in
                  guard let self else { return nil }
                  do {
                     return try await self.networkManager.request(
                        by: PostEndPoint.getPost(input: .init(post_id: id)),
                        of: PostsOutput.self
                     )
                  } catch {
                     return nil
                  }
               }
               
            }
            for await post in groups {
               if let post {
                  postsList.append(post)
               }
            }
         }
         
         var postsFilterList: [String: [PostsOutput]] = [:]
         
         postsList.forEach { post in
            if post.product_id == ProductIds.runwithu_community_posts_public.rawValue,
               let content1 = post.content1 {
               if var target = postsFilterList[content1] {
                  target.append(post)
                  postsFilterList[content1] = target
               } else {
                  postsFilterList[content1] = [post]
               }
            }
            
            if post.product_id == ProductIds.runwithu_running_group.rawValue
                  || post.product_id == ProductIds.runwithu_running_inviation.rawValue {
               if var target = postsFilterList[post.product_id] {
                  target.append(post)
                  postsFilterList[post.product_id] = target
               } else {
                  postsFilterList[post.product_id] = [post]
               }
            }
         }
         filteredPostsEmitter.onNext(postsFilterList)
      }
   }
   
   private func followingUser(
      followStateEmitter: PublishSubject<Bool>,
      errorEmitter: PublishSubject<String>,
      successCompletionHandler: @escaping () -> Void
   ) async {
      if !isUserProfile, let userId {
         let followInput: FollowInput = .init(user_id: userId, isFollowing: isFollowing)
         
         do {
            let followResult = try await networkManager.request(
               by: UserEndPoint.follow(input: followInput),
               of: FollowOutput.self)
            isFollowing = followResult.following_status
            followStateEmitter.onNext(isFollowing)
            successCompletionHandler()
         } catch NetworkErrors.needToRefreshRefreshToken {
            await tempLoginAPI()
            await followingUser(
               followStateEmitter: followStateEmitter,
               errorEmitter: errorEmitter,
               successCompletionHandler: successCompletionHandler
            )
         } catch {
            errorEmitter.onNext("팔로잉 과정에서 문제가 발생했어요.")
         }
      }
   }
}
