//
//  LoginDTO.swift
//  runwithu
//
//  Created by 강한결 on 8/14/24.
//

import Foundation

struct LoginInput: Encodable {
  let email: String
  let password: String
}

struct LoginOutput: Decodable {
   let user_id: String
   let email: String
   let nick: String
   let profileImage: String?
   let accessToken: String
   let refreshToken: String
}
