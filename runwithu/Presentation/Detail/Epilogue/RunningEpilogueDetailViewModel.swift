//
//  RunningEpilogueDetailViewModel.swift
//  runwithu
//
//  Created by 강한결 on 8/27/24.
//

import UIKit

import RxSwift

final class RunningEpilogueDetailViewModel: BaseViewModelProtocol {
   let disposeBag: DisposeBag
   let networkManager: NetworkService
   private let epilogueId: String
   private var epilogueComments: [CommentsOutput] = []
   
   init(
      disposeBag: DisposeBag,
      networkManager: NetworkService,
      epilogueId: String
   ) {
      self.disposeBag = disposeBag
      self.networkManager = networkManager
      self.epilogueId = epilogueId
   }
   
   struct Input {
      let didLoadInput: PublishSubject<Void>
      let commentSendButtonTapped: PublishSubject<String>
   }
   struct Output{
      let didLoadOutput: PublishSubject<PostsOutput>
      let didLoadImageOutput: PublishSubject<[String]>
      let didLoadCommentsOutput: PublishSubject<[CommentsOutput]>
      let errorOutput: PublishSubject<String>
   }
   
   func transform(for input: Input) -> Output {
      let didLoadOutput = PublishSubject<PostsOutput>()
      let didLoadImageOutput = PublishSubject<[String]>()
      let didLoadCommentsOutput = PublishSubject<[CommentsOutput]>()
      let errorOutput = PublishSubject<String>()
      
      input.didLoadInput
         .subscribe(with: self) { vm, _ in
            Task {
               await vm.getEpilogue(
                  successEmitter: didLoadOutput,
                  successImageEmitter: didLoadImageOutput,
                  successCommentsEmitter: didLoadCommentsOutput,
                  errorEmitter: errorOutput
               )
            }
         }
         .disposed(by: disposeBag)
      
      input.commentSendButtonTapped
         .subscribe(with: self) { vm, comment in
            Task {
               await vm.sendComment(
                  comment: comment,
                  successCommentsEmitter: didLoadCommentsOutput,
                  errorEmitter: errorOutput
               )
            }
         }
         .disposed(by: disposeBag)
      
      return Output(
         didLoadOutput: didLoadOutput,
         didLoadImageOutput: didLoadImageOutput,
         didLoadCommentsOutput: didLoadCommentsOutput,
         errorOutput: errorOutput
      )
   }

}

extension RunningEpilogueDetailViewModel {
   private func getEpilogue(
      successEmitter: PublishSubject<PostsOutput>,
      successImageEmitter: PublishSubject<[String]>,
      successCommentsEmitter: PublishSubject<[CommentsOutput]>,
      errorEmitter: PublishSubject<String>
   ) async {
      do {
         let epilogue = try await networkManager.request(
            by: PostEndPoint.getPost(input: .init(post_id: epilogueId)),
            of: PostsOutput.self)
         successEmitter.onNext(epilogue)
         if !epilogue.files.isEmpty {
            successImageEmitter.onNext(epilogue.files)
         }
         if !epilogue.comments.isEmpty {
            epilogueComments = epilogue.comments.reversed()
            successCommentsEmitter.onNext(epilogueComments)
         }
      } catch NetworkErrors.needToRefreshRefreshToken {
         await tempLoginAPI()
         await getEpilogue(
            successEmitter: successEmitter,
            successImageEmitter: successImageEmitter,
            successCommentsEmitter: successCommentsEmitter,
            errorEmitter: errorEmitter
         )
      } catch {
         errorEmitter.onNext("러닝 일지를 조회할 수 없어요 🥹")
      }
      
   }
   
   private func sendComment(
      comment: String,
      successCommentsEmitter: PublishSubject<[CommentsOutput]>,
      errorEmitter: PublishSubject<String>
   ) async {
      do {
         let comments = try await networkManager.request(
            by: PostEndPoint.postComment(
               input: .init(post_id: epilogueId, comment: .init(content: comment))),
            of: CommentsOutput.self)
         epilogueComments.append(comments)
         successCommentsEmitter.onNext(epilogueComments)
      } catch NetworkErrors.needToRefreshRefreshToken {
         await tempLoginAPI()
         await sendComment(
            comment: comment,
            successCommentsEmitter: successCommentsEmitter,
            errorEmitter: errorEmitter
         )
      } catch {
         errorEmitter.onNext("러닝 일지를 조회할 수 없어요 🥹")
      }
   }
}
