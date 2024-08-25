//
//  RunningQnaType.swift
//  runwithu
//
//  Created by 강한결 on 8/25/24.
//

import Foundation

enum RunningQnaType: String, CaseIterable {
   case running
   case product
   case injury
   case etc
   
   var byKoreanQnaCase: String {
      switch self {
      case .running:
         "러닝 일반"
      case .product:
         "러닝 용품 관련"
      case .injury:
         "러닝 부상 관련"
      case .etc:
         "기타"
      }
   }
}
