//
//  RunningEpiloguePostViewModel.swift
//  runwithu
//
//  Created by 강한결 on 8/23/24.
//

import Foundation

import RxSwift

final class RunningEpiloguePostViewModel: BaseViewModelProtocol {
   let disposeBag: DisposeBag
   let networkManager: NetworkService
   private let isInGroupSide: Bool
   private var epilogueId: String = ""
   private var invitationList: [(String, String)] = []
   private var selectedInvitation: String = ""
   var selectedImages: [Data] = []
   private lazy var runningEpilogueInput: EpilogueInput = .init(
      productId: isInGroupSide ? .runwithu_community_posts_group : .runwithu_community_posts_public,
      title: "",
      content: "",
      runningInfo: .init(date: Date().formattedRunningDate()),
      invitationId: nil
   )
   
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
      let didLoadInput: PublishSubject<Void>
      let titleInput: PublishSubject<String>
      let contentInput: PublishSubject<String>
      let dateInput: PublishSubject<String>
      let selectedInvitation: PublishSubject<String>
      let courseInput: PublishSubject<String>
      let hardTypeInput: PublishSubject<String>
      let createButtonTapped: PublishSubject<Void>
   }
   struct Output {
      let didLoadInvitations: PublishSubject<[String]>
      let successEmitter: PublishSubject<String>
      let errorEmitter: PublishSubject<String>
   }
   
   func transform(for input: Input) -> Output {
      let didLoadInvitation = PublishSubject<[String]>()
      let successEmitter = PublishSubject<String>()
      let errorEmitter = PublishSubject<String>()
      
      input.didLoadInput
         .subscribe(with: self) { vm, _ in
            Task {
               await vm.getUsersInvitations(emitter: didLoadInvitation)
            }
         }
         .disposed(by: disposeBag)
      
      input.titleInput
         .subscribe(with: self) { vm, title in
            if !title.isEmpty {
               vm.runningEpilogueInput.title = title
            }
         }
         .disposed(by: disposeBag)
      
      input.contentInput
         .subscribe(with: self) { vm, content in
            if !content.isEmpty && content != "이번 러닝은 어땠나요?" {
               vm.runningEpilogueInput.content = content
            }
         }
         .disposed(by: disposeBag)
      
      input.dateInput
         .subscribe(with: self) { vm, date in
            vm.runningEpilogueInput.runningInfo?.date = date
         }
         .disposed(by: disposeBag)
      
      input.courseInput
         .subscribe(with: self) { vm, course in
            vm.runningEpilogueInput.runningInfo?.course = course
         }
         .disposed(by: disposeBag)
      
      input.hardTypeInput
         .subscribe(with: self) { vm, hardType in
            vm.runningEpilogueInput.runningInfo?.hardType = hardType
         }
         .disposed(by: disposeBag)
      
      input.selectedInvitation
         .subscribe(with: self) { vm, invitation in
            vm.selectedInvitation = invitation
         }
         .disposed(by: disposeBag)
      
      input.createButtonTapped
         .subscribe(with: self) { vm, _ in
            Task {
               await vm.createPost(successEmitter: successEmitter, errorEmitter: errorEmitter)
            }
         }
         .disposed(by: disposeBag)
      
      return Output(
         didLoadInvitations: didLoadInvitation,
         successEmitter: successEmitter,
         errorEmitter: errorEmitter
      )
   }
   
   func getEpilogueId() -> String { return epilogueId }
}

extension RunningEpiloguePostViewModel {
   private func getUsersInvitations(
      emitter: PublishSubject<[String]>
   ) async {
      do {
         let invitations = try await networkManager.request(
            by: PostEndPoint.getPosts(
               input: .init(
                  product_id: ProductIds.runwithu_running_inviation.rawValue,
                  limit: 100000,
                  next: nil)),
            of: GetPostsOutput.self
         )
         let user = try await networkManager.request(
            by: UserEndPoint.readMyProfile,
            of: ProfileOutput.self)
         
         let userCreated = invitations.data.filter {
            $0.creator.user_id == user.user_id
         }
         
         let mappedUserCreated = mappingDataForDisplay(for: userCreated) { post, info in
            return "내가 보낸 - " + post.title + " (\(info.date))"
         }
         
         let userInvited = invitations.data.filter {
            if let content1 = $0.content1 {
               return content1.contains(user.user_id)
            } else {
               return false
            }
         }
         
         let mappedUserInvited = mappingDataForDisplay(for: userInvited) { post, info in
            return "내가 받은 - " + post.title + " (\(info.date))"
         }
         
         invitationList = mappedUserCreated + mappedUserInvited
         emitter.onNext((mappedUserCreated + mappedUserInvited).map { $0.1 })
         
      } catch NetworkErrors.needToRefreshRefreshToken {
         await tempLoginAPI()
         await getUsersInvitations(emitter: emitter)
      } catch {
         emitter.onNext([])
      }
   }
   
   private func mappingDataForDisplay(
      for input: [PostsOutput],
      by propertyHandler: @escaping (PostsOutput, RunningInfo) -> String
   ) -> [(String, String)] {
      return input.map {
         if let runningInfo = $0.content2 {
            if let info = $0.convertToData(for: runningInfo, of: RunningInfo.self) {
               return ($0.post_id, propertyHandler($0, info))
            }
            return ("", "")
         } else {
            return ("", "")
         }
      }.filter { !$0.0.isEmpty && !$0.1.isEmpty }
   }
   
   private func validInvitation(for invitation: String) -> String? {
      let targetInvitation = invitationList.filter { $0.1 == invitation }
      if let first = targetInvitation.first {
         return first.0
      } else {
         return nil
      }
   }
   
   private func uploadImages(
      errorEmitter: PublishSubject<String>
   )  async throws -> [String] {
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
            return try await uploadImages(errorEmitter: errorEmitter)
         } catch {
            errorEmitter.onNext("이미지 첨부에 실패했어요.")
            return []
         }
      } else {
         print("이미지 비었음")
         return []
      }
   }
   
   private func createPost(
      successEmitter: PublishSubject<String>,
      errorEmitter: PublishSubject<String>
   ) async {
      if !validPost() {
         errorEmitter.onNext("필수 항목을 모두 채워주세요.")
         return
      }
      
      let invitationId = validInvitation(for: selectedInvitation)
      
      
      do {
         let imageFiles = try await uploadImages(errorEmitter: errorEmitter)
         let postInput: PostsInput = .init(
            product_id: runningEpilogueInput.productId.rawValue,
            title: runningEpilogueInput.title,
            content: runningEpilogueInput.content,
            content1: runningEpilogueInput.communityType.rawValue,
            content2: runningEpilogueInput.runningInfo?.byJsonString,
            content3: invitationId,
            content4: nil,
            content5: nil,
            files: !imageFiles.isEmpty ? imageFiles : nil
         )
         
         
         let postResults = try await networkManager.request(
            by: PostEndPoint.posts(input: postInput),
            of: PostsOutput.self)
         epilogueId = postResults.post_id
         successEmitter.onNext(postResults.post_id)
      } catch NetworkErrors.needToRefreshRefreshToken {
         await tempLoginAPI()
         await createPost(successEmitter: successEmitter, errorEmitter: errorEmitter)
      } catch {
         errorEmitter.onNext("러닝 일지 작성에 뭔가 문제가 생겼어요.")
      }
   }
   
   private func validPost() -> Bool {
      guard let date = runningEpilogueInput.runningInfo?.date else { return false }
      
      if !runningEpilogueInput.title.isEmpty && !runningEpilogueInput.content.isEmpty && !date.isEmpty {
         return true
      } else {
         return false
      }
      
   }
}
