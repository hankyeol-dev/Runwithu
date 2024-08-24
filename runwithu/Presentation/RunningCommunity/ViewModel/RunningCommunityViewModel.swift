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
   
   init(
      disposeBag: DisposeBag,
      networkManager: NetworkService
   ) {
      self.disposeBag = disposeBag
      self.networkManager = networkManager
   }
   
   struct Input {
      let writeButtonTapped: PublishSubject<Void>
      let selectedCommunityType: PublishSubject<BottomSheetSelectedItem>
   }
   struct Output {
      let writeButtonTapped: PublishSubject<[BottomSheetSelectedItem]>
      let selectedCommunityType: PublishSubject<PostsCommunityType>
   }
   
   func transform(for input: Input) -> Output {
      let writeButtonTapped = PublishSubject<[BottomSheetSelectedItem]>()
      let selectedCommunityType = PublishSubject<PostsCommunityType>()
      
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
      
      input.selectedCommunityType
         .subscribe(with: self) { vm, item in
            guard let type = vm.bindingToCommunityType(for: item) else {
               return
            }
            selectedCommunityType.onNext(type)
         }
         .disposed(by: disposeBag)
      
      return Output(
         writeButtonTapped: writeButtonTapped,
         selectedCommunityType: selectedCommunityType
      )
   }
}

extension RunningCommunityViewModel {
   private func bindingToCommunityType(
      for item: BottomSheetSelectedItem
   ) -> PostsCommunityType? {
      
      switch item.title {
      case PostsCommunityType.epilogue.byKoreanTitle:
         return .epilogue
      case PostsCommunityType.product_epilogue.byKoreanTitle:
         return .product_epilogue
      case PostsCommunityType.qna.byKoreanTitle:
         return .qna
      case PostsCommunityType.open_self_marathon.byKoreanTitle:
         return .open_self_marathon
      default:
         return nil
      }
      
   }
}
