//
//  RunningCommunityViewModel.swift
//  runwithu
//
//  Created by 강한결 on 8/23/24.
//

import Foundation

import RxSwift

final class RunningCommunityViewModel: BaseViewModelProtocol {
   let disposeBag: DisposeBag
   let networkManager: NetworkService
   private var communityMenuItems: [CommunityMenuCellItem]
   = PostsCommunityType.allCases.filter{ $0 != .open_self_marathons }.enumerated().map { index, menu in
         .init(menu: menu, isSelected: index == 0 ? true : false)
   }
   
   init(
      disposeBag: DisposeBag,
      networkManager: NetworkService
   ) {
      self.disposeBag = disposeBag
      self.networkManager = networkManager
   }
   
   struct Input {
      let didLoadInput: PublishSubject<Void>
      let writeButtonTapped: PublishSubject<Void>
      let bottomSheetItemTapped: PublishSubject<BottomSheetSelectedItem>
      let communityTypeSelected: PublishSubject<Int>
   }
   struct Output {
      let communityMenuOutput: PublishSubject<[CommunityMenuCellItem]>
      let writeButtonTapped: PublishSubject<[BottomSheetSelectedItem]>
      let bottomSheetItemTapped: PublishSubject<PostsCommunityType>
      let communityPostsOutput: PublishSubject<(PostsCommunityType,[PostsOutput])>
      let errorOutput: PublishSubject<NetworkErrors>
   }
   
   func transform(for input: Input) -> Output {
      let communityMenuOutput = PublishSubject<[CommunityMenuCellItem]>()
      let writeButtonTapped = PublishSubject<[BottomSheetSelectedItem]>()
      let bottomSheetItemTapped = PublishSubject<PostsCommunityType>()
      let communityPostsOutput = PublishSubject<(PostsCommunityType,[PostsOutput])>()
      let errorOutput = PublishSubject<NetworkErrors>()
      
      input.didLoadInput
         .subscribe(with: self) { vm, _ in
            communityMenuOutput.onNext(vm.communityMenuItems)
            Task {
               await vm.getPosts(
                  successEmitter: communityPostsOutput,
                  errorEmitter: errorOutput
               )
            }
         }
         .disposed(by: disposeBag)
      
      input.writeButtonTapped
         .bind(with: self) { vm, _ in
            writeButtonTapped.onNext(
               PostsCommunityType.allCases.map {
                  .init(
                     image: $0.byTitleImage,
                     title: $0.byKoreanTitle,
                     isSelected: false)
               }
            )
         }
         .disposed(by: disposeBag)
      
      input.bottomSheetItemTapped
         .subscribe(with: self) { vm, item in
            guard let type = vm.bindingToCommunityType(for: item) else {
               return
            }
            bottomSheetItemTapped.onNext(type)
         }
         .disposed(by: disposeBag)
      
      input.communityTypeSelected
         .subscribe(with: self) { vm, row in
            let updateItems = vm.communityMenuItems.enumerated().map { index, item in
               CommunityMenuCellItem(menu: item.menu, isSelected: index == row ? true : false)
            }
            vm.communityMenuItems = updateItems
            communityMenuOutput.onNext(vm.communityMenuItems)
            Task {
               await vm.getPosts(
                  successEmitter: communityPostsOutput,
                  errorEmitter: errorOutput
               )
            }
         }
         .disposed(by: disposeBag)
      
      return Output(
         communityMenuOutput: communityMenuOutput,
         writeButtonTapped: writeButtonTapped,
         bottomSheetItemTapped: bottomSheetItemTapped,
         communityPostsOutput: communityPostsOutput,
         errorOutput: errorOutput
      )
   }
}

extension RunningCommunityViewModel {
   private func bindingToCommunityType(
      for item: BottomSheetSelectedItem
   ) -> PostsCommunityType? {
      
      switch item.title {
      case PostsCommunityType.epilogues.byKoreanTitle:
         return .epilogues
      case PostsCommunityType.product_epilogues.byKoreanTitle:
         return .product_epilogues
      case PostsCommunityType.qnas.byKoreanTitle:
         return .qnas
      case PostsCommunityType.open_self_marathons.byKoreanTitle:
         return .open_self_marathons
      default:
         return nil
      }
   }
   
   private func getPosts(
      successEmitter: PublishSubject<(PostsCommunityType,[PostsOutput])>,
      errorEmitter: PublishSubject<NetworkErrors>
   ) async {
      if let communityType = communityMenuItems.filter({ $0.isSelected }).first {
         do {
            let posts = try await networkManager.request(
               by: PostEndPoint.getPosts(
                  input: .init(
                     product_id: ProductIds.runwithu_community_posts_public.rawValue,
                     limit: 10000,
                     next: nil)
               ),
               of: GetPostsOutput.self
            )
            
            let filteredPosts = posts.data.filter { post in
               if let type = post.content1 {
                  return type == communityType.menu.rawValue
               } else {
                  return false
               }
            }
            successEmitter.onNext((communityType.menu, filteredPosts))
         } catch NetworkErrors.needToRefreshRefreshToken {
            await autoLoginCheck { success in
               if success {
                  Task {
                     await self.getPosts(successEmitter: successEmitter, errorEmitter: errorEmitter)
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
}
