//
//  PostsCommunityType.swift
//  runwithu
//
//  Created by 강한결 on 8/16/24.
//

import UIKit

enum PostsCommunityType: String, CaseIterable {
   case epilogue
   case product_epilogue
   case qna
   case open_self_marathon
   
   var byKoreanTitle: String {
      switch self {
      case .epilogue:
         return "러닝 후기 남기기"
      case .product_epilogue:
         return "러닝 용품 후기 남기기"
      case .qna:
         return "러닝 질문 올리기"
      case .open_self_marathon:
         return "셀프 마라톤 개최 (준비중)"
      }
   }
   
   var byTitleImage: UIImage {
      switch self {
      case .epilogue:
         return .runner
      case .product_epilogue:
         return .runningshoe
      case .qna:
         return UIImage.qna
      case .open_self_marathon:
         return .marathon
      }
   }
}
