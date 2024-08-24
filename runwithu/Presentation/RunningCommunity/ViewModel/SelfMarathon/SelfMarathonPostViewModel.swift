//
//  SelfMarathonPostViewModel.swift
//  runwithu
//
//  Created by 강한결 on 8/23/24.
//

import Foundation

import RxSwift

final class SelfMarathonPostViewModel: BaseViewModelProtocol {
   let disposeBag: DisposeBag
   let networkManager: NetworkService
   
   init(
      disposeBag: DisposeBag,
      networkManager: NetworkService
   ) {
      self.disposeBag = disposeBag
      self.networkManager = networkManager
   }
   
   struct Input {}
   struct Output {}
   
   func transform(for input: Input) -> Output {
      return Output()
   }
}
