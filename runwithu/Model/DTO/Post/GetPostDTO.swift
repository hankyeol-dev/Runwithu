//
//  GetPostDTO.swift
//  runwithu
//
//  Created by 강한결 on 8/16/24.
//

import Foundation

struct GetPostInput {
   let post_id: String
}

struct GetPostsInput {
   let product_id: String
   var limit: Int = 5
   let next: String?
}

struct GetPostsOutput: Decodable {
   let data: [PostsOutput]
   let next_cursor: String
}
