//
//  RunningProductType.swift
//  runwithu
//
//  Created by 강한결 on 8/16/24.
//

import Foundation

@frozen enum RunningProductType {
   case runningShoe
   case runningClothingTop
   case runningClothingBottom
   case runningCap
   case runningAccessories
   case etc(input: String)
   
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
      case let .etc(input):
         return "기타-(\(input))"
      }
   }
}

enum RunningProductBrandType: String {
   case nike
   case adidas
   case hoka
   case onRunning
   case newbalance
}
