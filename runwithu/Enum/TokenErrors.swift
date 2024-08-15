//
//  TokenErrors.swift
//  runwithu
//
//  Created by 강한결 on 8/15/24.
//

import Foundation

enum TokenErrors: Error {
   case keyChainSearchError(msg: String)
   case convertTokenError
   case notFoundTokenError
   
   var byErrorMessage: String {
      switch self {
      case let .keyChainSearchError(msg):
         return msg
      case .convertTokenError:
         return "토큰 변환 실패"
      case .notFoundTokenError:
         return "토큰을 찾을 수 없습니다."
      }
   }
}
