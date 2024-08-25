//
//  QnaInput.swift
//  runwithu
//
//  Created by 강한결 on 8/16/24.
//

import Foundation

struct QnaInput: PostInputTypeProtocol {
   var productId: ProductIds
   var title: String
   var content: String
   var communityType: PostsCommunityType = .qna
   var qnaType: String
}
