//
//  PostLikeDTO.swift
//  runwithu
//
//  Created by 강한결 on 8/27/24.
//

import Foundation

struct PostLikeInput {
   let postId: String
   let isLike: PostLikeStatus
}

struct PostLikeStatus: Encodable {
   let like_status: Bool
}

struct PostLikeOutput: Decodable {
   let like_status: Bool
}
