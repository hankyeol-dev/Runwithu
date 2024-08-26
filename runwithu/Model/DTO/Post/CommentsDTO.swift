//
//  CommentsDTO.swift
//  runwithu
//
//  Created by 강한결 on 8/26/24.
//

import Foundation

struct CommentInput: Encodable {
   let content: String
}

struct CommentsInput {
   let post_id: String
   var comment: CommentInput
}


struct CommentsOutput: Decodable {
   let comment_id: String
   let content: String
   let createdAt: String
   let creator: BaseProfileType
}
