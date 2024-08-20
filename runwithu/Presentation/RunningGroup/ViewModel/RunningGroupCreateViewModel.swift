//
//  RunningGroupCreateViewModel.swift
//  runwithu
//
//  Created by 강한결 on 8/19/24.
//

import Foundation

import RxSwift

final class RunningGroupCreateViewModel: BaseViewModelProtocol {
   struct Input {
      let groupName: PublishSubject<String>
   }
   
   struct Output {}
   
   func transform(for input: Input) -> Output {
      
      
      return Output()
   }
}

extension RunningGroupCreateViewModel {
   private func validGroupName() {
      
   }
}
