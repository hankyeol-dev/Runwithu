//
//  ProductIds.swift
//  runwithu
//
//  Created by 강한결 on 8/16/24.
//

import Foundation

enum ProductIds: String, CaseIterable {
   case runwithu_community_posts_public
   case runwithu_community_posts_group // MARK: 그룹 id를 suffix로 반영해줘야 함
   case runwithu_running_group
   case runwithu_running_inviation
   
   var byKoreanTitle: String {
      switch self {
      case .runwithu_community_posts_public, .runwithu_community_posts_group:
         return "러닝 커뮤니티 글 쓰기"
      case .runwithu_running_group:
         return "러닝 그룹 만들기"
      case .runwithu_running_inviation:
         return "함께 뛰기 초대장 만들기"
      }
   }
}
