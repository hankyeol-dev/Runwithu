//
//  BottomSheetViewModel.swift
//  runwithu
//
//  Created by 강한결 on 8/19/24.
//

import Foundation

import RxSwift

final class BottomSheetViewModel: BaseViewModelProtocol {
   private let mode: BottomSheetMode
   private let disposeBag = DisposeBag()
   private let networkManager = NetworkService.shared
   
   private var multiSelectRows: [Int] = []
   private var following: [BaseProfileType] = []

   enum BottomSheetMode {
      case community
      case userList
   }
   
   
   init(mode: BottomSheetMode) {
      self.mode = mode
   }
   
   struct Input {
      let didLoad: PublishSubject<Void>
      let singleSelect: PublishSubject<Int>
      let multiSelect: PublishSubject<Int>
   }
   
   struct Output {
      let didLoad: PublishSubject<[String]>
      let singleSelect: PublishSubject<Int>
      let multiSelect: PublishSubject<[Int]>
   }
   
   func transform(for input: Input) -> Output {
      let didLoadOutput = PublishSubject<[String]>()
      let singleSelect = PublishSubject<Int>()
      let multiSelect = PublishSubject<[Int]>()
      
      input.didLoad
         .subscribe(with: self) { vm, _ in
            switch vm.mode {
            case .community:
               didLoadOutput.onNext(PostsCommunityType.allCases.map { $0.byKoreanTitle })
               break
            default:
               Task {
                  await vm.readFollowers()
                  didLoadOutput.onNext(vm.following.map { $0.nick })
               }
               break
            }
         }
         .disposed(by: disposeBag)
      
      input.singleSelect
         .subscribe(with: self) { vm, row in
            singleSelect.onNext(row)
         }
         .disposed(by: disposeBag)
      
      input.multiSelect
         .subscribe(with: self) { vm, row in
            if let index = vm.multiSelectRows.firstIndex(of: row) {
               vm.multiSelectRows.remove(at: index)
            } else {
               vm.multiSelectRows.append(row)
            }
            multiSelect.onNext(vm.multiSelectRows)
         }
         .disposed(by: disposeBag)
      
      return Output(
         didLoad: didLoadOutput,
         singleSelect: singleSelect,
         multiSelect: multiSelect
      )
   }
}

extension BottomSheetViewModel {
   private func readFollowers() async {
      do {
         let results = try await networkManager.request(
            by: UserEndPoint.readMyProfile,
            of: FollowingsOutput.self
         )
         
         following = results.following
         
      } catch NetworkErrors.needToRefreshRefreshToken {
         await tempLoginAPI()
      } catch {
         dump(error)
      }
   }
}
