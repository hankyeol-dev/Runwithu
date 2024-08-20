//
//  RunningGroupListViewModel.swift
//  runwithu
//
//  Created by 강한결 on 8/20/24.
//

import Foundation

import RxSwift

final class RunningGroupListViewModel: BaseViewModelProtocol {
   struct Input {
      let floatingButtonTapped: PublishSubject<Void>
   }
   struct Output {
      let floatingButtonTapped: PublishSubject<Void>
   }
   
   func transform(for input: Input) -> Output {
      
      
      return Output(
         floatingButtonTapped: input.floatingButtonTapped
      )
   }
}
