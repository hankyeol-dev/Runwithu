//
//  SearchUserDTO.swift
//  runwithu
//
//  Created by 강한결 on 8/23/24.
//

import Foundation

struct SearchUserByNickInput {
   let nick: String
}

struct SearchUserByNickOutput: Decodable {
   let data: [SearchedUser]
}

struct SearchedUser: Decodable {
   let user_id: String
   let nick: String
}
