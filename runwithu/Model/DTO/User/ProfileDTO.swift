//
//  ProfileDTO.swift
//  runwithu
//
//  Created by 강한결 on 8/15/24.
//

import Foundation

struct ProfileInput: Encodable {
   let user_id: String
}

struct ProfileUpdateInput: Encodable {
   let nick: String?
   let phoneNum: String?
}

struct ProfileImageUpdateInput {
   let boundary: String = UUID().uuidString
   let profile: Data?
}

struct ProfileOutput: Decodable {
   let user_id: String
   let email: String?
   let nick: String
   let phoneNum: String?
   let birthDay: String?
   let profileImage: String?
   let followers: [BaseProfileType]
   let following: [BaseProfileType]
   let posts: [String]
}

struct FollowingsOutput: Decodable {
   let following: [BaseProfileType]
}

struct BaseProfileType: Decodable {
   let user_id: String
   let nick: String
   let profileImage: String?
}

