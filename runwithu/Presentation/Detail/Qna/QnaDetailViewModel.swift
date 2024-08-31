//
//  QnaDetailViewModel.swift
//  runwithu
//
//  Created by 강한결 on 8/25/24.
//

import Foundation

import RxSwift

final class QnaDetailViewModel: BaseViewModelProtocol {
   let disposeBag: DisposeBag
   let networkManager: NetworkService
   private let qnaId: String
   private var comments: [CommentsOutput] = []
   
   init(disposeBag: DisposeBag, networkManager: NetworkService, qnaId: String) {
      self.disposeBag = disposeBag
      self.networkManager = networkManager
      self.qnaId = qnaId
   }
   
   struct Input {
      let didLoadInput: PublishSubject<Void>
      let commentsSendButtonTapped: PublishSubject<String>
   }
   struct Output {
      let didLoadOutput: PublishSubject<PostsOutput>
      let commentsEmitter: BehaviorSubject<[CommentsOutput]>
      let errorEmitter: PublishSubject<NetworkErrors>
   }
   
   func transform(for input: Input) -> Output {
      let didLoadOutput = PublishSubject<PostsOutput>()
      let commentsEmitter = BehaviorSubject<[CommentsOutput]>(value: comments)
      let errorEmitter = PublishSubject<NetworkErrors>()
      
      input.didLoadInput
         .subscribe(with: self) { vm, _ in
            Task {
               await vm.getPost(
                  successEmitter: didLoadOutput,
                  commentsEmitter: commentsEmitter,
                  errorEmitter: errorEmitter
               )
            }
         }
         .disposed(by: disposeBag)
      
      input.commentsSendButtonTapped
         .subscribe(with: self) { vm, comment in
            Task {
               await vm.createComment(
                  for: comment,
                  successEmitter: commentsEmitter,
                  errorEmitter: errorEmitter
               )
            }
         }
         .disposed(by: disposeBag)
      
      return Output(
         didLoadOutput: didLoadOutput,
         commentsEmitter: commentsEmitter,
         errorEmitter: errorEmitter
      )
   }
}

extension QnaDetailViewModel {
   private func getPost(
      successEmitter: PublishSubject<PostsOutput>,
      commentsEmitter: BehaviorSubject<[CommentsOutput]>,
      errorEmitter: PublishSubject<NetworkErrors>
   ) async {
      do {
         let results = try await networkManager.request(
            by: PostEndPoint.getPost(input: .init(post_id: qnaId)),
            of: PostsOutput.self)
         
         successEmitter.onNext(results)
         comments = results.comments
         commentsEmitter.onNext(comments)
      } catch NetworkErrors.needToRefreshRefreshToken {
         errorEmitter.onNext(.needToLogin)
      } catch {
         errorEmitter.onNext(.dataNotFound)
      }
   }
   
   private func createComment(
      for comment: String,
      successEmitter: BehaviorSubject<[CommentsOutput]>,
      errorEmitter: PublishSubject<NetworkErrors>
   ) async {
      let commentInput: CommentsInput = .init(
         post_id: qnaId,
         comment: .init(content: comment)
      )
      
      do {
         let results = try await networkManager.request(
            by: PostEndPoint.postComment(input: commentInput),
            of: CommentsOutput.self)
         comments.append(results)
         successEmitter.onNext(comments)
      } catch NetworkErrors.needToRefreshRefreshToken {
         errorEmitter.onNext(.needToLogin)
      } catch {
         errorEmitter.onNext(.writeCommentError)
      }
   }
}
