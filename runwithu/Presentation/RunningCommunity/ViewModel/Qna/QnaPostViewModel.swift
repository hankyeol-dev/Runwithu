//
//  QnaPostViewModel.swift
//  runwithu
//
//  Created by 강한결 on 8/23/24.
//

import Foundation

import RxSwift

final class QnaPostViewModel: BaseViewModelProtocol {
   let disposeBag: DisposeBag
   let networkManager: NetworkService
   private let isInGroupSide: Bool
   private lazy var qnaInput: QnaInput = .init(
      productId: isInGroupSide ? .runwithu_community_posts_group: .runwithu_community_posts_public,
      title: "",
      content: "",
      qnaType: "")
   private var qnaPostId = ""
   
   init(
      disposeBag: DisposeBag,
      networkManager: NetworkService,
      isInGroupSide: Bool
   ) {
      self.disposeBag = disposeBag
      self.networkManager = networkManager
      self.isInGroupSide = isInGroupSide
   }
   
   struct Input {
      let qnaTypePickerInput: PublishSubject<String>
      let titleInput: PublishSubject<String>
      let contentInput: PublishSubject<String>
      let createButtonTapped: PublishSubject<Void>
   }
   struct Output {
      let successEmitter: PublishSubject<Void>
      let errorEmitter: PublishSubject<String>
   }
   
   func transform(for input: Input) -> Output {
      let successEmitter = PublishSubject<Void>()
      let errorEmitter = PublishSubject<String>()
      
      bindingQnaInput(for: input.qnaTypePickerInput) { vm, type in
         vm.qnaInput.qnaType = type
      }
      bindingQnaInput(for: input.titleInput) { vm, title in
         vm.qnaInput.title = title
      }
      bindingQnaInput(for: input.contentInput) { vm, content in
         vm.qnaInput.content = content
      }
      
      input.createButtonTapped
         .subscribe(with: self) { vm, _ in
            Task {
               await vm.createPost(successEmitter: successEmitter, errorEmitter: errorEmitter)
            }
         }
         .disposed(by: disposeBag)
      
      return Output(
         successEmitter: successEmitter, errorEmitter: errorEmitter
      )
   }
}

extension QnaPostViewModel {
   private func bindingQnaInput(
      for input: PublishSubject<String>,
      by handler: @escaping (QnaPostViewModel, String) -> Void
   ) {
      input.subscribe(with: self) { vm, text in
         handler(vm, text)
      }
      .disposed(by: disposeBag)
   }
   
   private func validPost() -> Bool {
      if qnaInput.qnaType.isEmpty {
         return false
      }
      
      if qnaInput.title.isEmpty {
         return false
      }
      
      if qnaInput.content.isEmpty {
         return false
      }
      
      return true
   }
   
   private func createPost(
      successEmitter: PublishSubject<Void>,
      errorEmitter: PublishSubject<String>
   ) async {
      if !validPost() {
         errorEmitter.onNext("필수 항목을 모두 채워주세요 :D")
         return
      }
      
      let postInput: PostsInput = .init(
         product_id: qnaInput.productId.rawValue,
         title: qnaInput.title,
         content: qnaInput.content,
         content1: qnaInput.communityType.rawValue,
         content2: qnaInput.qnaType,
         content3: nil,
         content4: nil,
         content5: nil, files: nil)
      
      do {
         
         let postResult = try await networkManager.request(
            by: PostEndPoint.posts(input: postInput),
            of: PostsOutput.self)
         qnaPostId = postResult.post_id
         successEmitter.onNext(())
      } catch NetworkErrors.needToRefreshRefreshToken {
         await tempLoginAPI()
         await createPost(successEmitter: successEmitter, errorEmitter: errorEmitter)
      } catch {
         errorEmitter.onNext("러닝 일지 작성에 뭔가 문제가 생겼어요.")
      }
   }
   
   func getGeneratedQnaPostId() -> String {
      return qnaPostId
   }
}
