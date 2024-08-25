//
//  RunningProductType.swift
//  runwithu
//
//  Created by 강한결 on 8/16/24.
//

import Foundation

@frozen enum RunningProductType: String, CaseIterable {
   case runningShoe
   case runningClothingTop
   case runningClothingBottom
   case runningCap
   case runningAccessories
   case etc
   
   var byProductTypeName: String {
      switch self {
      case .runningShoe:
         return "러닝화"
      case .runningClothingTop:
         return "러닝 상의"
      case .runningClothingBottom:
         return "러닝 하의"
      case .runningCap:
         return "러닝 모자"
      case .runningAccessories:
         return "러닝 악세사리"
      case .etc:
         return "기타"
      }
   }
}

enum RunningProductBrandType: String, CaseIterable {
   case Nike
   case Adidas
   case Hoka
   case OnRunning
   case Newbalance
   case Asics
   case Puma
   case Saucony
   case Mizuno
   case etc
   
   var byBrandKoreanName: String {
      switch self {
      case .Nike:
         "나이키"
      case .Adidas:
         "아디다스"
      case .Hoka:
         "호카"
      case .OnRunning:
         "온 러닝"
      case .Newbalance:
         "뉴발란스"
      case .Asics:
         "아식스"
      case .Puma:
         "푸마"
      case .Saucony:
         "써코니"
      case .Mizuno:
         "미즈노"
      case .etc:
         "기타"
      }
   }
}
