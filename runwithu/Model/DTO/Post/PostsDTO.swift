//
//  PostsDTO.swift
//  runwithu
//
//  Created by 강한결 on 8/16/24.
//

import Foundation

struct PostsInput: Encodable {
   let product_id: String
   let title: String
   let content: String
   let content1: String?
   let content2: String?
   let content3: String?
   let content4: String?
   let content5: String?
   let files: [String]?
}

struct PostsOutput: Decodable {
   let post_id: String
   let product_id: String
   let title: String
   let content: String
   let content1: String?
   let content2: String?
   let content3: String?
   let content4: String?
   let content5: String?
   let createdAt: String
   let creator: BaseProfileType
   let files: [String]
   let likes: [String]
   let likes2: [String]
   let hashTags: [String]
   let comments: [CommentsOutput]
}
