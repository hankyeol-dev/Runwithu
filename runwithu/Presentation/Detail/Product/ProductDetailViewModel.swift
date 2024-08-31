//
//  ProductDetailViewModel.swift
//  runwithu
//
//  Created by 강한결 on 8/30/24.
//

import Foundation

import RxSwift

final class ProductDetailViewModel: BaseViewModelProtocol {
   let disposeBag: DisposeBag
   let networkManager: NetworkService
   private let detailPost: PostsOutput
   private var detailComments: [CommentsOutput] = []
   
   init(
      disposeBag: DisposeBag,
      networkManager: NetworkService,
      detailPost: PostsOutput
   ) {
      self.disposeBag = disposeBag
      self.networkManager = networkManager
      self.detailPost = detailPost
   }
   
   struct Input {
      let didLoadInput: PublishSubject<Void>
      let commentSendButtonTapped: PublishSubject<String>
   }
   struct Output{
      let didLoatOutput: PublishSubject<PostsOutput>
      let commentsOutput: PublishSubject<[CommentsOutput]>
      let errorOutput: PublishSubject<NetworkErrors>
   }
   
   func transform(for input: Input) -> Output {
      let didLoadOutput = PublishSubject<PostsOutput>()
      let commentsOutput = PublishSubject<[CommentsOutput]>()
      let errorOutput = PublishSubject<NetworkErrors>()
      
      input.didLoadInput
         .subscribe(with: self) { vm, _ in
            didLoadOutput.onNext(vm.detailPost)
            vm.detailComments = vm.detailPost.comments
            commentsOutput.onNext(vm.detailComments)
         }
         .disposed(by: disposeBag)
      
      input.commentSendButtonTapped
         .subscribe(with: self) { vm, comment in
            Task {
               await vm.sendComment(
                  comment: comment,
                  successEmitter: commentsOutput,
                  errorEmitter: errorOutput
               )
            }
         }
         .disposed(by: disposeBag)
      
      return Output(
         didLoatOutput: didLoadOutput,
         commentsOutput: commentsOutput,
         errorOutput: errorOutput
      )
   }
}

extension ProductDetailViewModel {
   private func sendComment(
      comment: String,
      successEmitter: PublishSubject<[CommentsOutput]>,
      errorEmitter: PublishSubject<NetworkErrors>
   ) async {
      do {
         let commentsResult = try await networkManager.request(
            by: PostEndPoint.postComment(input: .init(post_id: detailPost.post_id, comment: .init(content: comment))),
            of: CommentsOutput.self)
         detailComments.append(commentsResult)
         successEmitter.onNext(detailComments)
      } catch NetworkErrors.needToRefreshRefreshToken {
         errorEmitter.onNext(.needToLogin)
      } catch {
         errorEmitter.onNext(.dataNotFound)
      }
   }
}
