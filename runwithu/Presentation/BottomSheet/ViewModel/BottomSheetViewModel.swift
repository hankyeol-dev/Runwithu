//
//  BottomSheetViewModel.swift
//  runwithu
//
//  Created by 강한결 on 8/19/24.
//

import Foundation

import RxSwift

final class BottomSheetViewModel: BaseViewModelProtocol {
   private let bag = DisposeBag()
   let menus = PostsCommunityType.allCases.map { $0.byKoreanTitle }
   
   struct Input {}
   struct Output {}
   
   func transform(for input: Input) -> Output {
      return Output()
   }
}
