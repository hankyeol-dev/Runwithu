//
//  RunningHardType.swift
//  runwithu
//
//  Created by 강한결 on 8/16/24.
//

import Foundation

enum RunningHardType: String, CaseIterable {
   case very_hard = "매우 힘들어요"
   case hard = "힘들어요"
   case normal = "적당히 힘들 수 있어요"
   case easy = "가볍게 달릴 수 있어요"
   case very_easy = "정말 쉽게 달릴 수 있어요"
   
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
