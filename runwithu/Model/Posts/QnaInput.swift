//
//  QnaInput.swift
//  runwithu
//
//  Created by 강한결 on 8/16/24.
//

import Foundation

struct QnaInput: PostInputTypeProtocol {
   let productId: ProductIds
   let title: String
   let content: String
   let communityType: PostsCommunityType = .qna
}
