//
//  RunningHardType.swift
//  runwithu
//
//  Created by 강한결 on 8/16/24.
//

import Foundation

enum RunningHardType: String, CaseIterable {
   case very_hard
   case hard
   case normal
   case easy
   case very_easy
   
   var byLevel: String {
      switch self {
      case .very_hard:
         return "초고수 (10년 이상 러닝)"
      case .hard:
         return "고수 (5년 이상 러닝)"
      case .normal:
         return "어느정도 (1년 이상 러닝)"
      case .easy:
         return "초보 (1년 미만 러닝)"
      case .very_easy:
         return "입문 (이제 러닝 시작)"
      }
   }
}
