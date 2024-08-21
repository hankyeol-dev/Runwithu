//
//  RunningGroupCreateViewModel.swift
//  runwithu
//
//  Created by 강한결 on 8/19/24.
//

import Foundation

import RxSwift

final class RunningGroupCreateViewModel: BaseViewModelProtocol {
   private let disposeBag = DisposeBag()
   private let tokenManager = TokenManager.shared
   private let networkManager = NetworkService.shared
   
   private var postGroupInput = CreateRunningGroupInput(
      title: "",
      content: "",
      entryLimit: "",
      mainSpot: "",
      runningHardType: ""
   )
   
   struct Input {
      let groupName: PublishSubject<String>
      let groupEntryLimit: PublishSubject<String>
      let groupDescription: PublishSubject<String>
      let groupSpot: PublishSubject<String>
      let groupHardType: PublishSubject<String>
      let createButtonTapped: PublishSubject<Void>
   }
   
   struct Output {
      let name: PublishSubject<String>
      let entryLimit: PublishSubject<String>
      let description: PublishSubject<String>
      let spot: PublishSubject<String>
      let hardType: PublishSubject<String>
      let createError: PublishSubject<String>
      let createSuccess: PublishSubject<String>
   }
   
   func transform(for input: Input) -> Output {
      let name = PublishSubject<String>()
      let entryLimit = PublishSubject<String>()
      let description = PublishSubject<String>()
      let spot = PublishSubject<String>()
      let hardType = PublishSubject<String>()
      let createError = PublishSubject<String>()
      let createSuccess = PublishSubject<String>()
      
      input.groupName
         .subscribe(with: self) { vm, text in
            let trimmedText = vm.trimmingText(for: text, index: 15)
            name.onNext(trimmedText)
            vm.postGroupInput.title = trimmedText
         }
         .disposed(by: disposeBag)
      
      input.groupEntryLimit
         .subscribe(with: self) { vm, text in
            let countedText = vm.countingText(for: text, limit: 100)
            entryLimit.onNext(countedText)
            vm.postGroupInput.entryLimit = countedText
         }
         .disposed(by: disposeBag)
      
      input.groupDescription
         .subscribe(with: self) { vm, text in
            let trimmedText = vm.trimmingText(for: text, index: 300)
            description.onNext(trimmedText)
            vm.postGroupInput.content = trimmedText
         }
         .disposed(by: disposeBag)
      
      input.groupSpot
         .subscribe(with: self) { vm, text in
            let trimmedText = vm.trimmingText(for: text, index: 15)
            spot.onNext(trimmedText)
            vm.postGroupInput.mainSpot = trimmedText
         }
         .disposed(by: disposeBag)
      
      input.groupHardType
         .subscribe(with: self) { vm, text in
            hardType.onNext(text)
            vm.postGroupInput.runningHardType = text
         }
         .disposed(by: disposeBag)
      
      input.createButtonTapped
         .subscribe(with: self) { vm, _ in
            let valid = vm.validateForCreate()
            if valid {
               Task {
                  await vm.createGroup(
                     successEmitter: createSuccess,
                     errorEmitter: createError
                  )
               }
            } else {
               createError.onNext("모든 항목을 채워주세요.")
            }
         }
         .disposed(by: disposeBag)
            
      return Output(
         name: name,
         entryLimit: entryLimit,
         description: description,
         spot: spot,
         hardType: hardType,
         createError: createError,
         createSuccess: createSuccess
      )
   }
}

extension RunningGroupCreateViewModel {
   private func trimmingText(for text: String, index: Int) -> String {
      if text.count >= index {
         let index = text.index(text.startIndex, offsetBy: index)
         return String(text[..<index])
      } else {
         return text
      }
   }
   
   private func countingText(for text: String, limit: Int) -> String {
      if let count = Int(text), count >= limit {
         return "\(limit - 1)"
      } else {
         return text
      }
   }
   
   private func validateForCreate() -> Bool {
      if postGroupInput.title.isEmpty ||
            postGroupInput.content.isEmpty ||
            postGroupInput.entryLimit.isEmpty ||
            postGroupInput.runningHardType.isEmpty ||
            postGroupInput.mainSpot.isEmpty
      {
         return false
      } else {
         return true
      }
   }
   
   private func createGroup(
      successEmitter: PublishSubject<String>,
      errorEmitter: PublishSubject<String>
   ) async {
      let postInput: PostsInput = .init(
         product_id: postGroupInput.productId.rawValue,
         title: postGroupInput.title,
         content: postGroupInput.content,
         content1: postGroupInput.entryLimit,
         content2: postGroupInput.mainSpot,
         content3: postGroupInput.runningHardType,
         content4: nil,
         content5: nil,
         files: nil
      )
      
      do {
         let results = try await networkManager.request(
            by: PostEndPoint.posts(input: postInput),
            of: PostsOutput.self
         )
         
         successEmitter.onNext("\(results.title) 그룹 생성 완료")
         
      } catch NetworkErrors.dataNotFound {
         errorEmitter.onNext("\(NetworkErrors.dataNotFound.byErrorMessage)")
      } catch NetworkErrors.needToRefreshRefreshToken {
         await tempLoginAPI()
         await createGroup(successEmitter: successEmitter, errorEmitter: errorEmitter)
      } catch {
         dump(error)
      }
   }
   
}
