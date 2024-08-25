//
//  ProductEpiloguePostViewModel.swift
//  runwithu
//
//  Created by 강한결 on 8/23/24.
//

import Foundation

import RxSwift

final class ProductEpiloguePostViewModel: BaseViewModelProtocol {
   let disposeBag: DisposeBag
   let networkManager: NetworkService
   private let isInGroupSide: Bool
   var selectedImages: [Data] = []
   private lazy var productEpilogueInput: ProductEpilogueInput = .init(
      productId: isInGroupSide ? .runwithu_community_posts_group : .runwithu_community_posts_public,
      title: "",
      content: "",
      productType: "",
      productBrandType: "",
      rating: nil,
      purchasedLink: nil)
   
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
      let brandPickerInput: PublishSubject<String>
      let productTypeInput: PublishSubject<String>
      let titleInput: PublishSubject<String>
      let contentInput: PublishSubject<String>
      let ratingInput: PublishSubject<String>
      let purchaseLinkInput: PublishSubject<String>
      let createButtonTapped: PublishSubject<Void>
   }
   struct Output {
      let successEmitter: PublishSubject<String>
      let errorEmitter: PublishSubject<String>
   }
   
   func transform(for input: Input) -> Output {
      let successEmitter = PublishSubject<String>()
      let errorEmitter = PublishSubject<String>()
      
      bindingToEpilogueInput(for: input.brandPickerInput) { vm, brand in
         vm.productEpilogueInput.productBrandType = brand
      }
      bindingToEpilogueInput(for: input.productTypeInput) { vm, type in
         vm.productEpilogueInput.productType = type
      }
      bindingToEpilogueInput(for: input.titleInput) { vm, title in
         vm.productEpilogueInput.title = title
      }
      bindingToEpilogueInput(for: input.contentInput) { vm, content in
         vm.productEpilogueInput.content = content
      }
      bindingToEpilogueInput(for: input.ratingInput) { vm, rating in
         vm.productEpilogueInput.rating = rating
      }
      bindingToEpilogueInput(for: input.purchaseLinkInput) { vm, link in
         vm.productEpilogueInput.purchasedLink = link
      }
      
      input.createButtonTapped
         .subscribe(with: self) { vm, _ in
            Task {
               await vm.createPost(
                  successEmitter: successEmitter,
                  errorEmitter: errorEmitter
               )
            }
         }
         .disposed(by: disposeBag)
      
      return Output(
         successEmitter: successEmitter,
         errorEmitter: errorEmitter
      )
   }
}

extension ProductEpiloguePostViewModel {
   private func bindingToEpilogueInput(
      for input: PublishSubject<String>,
      by handler: @escaping (ProductEpiloguePostViewModel, String) -> Void
   ) {
      input.subscribe(with: self) { vm, text in
         handler(vm, text)
      }
      .disposed(by: disposeBag)
   }
   
   private func createPost(
      successEmitter: PublishSubject<String>,
      errorEmitter: PublishSubject<String>
   ) async {
      let postValid = validPost()
      
      if postValid {
         let imageFiles = await uploadImages(errorEmitter: errorEmitter)
         let postInput: PostsInput = .init(
            product_id: productEpilogueInput.productId.rawValue,
            title: productEpilogueInput.title,
            content: productEpilogueInput.content,
            content1: productEpilogueInput.communityType.rawValue,
            content2: productEpilogueInput.productBrandType,
            content3: productEpilogueInput.productType,
            content4: productEpilogueInput.rating,
            content5: productEpilogueInput.purchasedLink,
            files: imageFiles)
         
         do {
            let postResults = try await networkManager.request(
               by: PostEndPoint.posts(input: postInput),
               of: PostsOutput.self)
            successEmitter.onNext(postResults.post_id)
         } catch NetworkErrors.needToRefreshRefreshToken {
            await tempLoginAPI()
            await createPost(successEmitter: successEmitter, errorEmitter: errorEmitter)
         } catch {
            errorEmitter.onNext("러닝 일지 작성에 뭔가 문제가 생겼어요.")
         }
      } else {
         errorEmitter.onNext("필수 항목을 모두 채워주세요 :D")
      }
   }
   
   private func uploadImages(
      errorEmitter: PublishSubject<String>
   ) async -> [String] {
      if !selectedImages.isEmpty {
         do {
            let results = try await networkManager.upload(
               by: PostEndPoint.postImageUpload(input: .init(files: selectedImages)),
               of: ImageUploadOutput.self)
            return results.files
         } catch NetworkErrors.invalidRequest {
            errorEmitter.onNext("첨부해주신 이미지 사이즈는 5MB를 넘을 수 없어요.")
            return []
         } catch NetworkErrors.needToRefreshRefreshToken {
            await tempLoginAPI()
            return await uploadImages(errorEmitter: errorEmitter)
         } catch {
            errorEmitter.onNext("이미지 첨부에 실패했어요.")
            return []
         }
      } else {
         return []
      }
   }
   
   private func validPost() -> Bool {
      if productEpilogueInput.title.isEmpty {
         return false
      }
      
      if productEpilogueInput.content.isEmpty {
         return false
      }
      
      if productEpilogueInput.productBrandType.isEmpty {
         return false
      }
      
      if productEpilogueInput.productType.isEmpty {
         return false
      }
      
      return true
   }
}
