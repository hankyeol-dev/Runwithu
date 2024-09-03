//
//  PostsCommunityType.swift
//  runwithu
//
//  Created by 강한결 on 8/16/24.
//

import UIKit

enum PostsCommunityType: String, CaseIterable {
   case epilogues
   case product_epilogues
   case qnas
   case open_self_marathons
   
   var byKoreanTitle: String {
      switch self {
      case .epilogues:
         return "러닝 후기 남기기"
      case .product_epilogues:
         return "러닝 용품 후기 남기기"
      case .qnas:
         return "러닝 질문 올리기"
      case .open_self_marathons:
         return "나만의 마라톤 개최 (준비중)"
      }
   }
   
   var byTitleImage: UIImage {
      switch self {
      case .epilogues:
         return .runner
      case .product_epilogues:
         return .runningshoe
      case .qnas:
         return UIImage.qna
      case .open_self_marathons:
         return .marathon
      }
   }
   
   var byDetailLabel: String {
      switch self {
      case .epilogues:
         return "러닝 일지"
      case .product_epilogues:
         return "러닝 기어 후기"
      case .qnas:
         return "러닝 질문"
      case .open_self_marathons:
         return "셀프 마라톤"
      }
   }
}
